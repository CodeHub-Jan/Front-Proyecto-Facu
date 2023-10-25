import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:centyneg_sys/models/drop_item_model.dart';
import 'package:centyneg_sys/models/items_models.dart';
import 'package:centyneg_sys/models/search_item_model.dart';
import 'package:centyneg_sys/providers/printing_provider.dart';
import 'package:centyneg_sys/providers/sys_data_provider.dart';
import 'package:centyneg_sys/widgets/custom_container.dart';
import 'package:centyneg_sys/widgets/loading_widget.dart';
import 'package:date_field/date_field.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:search_choices/search_choices.dart';

import '../commons/Globals.dart';
import '../commons/app_color.dart';
import '../widgets/custom_dropdown_button2.dart';

class InformeRentabilidadScreen extends StatefulWidget {
  const InformeRentabilidadScreen({super.key});

  @override
  State<InformeRentabilidadScreen> createState() => _State();
}

class _State extends State<InformeRentabilidadScreen> {
  DropItemModel? producto;
  DropItemModel? marca;
  DropItemModel? familia;
  var desde= DateTime(Globals.periodo,1,1), hasta= DateTime(Globals.periodo,12,31);
 List<DropdownMenuItem<DropItemModel>> productos= [];
  var me={};
  final dio= Dio(BaseOptions(baseUrl: Globals.apiUrl));
  ItemsClientModel? account;
  bool isLoading=true;
  var searchAccountController= TextEditingController();
  loadDataFromApi() async{
     me= await Globals.getMe();
     var productResult= await dio.get('/api/productos/get-all-products',queryParameters: {
       'clientId':me['clientId'],
       'pattern':'pattern'
     });
     productos= (productResult.data as List).map((e) => DropdownMenuItem<DropItemModel>(
         child: Text(e['nombre']),
         value: DropItemModel(e['id'], e['nombre']))).toList();
    setState(() {
      isLoading=false;
    });
  }
  @override
  void initState() {
    loadDataFromApi();
    super.initState();
  }

  clean(){
    producto=null;
    familia=null;
    marca=null;

  }

