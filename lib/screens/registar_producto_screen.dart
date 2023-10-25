import 'package:centyneg_sys/commons/Globals.dart';
import 'package:centyneg_sys/commons/ThousandsSeparatorInputFormatter.dart';
import 'package:centyneg_sys/models/items_models.dart';
import 'package:centyneg_sys/providers/product_provider.dart';
import 'package:centyneg_sys/widgets/custom_container.dart';
import 'package:centyneg_sys/widgets/loading_widget.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../commons/app_color.dart';
import '../widgets/custom_dropdown_button2.dart';

class RegistrarProductoScreen extends StatefulWidget {
  final int productId;
  final bool edit;
  const RegistrarProductoScreen({super.key, required this.productId, required this.edit});

  @override
  State<RegistrarProductoScreen> createState() => _RegistrarProductoScreenState();
}

class _RegistrarProductoScreenState extends State<RegistrarProductoScreen> {
  late ProductProvider provider;
  var isLoading=true;
  final dio= Dio(BaseOptions(baseUrl: Globals.apiUrl));
  loadDataFromApi() async{
    await provider.loadAllAccounts();
    await provider.loadValues();
   if(widget.productId!=0){
     var apiResult= await dio.get('/api/productos/get-product-duplicate',queryParameters: {'id':widget.productId});
     var data= apiResult.data as Map;
     cuentaVenta=provider.accounts.firstWhere((element) => element.id==data['venta']['id']);
     cuentaCompra=provider.accounts.firstWhere((element) => element.id==data['compra']['id']);
     cuentaCosto=provider.accounts.firstWhere((element) => element.id==data['costo']['id']);

     familia=  !(provider.values['familia']?.any((element) => element.id==data['familia']['id']) ?? false) ? null:
     provider.values['familia']?.firstWhere((element) => element.id==data['familia']['id']);

     marca=  !(provider.values['marca']?.any((element) => element.id==data['marca']['id']) ?? false) ? null:
     provider.values['marca']?.firstWhere((element) => element.id==data['marca']['id']);

     tipo =  !(provider.values['tipo']?.any((element) => element.id==data['tipo']['id']) ?? false) ? null:
     provider.values['tipo']?.firstWhere((element) => element.id==data['tipo']['id']);

     procedencia =  !(provider.values['procedencia']?.any((element) => element.id==data['procedencia']['id']) ?? false) ? null:
     provider.values['procedencia']?.firstWhere((element) => element.id==data['procedencia']['id']);

     color =  !(provider.values['color']?.any((element) => element.id==data['color']['id']) ?? false) ? null:
     provider.values['color']?.firstWhere((element) => element.id==data['color']['id']);

     medida =  !(provider.values['unidadmedida']?.any((element) => element.id==data['medida']['id']) ?? false) ? null:
     provider.values['unidadmedida']?.firstWhere((element) => element.id==data['medida']['id']);

     iva = ivaList.firstWhere((element) => element.id==data['iva']['id']);

     nombreController.text= data['nombre'];
     codigoController.text=data['codigoBarra'];
     precio1Controller.text=data['precio1']?.toString() ?? '0';
     precio2Controller.text=data['precio2']?.toString() ?? '0';
     costoController.text=data['costoProduct']?.toString() ?? '0';
     stockController.text=data['stock']?.toString() ?? '0';
   }
    setState(() {
      isLoading=false;
    });

  }

  @override
  void initState() {
    provider=Provider.of<ProductProvider>(context,listen: false);
    loadDataFromApi();
    // TODO: implement initState
    super.initState();
  }

