import 'dart:convert';
import 'dart:typed_data';

import 'package:centyneg_sys/commons/Globals.dart';
import 'package:centyneg_sys/models/drop_item_model.dart';
import 'package:centyneg_sys/providers/printing_provider.dart';
import 'package:centyneg_sys/widgets/loading_widget.dart';
import 'package:date_field/date_field.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:empty_widget/empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pdf_render/pdf_render_widgets.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';

class BoucherReporteScreen extends StatefulWidget {
  const BoucherReporteScreen({super.key});

  @override
  State<BoucherReporteScreen> createState() => _BoucherReporteScreenState();
}

class _BoucherReporteScreenState extends State<BoucherReporteScreen> {
  Uint8List? bytes;
  var entidadController= TextEditingController();
  DropItemModel? cuenta;
  var desde=DateTime(Globals.periodo,1,1);
  var hasta=DateTime(Globals.periodo,12,31);
  final dio= Dio(BaseOptions(baseUrl: Globals.apiUrl));
  var isLoading=true;
  var me={};

  loadDataFromApi() async {
       me= await Globals.getMe();
      setState(() {
        isLoading=false;
      });
  }

  @override
  void initState() {
    loadDataFromApi();
    super.initState();
  }

  var pdfController= PdfViewerController();

  @override
  Widget build(BuildContext context) {
   var size= MediaQuery.of(context).size;
    return Scaffold(
      body: isLoading ? const LoadingWidget() : SingleChildScrollView(
        child: Container(
          width: size.width ,
          height: 700,
          child: Stack(
            children: [
              Positioned(
                top: 20,
                left: 20,
                child: Container(
                  width: 300,
                  height: 700,
                  color: Colors.blue.withOpacity(0.2),
                child: Stack(
                  children: [
                    const Positioned(left: 20,
                      top: 40,child: Text('CRITERIOS DE CONSULTA', style: TextStyle(fontSize: 20,
                        decoration: TextDecoration.underline
                        ,fontWeight: FontWeight.bold), ),
                    ),
                    Positioned(left: 20,
                      top: 150,child: SizedBox(
                        width: 250,
                        height: 50,
                        child: DropdownSearch<DropItemModel>(
                          asyncItems: (f)=>  (dio.get('/api/arqueos/listar-bouchers',queryParameters: {
                            'clientId':me['clientId']
                          }).then((value) => (value.data as List).map((e) => DropItemModel(e['id'], e['code'])).toList())),
                          onChanged: (a){
                            cuenta=a;
                          },
                          dropdownDecoratorProps: const DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                  label: Text('Seleccionar Boucher')
                              )
                          ),
                        ),
                      ),
                    ),
                    Positioned(left: 20,
                      top: 220,child: SizedBox(
                        width: 250,
                        height: 50,
                        child:DateTimeFormField(
                          dateFormat: DateFormat('dd/MM/yyyy'),
                          initialValue: desde,
                          decoration: const InputDecoration(
                            hintStyle: TextStyle(color: Colors.black45),
                            errorStyle: TextStyle(color: Colors.redAccent),
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.event_note),
                            labelText: 'Fecha Desde',
                          ),
                          mode: DateTimeFieldPickerMode.date,
                          autovalidateMode: AutovalidateMode.always,
                          onDateSelected: (DateTime value) {
                            desde=value;
                          },
                        )
                      ),
                    ),
                    Positioned(left: 20,
                      top: 280,child: SizedBox(
                          width: 250,
                          height: 50,
                          child:DateTimeFormField(
                            dateFormat: DateFormat('dd/MM/yyyy'),
                            initialValue: hasta,
                            decoration: const InputDecoration(
                              hintStyle: TextStyle(color: Colors.black45),
                              errorStyle: TextStyle(color: Colors.redAccent),
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.event_note),
                              labelText: 'Fecha Hasta',
                            ),
                            mode: DateTimeFieldPickerMode.date,
                            autovalidateMode: AutovalidateMode.always,
                            onDateSelected: (DateTime value) {
                              hasta=value;
                            },
                          )
                      ),
                    ),
                    Positioned(left: 20,
                      top: 350,child: SizedBox(
                        width: 200,
                        height: 50,
                        child: ElevatedButton.icon(onPressed: () async{
                          var result= await dio.post('/api/reportes/generar-informe-boucher',data: {
                            'id':cuenta?.id,
                            'desde':desde.toIso8601String(),
                            'hasta':hasta.toIso8601String()
                          });
                           bytes = base64Decode(result.data);
                          setState(() {

                          });
                        }, icon: const Icon(Icons.picture_as_pdf), label: const Text('Generar Informe')
                        ),
                      ),
                    ),
                    Positioned(left: 20,
                      top: 430,child: SizedBox(
                        width: 200,
                        height: 50,
                        child: ElevatedButton.icon(onPressed: () async{
                          var result= await dio.post('/api/reportes/generar-informe-boucher',data: {
                            'id':cuenta?.id,
                            'desde':desde.toIso8601String(),
                            'hasta':hasta.toIso8601String()
                          });
                         var printer= Provider.of<PrintingProvider>(context,listen: false);
                         printer.printPdfByBase64(result.data);
                        }, icon: const Icon(Icons.print), label: const Text('Imprimir Informe')
                        ),
                      ),
                    )
                  ],
                ),
                ),
              ),
              Positioned(
                top: 20,
                left: 330,
                child: Container(
                  width: size.width * 0.80,
                  height: 700,
                  color: Colors.lightGreen.withOpacity(0.2),
                  child: PdfViewer.openData(bytes ?? Uint8List(2),viewerController: pdfController)
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
