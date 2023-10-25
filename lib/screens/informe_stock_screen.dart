import 'package:centyneg_sys/models/drop_item_model.dart';
import 'package:centyneg_sys/models/items_models.dart';
import 'package:centyneg_sys/providers/printing_provider.dart';
import 'package:centyneg_sys/widgets/custom_container.dart';
import 'package:centyneg_sys/widgets/loading_widget.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:search_choices/search_choices.dart';

import '../commons/Globals.dart';
import '../commons/app_color.dart';
import '../widgets/custom_dropdown_button2.dart';

class InformeStockScreen extends StatefulWidget {
  const InformeStockScreen({super.key});

  @override
  State<InformeStockScreen> createState() => _State();
}

class _State extends State<InformeStockScreen> {
  DropItemModel? producto;
  DropItemModel? marca;
  DropItemModel? familia;
  var mostrarResumen=  false;
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
     productos.add(DropdownMenuItem<DropItemModel>(
       child: Text('Todos los Productos'),
       value: DropItemModel(0,'DSADS'),
     ));
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
          'Generar Informe Stock', style: TextStyle(color: AppColor.white),),
        backgroundColor: AppColor.darkBlue,),
      body: isLoading? const LoadingWidget() : SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40,),
            Center(child: CustomContainer(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              containerWith: 500,
              containerHeight: 400,
              child: Column(
                children: [
                  const Text('Generar Informe de Stock', style: TextStyle(fontSize: 30),),
                  const SizedBox(height: 10,),
                  SizedBox(
                    width: 400,
                    child: SearchChoices<DropItemModel>.single(
                      items: productos,
                      value: producto,
                      hint: "Seleccionar un Producto",
                      searchHint: 'Buscar un producto',
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
                  const SizedBox(height: 2,),
                  SizedBox(width: 250,height: 40,child:  CheckboxListTile(value: mostrarResumen, onChanged: (a){
                    mostrarResumen=a ?? false;
                    setState(() {

                    });
                  },title: const Text('Mostrar Resumen'),),),
                  const SizedBox(height: 10,),
                  ElevatedButton.icon(onPressed: () async{
                    EasyLoading.show(status: 'Generando Reporte');
                    var result= await dio.post('/api/reportes/generar-informe-stock',data: {
                      'clientId':me['clientId'],
                      'productId':producto?.id,
                      'marcaId':marca?.id,
                      'familiaId':familia?.id,
                      'resumen': mostrarResumen,
                    });
                    var base64=result.data;
                    var printing= Provider.of<PrintingProvider>(context, listen: false);
                    EasyLoading.dismiss(animation: true);
                    printing.printPdfByBase64(base64);
                  }, icon: const Icon(Icons.print), label: const Text('Generar Informe Stock')),
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
