import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:centyneg_sys/commons/Globals.dart';
import 'package:centyneg_sys/models/items_models.dart';
import 'package:centyneg_sys/models/search_item_model.dart';
import 'package:centyneg_sys/providers/printing_provider.dart';
import 'package:centyneg_sys/providers/sys_data_provider.dart';
import 'package:centyneg_sys/widgets/custom_container.dart';
import 'package:centyneg_sys/widgets/loading_widget.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../commons/app_color.dart';
import '../widgets/custom_dropdown_button2.dart';

class LibrosScreen extends StatefulWidget {
  const LibrosScreen({super.key});

  @override
  State<LibrosScreen> createState() => _State();
}

class _State extends State<LibrosScreen> {
  var fechaDesdeController= TextEditingController();
  var fechaHastaController= TextEditingController();
  DateTime? desde;
  DateTime? hasta;
  ItemModel? libro;
  bool isLoading=false;
  var searchAccountController= TextEditingController();
  var tiposDeLibros=[ItemModel(1, 'LIBRO DE COMPRA'),ItemModel(2, 'LIBRO DE VENTA')];
  @override
  Widget build(BuildContext context) {
    var provider= Provider.of<SysDataProvider>(context);
    var printing= Provider.of<PrintingProvider>(context);
    return  Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColor.white),
        title: Text(
          'Generar Libro Contable', style: TextStyle(color: AppColor.white),),
        backgroundColor: AppColor.darkBlue,),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40,),
            Center(child: CustomContainer(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              containerWith: 500,
              containerHeight: 400,
              child: Column(
                children: [
                   Text('Generar LIBRO CONTABLE por Rango de Fecha, PERIODO ${Globals.periodo}'),
                  const SizedBox(height: 20,),
                  Row(
                    children: [
                      CustomDropdownButton2(hint: 'Seleccionar el tipo de libro',
                          buttonWidth: 420,
                          dropdownWidth: 500,
                          dropdownHeight: 500,
                          buttonHeight: 30,
                          value: libro,
                          dropdownItems: tiposDeLibros,
                          onChanged: (a) async  {
                            setState(() {
                              libro = a;
                            });
                          }),
                    ],
                  ),
                  const SizedBox(height: 10,),
              Row(
              children: [

                Flexible(child: SizedBox(
                  width: 300,
                  height: 30,
                  child: TextField(
                    readOnly: true,
                    controller: fechaDesdeController,
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Fecha Desde',
                      labelStyle: TextStyle(fontSize: 12),

                    ),
                  ),
                ),),
                const SizedBox(width: 20,),
                Flexible(child: SizedBox(
                  width: 150,
                  child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white38
                      ),
                      onPressed: () async {
                        var results = await showCalendarDatePicker2Dialog(
                          context: context,
                          config: CalendarDatePicker2WithActionButtonsConfig(),
                          dialogSize: const Size(325, 400),
                          value: [DateTime.now()],
                          borderRadius: BorderRadius.circular(
                              15),
                        );
                        desde = results?.first;
                        if (desde != null) {
                          fechaDesdeController.text =
                              DateFormat('dd/MM/yyyy').format(
                                  desde!);
                          setState(() {

                          });
                        }
                      },
                      icon: const Icon(Icons.calendar_month),
                      label: const Text('Seleccionar')),
                )
                )
  ]),
                  const SizedBox(height: 20,),
                  Row(
                      children: [
                        Flexible(child: SizedBox(
                          width: 300,
                          height: 30,
                          child: TextField(
                            readOnly: true,
                            controller: fechaHastaController,
                            style: const TextStyle(fontSize: 14),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Fecha Hasta',
                              labelStyle: TextStyle(fontSize: 12),

                            ),
                          ),
                        ),),
                        const SizedBox(width: 20,),
                        Flexible(child: SizedBox(
                          width: 150,
                          child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white38
                              ),
                              onPressed: () async {
                                var results = await showCalendarDatePicker2Dialog(
                                  context: context,
                                  config: CalendarDatePicker2WithActionButtonsConfig(),
                                  dialogSize: const Size(325, 400),
                                  value: [DateTime.now()],
                                  borderRadius: BorderRadius.circular(
                                      15),
                                );
                                hasta = results?.first;
                                if (hasta != null) {
                                  fechaHastaController.text =
                                      DateFormat('dd/MM/yyyy').format(
                                          hasta!);
                                  setState(() {

                                  });
                                }
                              },
                              icon: const Icon(Icons.calendar_month),
                              label: const Text('Seleccionar')),
                        )
                        )
                      ]),
                  const SizedBox(height: 10,),
                  ElevatedButton.icon(onPressed: () async{
                    setState(() {
                      isLoading=true;
                    });
                    var base64= await provider.generarLibro({
                      'desde': desde?.toIso8601String(),
                      'hasta':hasta?.toIso8601String(),
                      'libro': libro?.id,
                      'periodo': Globals.periodo,
                      'type':2
                    });
                    setState(() {
                      isLoading=false;
                    });
                    printing.downloadExcelFromBase64(base64);
                  }, icon: const Icon(Icons.download), label: const Text('Exportar a Excel')),
                  SizedBox(height: 10,),
                  ElevatedButton.icon(onPressed: () async{
                    setState(() {
                      isLoading=true;
                    });
                    var base64= await provider.generarLibro({
                      'desde': desde?.toIso8601String(),
                      'hasta':hasta?.toIso8601String(),
                      'libro': libro?.id,
                      'periodo': Globals.periodo,
                      'type':2
                    });
                    setState(() {
                      isLoading=false;
                    });
                    printing.downloadExcelFromBase64(base64);
                  }, icon: const Icon(Icons.download), label: const Text('Libro Fiscal')),
                  SizedBox(height: 10,),
                  ElevatedButton.icon(onPressed: () async{
                    setState(() {
                      isLoading=true;
                    });
                    var base64= await provider.generarLibro({
                      'desde': desde?.toIso8601String(),
                      'hasta':hasta?.toIso8601String(),
                      'libro': libro?.id,
                      'periodo': Globals.periodo,
                      'type':1
                    });
                    setState(() {
                      isLoading=false;
                    });
                    printing.printPdfByBase64(base64);
                  }, icon: const Icon(Icons.print), label: const Text('Libro General')),

                  if(isLoading)
                    const LoadingWidget()
                ],
              ),
            ),)
          ],
        ),
      ),
    );
  }
}