  var codigoController= TextEditingController(), nombreController=TextEditingController(),
      precio1Controller= TextEditingController(),
      precio2Controller= TextEditingController(),
      costoController= TextEditingController(),
      stockController= TextEditingController();
ItemModel? tipo,marca,color,procedencia,medida,familia,iva;
  ItemModel? cuentaVenta;
  ItemModel? cuentaCosto;
  ItemModel? cuentaCompra;
  var procedenciaSearchController=TextEditingController();
  var cuentaVentaSearchController=TextEditingController();
  var cuentaCompraSearchController=TextEditingController();
  var cuentaCostoSearchController=TextEditingController();
List<ItemModel> ivaList=[ItemModel(0, '0%'),ItemModel(5, '5%'),ItemModel(10, '10%')];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColor.white),
        title: Text(
          'Registrar Producto', style: TextStyle(color: AppColor.white),),
        backgroundColor: AppColor.darkBlue,),
      body: isLoading ?  LoadingWidget(): SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30,),
            Center(child: CustomContainer(
              padding: const EdgeInsets.symmetric(vertical:20,horizontal: 40),
                containerWith: 700, containerHeight: 750, child:  Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 SizedBox(
                  width: 550,
                  height: 50
                  ,
                  child: TextField(
                    controller: codigoController,
                      decoration: const InputDecoration(
                          labelText: 'CODIGO DE BARRA'),
                      style: const TextStyle(
                          color: Colors.blue
                      )),
                ),
                const SizedBox(height: 20,),
                _buildSelector(tipo, provider.values['tipo']??[], 'TIPO', 200, onChange: (a){
                  setState(() {
                    tipo=a;
                  });
                }),
                const SizedBox(height: 10,),
                _buildSelector(marca, provider.values['marca']??[], 'MARCA', 400, onChange: (a){
                  setState(() {
                    marca=a;
                  });
                }),
                const SizedBox(height: 10,),
                _buildSelector(color, provider.values['color']??[], 'COLOR', 200, onChange: (a){
                  setState(() {
                    color=a;
                  });
                }),
                const SizedBox(height: 10,),
                _buildSelector(procedencia, provider.values['procedencia']??[], 'PROCEDENCIA', 400, onChange: (a){
                  setState(() {
                    procedencia=a;
                  });
                }, searchController: procedenciaSearchController, searchTitle: 'Buscar',showSearch: true),
                const SizedBox(height: 10,),
                _buildSelector(medida, provider.values['unidadmedida']??[], 'U. MEDIDA', 200, onChange: (a){
                  setState(() {
                    medida=a;
                  });
                }),
                const SizedBox(height: 10,),
                _buildSelector(familia, provider.values['familia']??[], 'FAMILIA', 200, onChange: (a){
                  setState(() {
                    familia=a;
                  });
                }),
                const SizedBox(height: 10,),
                 SizedBox(
                  width: 550,
                  height: 50
                  ,
                  child: TextField(
                    controller: nombreController,
                      decoration: InputDecoration(
                          labelText: 'NOMBRE'),
                      style: TextStyle(
                          color: Colors.blue
                      )),
                ),
                const SizedBox(height: 10,),
                 Row(
                  children: [
                    SizedBox(
                      width: 265,
                      height: 50
                      ,
                      child: TextField(
                          inputFormatters: [ThousandsSeparatorInputFormatter()],
                        controller: precio1Controller,
                          decoration: InputDecoration(
                              labelText: 'PRECIO LISTA 1'),
                          style: TextStyle(
                              color: Colors.blue
                          )),
                    ),
                    SizedBox(width: 20,),
                    SizedBox(
                      width: 265,
                      height: 50
                      ,
                      child: TextField(
                          inputFormatters: [ThousandsSeparatorInputFormatter()],
                          controller: precio2Controller,
                          decoration: InputDecoration(
                              labelText: 'PRECIO LISTA 2'),
                          style: TextStyle(
                              color: Colors.blue
                          )),
                    ),
                  ],
                ),
                const SizedBox(height: 10,),
                 Row(
                  children: [
                    SizedBox(
                      width: 265,
                      height: 50
                      ,
                      child: TextField(
                          inputFormatters: [ThousandsSeparatorInputFormatter()],
                          controller: costoController,
                          decoration: InputDecoration(
                              labelText: 'COSTO'),
                          style: TextStyle(
                              color: Colors.blue
                          )),
                    ),
                    SizedBox(width: 20,),
                    SizedBox(
                      width: 265,
                      height: 50
                      ,
                      child: TextField(
                        inputFormatters: [ThousandsSeparatorInputFormatter()],
                          controller: stockController,
                          decoration: InputDecoration(
                              labelText: 'STOCK'),
                          style: TextStyle(
                              color: Colors.blue
                          )),
                    ),
                  ],
                ),
                const SizedBox(height: 15,),
                _buildSelector(iva, ivaList, 'IVA', 200, onChange: (a){
                  iva=a;
                  setState(() {

                  });
                }),
                const SizedBox(height: 10,),
                _buildSelector(cuentaVenta, provider.accounts, 'CUENTA VENTAS', 500,
                    showSearch: true,
                    searchController: cuentaVentaSearchController,
                    onChange: (a){
                  setState(() {
                    cuentaVenta=a;
                  });
                }),
                const SizedBox(height: 10,),
                _buildSelector(cuentaCompra,provider.accounts, 'CUENTA COMPRA', 500,
                    showSearch: true,
                    searchController: cuentaCompraSearchController,
                    onChange: (a){
                  cuentaCompra=a;
                  setState(() {

                  });
                }),
                const SizedBox(height: 10,),
                _buildSelector(cuentaCosto,provider.accounts , 'CUENTA COSTO', 500,
                    showSearch: true, searchController: cuentaCostoSearchController,
                    onChange: (a){
                  cuentaCosto=a;
                  setState(() {

                  });
                }),
                const SizedBox(height: 10,),
                SizedBox(
                  child: ElevatedButton.icon(onPressed: ()async{
                    if(iva == null){
                      Globals.showMessage('Seleccione el IVA del producto', context);
                      return;
                    }
                    if(cuentaVenta == null){
                      Globals.showMessage('Seleccione la CUENTA DE VENTA del producto', context);
                      return;
                    }
                    if(cuentaCompra == null){
                      Globals.showMessage('Seleccione la CUENTA DE COMPRA del producto', context);
                      return;
                    }
                    if(cuentaCosto == null){
                      Globals.showMessage('Seleccione la CUENTA DE COSTO del producto', context);
                      return;
                    }
                    var result= await provider.registrarProducto({
                      'id': widget.edit ? widget.productId: 0,
                      'clientId':0,
                      'codigoBarra': codigoController.text,
                      'tipoId':tipo?.id,
                      'marcaId':marca?.id,
                      'colorId':color?.id,
                      'procedenciaId':procedencia?.id,
                      'medidaId':medida?.id,
                      'familiaId':familia?.id,
                      'nombre':nombreController.text,
                      'precio1':double.tryParse(precio1Controller.text.replaceAll('.', ''))  ?? 0,
                      'precio2':double.tryParse(precio2Controller.text.replaceAll('.', ''))  ?? 0,
                      'costo':double.tryParse(costoController.text.replaceAll('.', ''))  ?? 0,
                      'stock':double.tryParse(stockController.text.replaceAll('.', ''))  ?? 0,
                      'iva': iva?.id,
                      'cuentaVentaId': cuentaVenta?.id,
                      'cuentaCompraId': cuentaCompra?.id,
                      'cuentaCostoId': cuentaCosto?.id,
                    });
                    if(result)
                      clear();
                  }, icon: Icon(Icons.save), label: Text('Guardar Producto')),
                )
              ],
            )))
          ],
        ),
      ),
    );
  }
void clear(){
    tipo=null;
    marca=null;
    procedencia=null;
    color=null;
    medida=null;
    familia=null;
    cuentaVenta=null;
    cuentaCompra=null;
    cuentaCosto=null;
    codigoController.clear();
    nombreController.clear();
    precio1Controller.clear();
    precio2Controller.clear();
    stockController.clear();
    costoController.clear();
    setState(() {

    });
}
  Widget _buildSelector(
      ItemModel? model, List<ItemModel> source,
      String title, double controlWith,{ bool showSearch=false, String searchTitle='', TextEditingController? searchController,
      Function(ItemModel? a)? onChange
      }) {
    return  CustomDropdownButton2(
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