  @override
  Widget build(BuildContext context) {
    var printing= Provider.of<PrintingProvider>(context);
    return  Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColor.white),
        title: Text(
          'Generar Informe Rentabilidad', style: TextStyle(color: AppColor.white),),
        backgroundColor: AppColor.darkBlue,),
      body: isLoading? const LoadingWidget() : SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40,),
            Center(child: CustomContainer(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              containerWith: 500,
              containerHeight: 500,
              child: Column(
                children: [
                  const Text('Generar Informe de Rentabilidad', style: TextStyle(fontSize: 30),),
                  const SizedBox(height: 10,),
                  SizedBox(
                    width: 400,
                    child: SearchChoices<DropItemModel>.single(
                      items: productos,
                      value: producto,
                      hint: "Seleccionar un Producto",
                      searchHint: 'Buscar un producto',
                      onClear: (a){
                        clean();
                        setState(() {

                        });
                      },
                      onChanged: (value) {
                clean();
                        setState(() {
                          producto=value;
                        });
                      },
                      doneButton: "Listo",
                      displayItem: (item, selected) {
                        return (Row(children: [
                          selected
                              ? const Icon(
                            Icons.check,
                            color: Colors.grey,
                          )
                              : const Icon(
                            Icons.radio_button_unchecked,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: item,
                          ),
                        ]));
                      },
                      isExpanded: true,
                    ),
                  ),
                  const SizedBox(height: 5,),
                  SizedBox(
                    width: 400,
                    height: 70,
                    child: DropdownSearch<DropItemModel>(dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(labelText: 'Marca')
                    ),
                      asyncItems: (f)=> dio.get('/api/modules/get-tabla-valores', queryParameters: {
                        'tipo':2,
                        'clientId':me['clientId']
                      }).then((value) => (value.data as List).map((e) => DropItemModel(e['id'], e['name'])).toList()),
                      itemAsString: (u)=> u.title,
                      onChanged: (a){
                      clean();
                      marca=a;
                      setState(() {

                      });
                      },
                    ),),
                  const SizedBox(height: 5,),
                  SizedBox(
                    width: 400,
                    height: 70,
                    child: DropdownSearch<DropItemModel>(dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(labelText: 'Familia')
                    ),
                      onChanged: (a){

                        clean();
                        familia=a;
                        setState(() {

                        });
                      },
                      asyncItems: (f)=> dio.get('/api/modules/get-tabla-valores', queryParameters: {
                        'tipo':6,
                        'clientId':me['clientId']
                      }).then((value) => (value.data as List).map((e) => DropItemModel(e['id'], e['name'])).toList()),
                      itemAsString: (u)=> u.title,
                    ),),
                  SizedBox(height: 5,),
                  SizedBox(
                      width: 400,
                      height: 50,
                      child: DateTimeFormField(
                        dateFormat: DateFormat('dd/MM/yyyy'),
                        initialValue: desde,
                        decoration: const InputDecoration(
                          hintStyle: TextStyle(color: Colors.black45),
                          errorStyle: TextStyle(color: Colors.redAccent),
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.event_note),
                          labelText: 'Fecha de Desde',
                        ),
                        mode: DateTimeFieldPickerMode.date,
                        autovalidateMode: AutovalidateMode.always,
                        onDateSelected: (DateTime value) {
                          desde =value;
                        },
                      )
                  ),
                  SizedBox(height: 10,),
                  SizedBox(
                      width: 400,
                      height: 50,
                      child: DateTimeFormField(
                        dateFormat: DateFormat('dd/MM/yyyy'),
                        initialValue: hasta,
                        decoration: const InputDecoration(
                          hintStyle: TextStyle(color: Colors.black45),
                          errorStyle: TextStyle(color: Colors.redAccent),
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.event_note),
                          labelText: 'Fecha de Hasta',
                        ),
                        mode: DateTimeFieldPickerMode.date,
                        autovalidateMode: AutovalidateMode.always,
                        onDateSelected: (DateTime value) {
                          hasta =value;
                        },
                      )
                  ),
                  const SizedBox(height: 20,),
                  SizedBox(
                    width: 400,
                    height: 50,
                    child: ElevatedButton.icon(onPressed: () async{
                      EasyLoading.show(status: 'Generando Reporte');
                      var result= await dio.post('/api/reportes/generar-informe-renta',data: {
                        'clientId':me['clientId'],
                        'productId':producto?.id,
                        'marcaId':marca?.id,
                        'familiaId':familia?.id,
                        'desde': desde.toIso8601String(),
                        'hasta':hasta.toIso8601String()
                      });
                      var base64=result.data;
                      var printing= Provider.of<PrintingProvider>(context, listen: false);
                      EasyLoading.dismiss(animation: true);
                      printing.printPdfByBase64(base64);
                    }, icon: const Icon(Icons.print, size: 40,), label: const Text('Generar Informe Rentabilidad',style: TextStyle(fontSize: 20),)),
                  ),
                ],
              ),
            ),)
          ],
        ),
      ),
    );
  }
  Widget _buildSelector(
      ItemModel? model, List<ItemModel> source,
      String title, double controlWith,{ bool showSearch=false, String searchTitle='', TextEditingController? searchController,
        Function(ItemModel? a)? onChange
      }) {
    return  CustomDropdownButton2(
        icon: const Icon(Icons.list),
        searchData: !showSearch  ? null:  DropdownSearchData(
          searchController: searchController,
          searchInnerWidgetHeight: 50,
          searchInnerWidget: Container(
            height: 50,
            padding: const EdgeInsets.only(
              top: 8,
              bottom: 4,
              right: 8,
              left: 8,
            ),
            child: TextFormField(
              expands: true,
              maxLines: null,
              controller: searchController,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets
                    .symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                hintText: searchTitle,
                hintStyle: const TextStyle(
                    fontSize: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                      8),
                ),
              ),
            ),
          ),
          searchMatchFn: (item, searchValue) {
            return item.value.toString()
                .toUpperCase()
                .contains(searchValue.toUpperCase());
          },
        ),
        hint: title,
        buttonWidth: controlWith,
        dropdownWidth: controlWith,
        dropdownHeight: 200,
        buttonHeight: 30,
        value: model,
        dropdownItems: source,
        onChanged: onChange);
  }
}
