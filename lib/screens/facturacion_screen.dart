import 'dart:js_interop';

import 'package:centyneg_sys/commons/Globals.dart';
import 'package:centyneg_sys/providers/facturacion_provider.dart';
import 'package:centyneg_sys/providers/printing_provider.dart';
import 'package:centyneg_sys/providers/product_provider.dart';
import 'package:centyneg_sys/providers/sys_data_provider.dart';
import 'package:centyneg_sys/widgets/custom_container.dart';
import 'package:centyneg_sys/widgets/loading_widget.dart';
import 'package:date_field/date_field.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:empty_widget/empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';

import '../commons/app_color.dart';
import '../models/items_models.dart';
import '../widgets/custom_dropdown_button2.dart';

class FacturacionScreen extends StatefulWidget {
  const FacturacionScreen({super.key});

  @override
  State<FacturacionScreen> createState() => _FacturacionScreenState();
}

class _FacturacionScreenState extends State<FacturacionScreen> {
  DateTime fecha=DateTime.now();
  ItemsClientModel? cliente;

      ItemModel? tipoPago, tipoDocumento, caja;
  var rucController= TextEditingController();
  var facturaController= TextEditingController();
  var condicionController= TextEditingController();
  var timbradoController= TextEditingController();
  var searchClienteController= TextEditingController();
  var productController= TextEditingController();
  List<ItemModel> comprobantes= [ItemModel(288, 'FACTURA LEGAL DUPLICADO'),
    ItemModel(289, 'AUTOIMPRESOR TICKET'),
    ItemModel(4059, 'AUTOIMPRESOR DUPLICADO'),
    ItemModel(1157, 'FACTURA LEGAL TRIPLICADO'),
    ItemModel(4058, 'CONTROL INTERNO'),];
  List<ItemModel> tipoDePagos=[];
  late PlutoGridStateManager stateManagerDatos;
  double total=0;
  final dio= Dio(BaseOptions(baseUrl: Globals.apiUrl));
  var isLoading= true;
  var me={};
  var storage= LocalStorage(Globals.dataFileKeyName);
  @override
  void initState() {
    // TODO: implement initState
    loadDataFromApi();
    super.initState();
  }
  loadDataFromApi() async{
    me= await Globals.getMe();
    var resultTipoFacturas= await dio.get('/api/modules/get-documentos-impresion-by-client'
    ,queryParameters: {
      'id':me['clientId']
        }
    );
    comprobantes= (resultTipoFacturas.data as List)
    .map((e) => ItemModel(e['id'], e['name'])).toList();
    var pagosFecht= await dio.get('/api/typeofpayments/get-all',queryParameters: {
      'tipoId':7,
      'clientId': me['clientId']
    });
    tipoDePagos= (pagosFecht.data as List).map((e) => ItemModel(e['id'], e['name'])).toList();
    await refreshCajaDataFromApi();
    await loadProductsFromApi();
    setState(() {
      isLoading=false;
    });
  }
  refreshCajaDataFromApi() async{

    var id= storage.getItem('caja');
    var fechtCaja= await dio.get('/api/cajas/get-caja',queryParameters: {
      'id':id
    });
   var data= fechtCaja.data as Map;
   facturaController.text=data['numero'];
   timbradoController.text=data['timbrado'];
  }
  var products=[];
 loadProductsFromApi({String pattern='pattern'}) async{
    var data=await dio.get('/api/productos/get-all-products', queryParameters: {
      'clientId':me['clientId'],
      'pattern':pattern
    });
    products= data.data as List;
  }
  @override
  Widget build(BuildContext context) {
    var dataProvider = Provider.of<SysDataProvider>(context);
    var productProvider = Provider.of<ProductProvider>(context);
    var factProvider = Provider.of<FacturacionProvider>(context);
    caja = ItemModel(factProvider.caja['id'] ?? 0, '');
    var size= MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColor.white),
        title: Text(
          'Generar Venta - Factura', style: TextStyle(color: AppColor.white),),
        backgroundColor: AppColor.darkBlue,),
      body: isLoading ? const LoadingWidget() : SingleChildScrollView(
        child: storage.getItem('screen') == 1 ?
        Column(
          children: [
            const SizedBox(height: 30,),
            CustomContainer(
                padding: const EdgeInsets.symmetric(
                    vertical: 10, horizontal: 20),
                containerWith: size.width , containerHeight: 1000, child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 20,),
                SizedBox(
                  width: 200,
                  height: 50
                  ,
                  child: TextField(
                      readOnly: true,
                      controller: facturaController,
                      decoration: const InputDecoration(
                          labelText: 'Nº FACTURA'),
                      style: const TextStyle(
                          color: Colors.blue
                      )),
                ),
                const SizedBox(height: 5,),
                SizedBox(
                  width: 300,
                  height: 50
                  ,
                  child: TextField(
                      controller: rucController,
                      decoration: const InputDecoration(
                          labelText: 'R.U.C'),
                      style: const TextStyle(
                          color: Colors.blue
                      )),
                ),
                const SizedBox(height: 10,),
                Flexible(child: Container(
                  width: 500,
                  height: 80,
                  child: TypeAheadField(
                    textFieldConfiguration:  TextFieldConfiguration(
                        autofocus: true,
                        controller: searchClienteController,
                        style: const TextStyle(fontSize: 16),
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Buscar un Cliente'
                        )
                    ),
                    suggestionsCallback: (pattern) async {
                      return await dataProvider.entitiesBackSearch(pattern);
                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        leading: const Icon(Icons.supervised_user_circle_sharp),
                        title: Text(suggestion['fullName']),
                        subtitle: Text('R.U.C ${suggestion['ruc']}'),
                      );
                    },
                    onSuggestionSelected: (suggestion) async {
                      cliente= await dataProvider.getEntidad(suggestion['id']);
                      if(cliente != null){
                        rucController.text=cliente?.ruc ?? '';
                        searchClienteController.text=cliente?.title ?? '';
                      }
                    },
                    hideSuggestionsOnKeyboardHide: false,
                    hideOnError: true,
                    animationDuration: const Duration(seconds: 1),

                    noItemsFoundBuilder: (_)=> Container(
                        width: 200,
                        height: 300,
                        child: Column(
                          children: [
                            Container(
                              width: 400,
                              height: 230,
                              child: EmptyWidget(
                                image: null,
                                packageImage: PackageImage.Image_1,
                                title: 'No existe el cliente',
                                subTitle: 'Parece que el cliente que buscas no existe,',
                                titleTextStyle: const TextStyle(
                                  fontSize: 22,
                                  color: Color(0xff9da9c7),
                                  fontWeight: FontWeight.w500,
                                ),
                                subtitleTextStyle: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xffabb8d6),
                                ),
                                hideBackgroundAnimation: false,
                              ),
                            ),

                            const SizedBox(height: 10,),
                            Row(
                              children: [
                                const Text("Egregar Cliente", style: TextStyle(fontSize: 20),),
                                InkWell(child: const Icon(Icons.add,color: Colors.green, size: 35,), onTap: (){
                                  context.go('/registrar_cliente');
                                },)
                              ],
                            )
                          ],
                        )
                    ),
                  ),
                )),
                const SizedBox(height: 5,),
                SizedBox(
                    width: 400,
                    height: 50,
                    child: DateTimeFormField(
                      dateFormat: DateFormat('dd/MM/yyyy'),
                      initialValue: fecha,
                      decoration: const InputDecoration(
                        hintStyle: TextStyle(color: Colors.black45),
                        errorStyle: TextStyle(color: Colors.redAccent),
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.event_note),
                        labelText: 'Fecha de Documento',
                      ),
                      mode: DateTimeFieldPickerMode.date,
                      autovalidateMode: AutovalidateMode.always,
                      onDateSelected: (DateTime value) {
                        fecha=value;
                      },
                    )
                ),
                const SizedBox(height: 5,),
                Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: _buildSelector(
                        tipoPago, tipoDePagos,
                        'TIPO DE PAGO', 500, onChange: (a) async {
                      tipoPago = a;
                      if (tipoPago != null) {
                        var data = await factProvider.getTipoPago(
                            tipoPago?.id ?? 0);
                        condicionController.text = data['tipo'];
                      }
                      setState(() {

                      });
                    })),
                Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: _buildSelector(tipoDocumento, comprobantes,
                        'TIPO DE COMPROBANTE', 500, onChange: (a) {
                          tipoDocumento = a;
                          setState(() {

                          });
                        })),
                const SizedBox(height: 10,),
                Container(
                  width: 800,
                  height: 50,
                  child: TypeAheadField(
                    textFieldConfiguration:  TextFieldConfiguration(
                        autofocus: true,
                        controller: productController,
                        style: const TextStyle(fontSize: 20, color: Colors.blueGrey),
                        decoration: const InputDecoration(
                            icon: Icon(Icons.qr_code_rounded),
                            border: OutlineInputBorder(),
                            hintText: 'Ingrese el Nombre o Codigo de Barra'
                        )
                    ),
                    suggestionsCallback: (pattern) async {
                      var fecth= await dio.get('/api/productos/get-all-products',queryParameters: {
                        'clientId':me['clientId'],
                        'pattern':pattern
                      });
                      return fecth.data as List;
                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        leading: const Icon(Icons.sell),
                        title: Text(suggestion['nombre']),
                        subtitle: Text('Codigo de Barra ${suggestion['codigoBarra']}'),
                      );
                    },
                    onSuggestionSelected: (suggestion) async {
                      productController.clear();
                      var product= await productProvider.getProduct(suggestion['id']);
                      var index= stateManagerDatos.refRows.length ;
                      stateManagerDatos.insertRows(index, [
                        PlutoRow(cells: {
                          'id': PlutoCell(value: product['id']),
                          'producto': PlutoCell(value: product['name']),
                          'cantidad': PlutoCell(value: product['cant']),
                          'precio': PlutoCell(value: product['price']),
                          'total': PlutoCell(value: product['tot']),
                          'iva': PlutoCell(value: product['iva']),
                        }),
                      ]);
                      updateTotal();
                    },
                    hideSuggestionsOnKeyboardHide: false,
                    hideOnError: true,
                    animationDuration: const Duration(seconds: 1),
                  ),
                ),
                const SizedBox(height: 10,),
                Container(
                  width: 1000,
                  height: 450,
                  child: PlutoGrid(
                    onLoaded: (PlutoGridOnLoadedEvent event) =>
                    stateManagerDatos = event.stateManager,
                    configuration: const PlutoGridConfiguration(
                      style: PlutoGridStyleConfig(
                        cellTextStyle: TextStyle(fontSize: 12),
                        columnTextStyle: TextStyle(fontSize: 12),
                        columnHeight: 30,
                        rowHeight: 30,
                      ),
                      enterKeyAction: PlutoGridEnterKeyAction.toggleEditing,

                    ),
                    columns: [
                      PlutoColumn(title: 'ID',
                          field: 'id',
                          type: PlutoColumnType.number(),
                          width: 0),
                      PlutoColumn(
                        suppressedAutoSize: true,
                        title: 'PRODUCTO (DESCRIPCION)',
                        field: 'producto',
                        type: PlutoColumnType.text(),
                        width: 400,
                        renderer: (rendererContext) {
                          return Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.remove_circle_outlined,
                                ),
                                onPressed: () {
                                  if (rendererContext.stateManager.refRows
                                      .length == 1)
                                    return;
                                  rendererContext.stateManager
                                      .removeRows([rendererContext.row]);
                                  updateTotal();
                                },
                                iconSize: 18,
                                color: Colors.red,
                                padding: const EdgeInsets.all(0),
                              ),
                              Expanded(
                                child: Text(
                                  rendererContext.row.cells[rendererContext
                                      .column.field]!.value
                                      .toString(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      PlutoColumn(title: 'CANTIDAD',
                          field: 'cantidad',
                          type: PlutoColumnType.number(),
                          width: 150),
                      PlutoColumn(title: 'PRECIO',
                          field: 'precio',
                          type: PlutoColumnType.currency(
                              symbol: Globals.symbol, decimalDigits: 0),
                          width: 150),
                      PlutoColumn(title: 'TOTAL',
                          field: 'total',
                          type: PlutoColumnType.currency(
                              symbol: Globals.symbol, decimalDigits: 0),
                          width: 150),
                      PlutoColumn(title: 'IVA',
                          field: 'iva',
                          type: PlutoColumnType.currency(
                              symbol: '%', decimalDigits: 0),
                          width: 150,
                          readOnly: true),
                    ],
                    rows: [
                    ],
                    onChanged: (a){
                      if(a.columnIdx==2){
                        a.row.cells['total']?.value=a.row.cells['precio']?.value *a.row.cells['cantidad']?.value;
                        updateTotal();
                      } else if(a.columnIdx==3){
                        a.row.cells['total']?.value=a.row.cells['precio']?.value *a.row.cells['cantidad']?.value;
                        updateTotal();
                      }
                    },
                  ),
                ),
                const SizedBox(height: 10,),
                Container(
                  width: 1000,
                  height: 120,
                  child: Stack(
                    children: [
                      Positioned(
                          top: 80,
                          right: 2,
                          child: Text('Total ${Globals.symbol}${Globals
                              .formatNumberToLocate(total)}',
                            style: const TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold),)),
                      Positioned(
                          top: 50,
                          left: 2,
                          child: ElevatedButton.icon(onPressed: () async {
                            if (tipoPago == null) {
                              Globals.showMessage(
                                  'Seleccione un tipo de Pago', context);
                              return;
                            }
                            if (tipoDocumento == null) {
                              Globals.showMessage(
                                  'Seleccione un tipo de Documento', context);
                              return;
                            }
                            if (cliente == null) {
                              Globals.showMessage(
                                  'Seleccione el Cliente', context);
                              return;
                            }
                            if (caja == null) {
                              Globals.showMessage(
                                  'Seleccione la Caja', context);
                              return;
                            }
                            var items = stateManagerDatos.refRows.map((
                                element) =>
                            {
                              'productoId': element.cells['id']?.value ?? 0,
                              'precio': element.cells['precio']?.value ?? 0,
                              'cantidad': element.cells['cantidad']?.value ??
                                  0,
                              'descuento': 0,
                              'iva': element.cells['iva']?.value ?? 0,
                            }).toList();
                            var body = {
                              'sucursalId': storage.getItem('sucursal'),
                              'fecha': fecha.toIso8601String(),
                              'clientId': 0,
                              'userId': 0,
                              'periodo': Globals.periodo,
                              'tipoDocId': tipoDocumento?.id,
                              'entidadId': cliente?.id,
                              'cajaId': storage.getItem('caja'),
                              'numeroDoc': facturaController.text,
                              'TipoPagoId': tipoPago?.id,
                              'detalles': items
                            };
                            var result = await factProvider.registrarFactura(
                                body);
                            await limpiar();
                            var printProvider = Provider.of<PrintingProvider>(context,listen: false);
                            if (result.isNotEmpty) {
                              await printProvider.printPdfByBase64(result);
                            }
                          },
                              icon: const Icon(Icons.save),
                              label: const Text('Guardar Factura'))),
                      Positioned(
                          top: 5,
                          left: 2,
                          child: ElevatedButton.icon(onPressed: () async {
                            await limpiar();
                          },
                              icon: const Icon(Icons.cleaning_services_rounded),
                              label: const Text('Cancelar Operación')))
                    ],
                  ),
                )
              ],))
          ],
        )
            :

        Column(
          children: [
            const SizedBox(height: 30,),
            Center(
            child: CustomContainer(
                padding: const EdgeInsets.symmetric(
                    vertical: 10, horizontal: 20),
                containerWith: size.width * 0.50, containerHeight: 1000, child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 20,),
                    SizedBox(
                      width: 400,
                      height: 50
                      ,
                      child: TextField(
                        readOnly: true,
                          controller: facturaController,
                          decoration: const InputDecoration(
                              labelText: 'Nº FACTURA'),
                          style: const TextStyle(
                              color: Colors.blue
                          )),
                    ),
                    const SizedBox(width: 20,),
                    SizedBox(
                      width: 150,
                      height: 50
                      ,
                      child: TextField(
                          controller: rucController,
                          decoration: const InputDecoration(
                              labelText: 'R.U.C'),
                          style: const TextStyle(
                              color: Colors.blue
                          )),
                    ),
                    const SizedBox(width: 20,),
                    SizedBox(
                      width: 150,
                      height: 50
                      ,
                      child: TextField(
                        readOnly: true,
                          controller: timbradoController,
                          decoration: const InputDecoration(
                              labelText: 'TIMBRADO'),
                          style: const TextStyle(
                              color: Colors.blue
                          )),
                    ),
                  ],
                ),
                const SizedBox(height: 20,),
                Row(
                  children: [
                    Flexible(child: Container(
                      width: 500,
                      height: 60,
                      child: TypeAheadField(
                        textFieldConfiguration:  TextFieldConfiguration(
                            autofocus: true,
                            controller: searchClienteController,
                            style: const TextStyle(fontSize: 16),
                            decoration: const InputDecoration(
                              icon: Icon(Icons.account_circle_outlined),
                                border: OutlineInputBorder(),
                              hintText: 'Buscar un Cliente'
                            )
                        ),
                        suggestionsCallback: (pattern) async {
                          return await dataProvider.entitiesBackSearch(pattern);
                        },
                        itemBuilder: (context, suggestion) {
                          return ListTile(
                            leading: const Icon(Icons.supervised_user_circle_sharp),
                            title: Text(suggestion['fullName']),
                            subtitle: Text('R.U.C ${suggestion['ruc']}'),
                          );
                        },
                        onSuggestionSelected: (suggestion) async {
                          cliente= await dataProvider.getEntidad(suggestion['id']);
                          if(cliente != null){
                            rucController.text=cliente?.ruc ?? '';
                            searchClienteController.text=cliente?.title ?? '';
                          }
                        },
                        hideSuggestionsOnKeyboardHide: false,
                        hideOnError: true,
                        animationDuration: const Duration(seconds: 1),

                        noItemsFoundBuilder: (_)=> Container(
                            width: 500,
                            height: 300,
                            child: Column(
                              children: [
                                Container(
                                  width: 400,
                                  height: 230,
                                  child: EmptyWidget(
                                    image: null,
                                    packageImage: PackageImage.Image_1,
                                    title: 'No existe el cliente',
                                    subTitle: 'Parece que el cliente que buscas no existe, no que no, Edgar? :(',
                                    titleTextStyle: const TextStyle(
                                      fontSize: 22,
                                      color: Color(0xff9da9c7),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    subtitleTextStyle: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xffabb8d6),
                                    ),
                                    hideBackgroundAnimation: false,
                                  ),
                                ),

                                const SizedBox(height: 10,),
                                Row(
                                  children: [
                                    const Text("Para agregar el cliente, clic en el icono", style: TextStyle(fontSize: 20),),
                                    InkWell(child: const Icon(Icons.add,color: Colors.green, size: 35,), onTap: (){
                                      context.go('/registrar_cliente');
                                    },)
                                  ],
                                )
                              ],
                            )
                        ),
                      ),
                    )),
                    const SizedBox(width: 20,),
                    SizedBox(
                        width: 200,
                        height: 50,
                        child: DateTimeFormField(
                          dateFormat: DateFormat('dd/MM/yyyy'),
                          initialValue: fecha,
                          decoration: const InputDecoration(
                            hintStyle: TextStyle(color: Colors.black45),
                            errorStyle: TextStyle(color: Colors.redAccent),
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.event_note),
                            labelText: 'Fecha de Documento',
                          ),
                          mode: DateTimeFieldPickerMode.date,
                          autovalidateMode: AutovalidateMode.always,
                          onDateSelected: (DateTime value) {
                            fecha=value;
                          },
                        )
                    )
                  ],
                ),
                const SizedBox(height: 5,),
                Row(
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: _buildSelector(
                            tipoPago, tipoDePagos,
                            'TIPO DE PAGO', 300, onChange: (a) async {
                          tipoPago = a;
                          if (tipoPago != null) {
                            var data = await factProvider.getTipoPago(
                                tipoPago?.id ?? 0);
                            condicionController.text = data['tipo'];
                          }
                          setState(() {

                          });
                        })),
                    const SizedBox(width: 20,),
                    Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: _buildSelector(tipoDocumento, comprobantes,
                            'TIPO DE COMPROBANTE', 300, onChange: (a) {
                              tipoDocumento = a;
                              setState(() {

                              });
                            })),
                    const SizedBox(width: 20,),
                    SizedBox(
                      width: 170,
                      height: 50
                      ,
                      child: TextField(
                          controller: condicionController,
                          decoration: const InputDecoration(
                              labelText: 'CONDICION DE PAGO'),
                          style: const TextStyle(
                              color: Colors.blue
                          )),
                    ),
                  ],
                ),
              const SizedBox(height: 10,),
              Container(
                width: 800,
                height: 50,
                child: TypeAheadField(
                  textFieldConfiguration:  TextFieldConfiguration(
                      autofocus: true,
                      controller: productController,
                      style: const TextStyle(fontSize: 20, color: Colors.blueGrey),
                      decoration: const InputDecoration(
                          icon: Icon(Icons.qr_code_rounded),
                          border: OutlineInputBorder(),
                          hintText: 'Ingrese el Nombre o Codigo de Barra'
                      )
                  ),
                  suggestionsCallback: (pattern) async {
                    var fecth= await dio.get('/api/productos/get-all-products',queryParameters: {
                      'clientId':me['clientId'],
                      'pattern':pattern
                    });
                    return fecth.data as List;
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      leading: const Icon(Icons.sell),
                      title: Text(suggestion['nombre']),
                      subtitle: Text('Codigo de Barra ${suggestion['codigoBarra']}'),
                    );
                  },
                  onSuggestionSelected: (suggestion) async {
                    productController.clear();
                    var product= await productProvider.getProduct(suggestion['id']);
                    var index= stateManagerDatos.refRows.length ;
                    stateManagerDatos.insertRows(index, [
                      PlutoRow(cells: {
                        'id': PlutoCell(value: product['id']),
                        'producto': PlutoCell(value: product['name']),
                        'cantidad': PlutoCell(value: product['cant']),
                        'precio': PlutoCell(value: product['price']),
                        'total': PlutoCell(value: product['tot']),
                        'iva': PlutoCell(value: product['iva']),
                      }),
                    ]);
                    updateTotal();
                  },
                  hideSuggestionsOnKeyboardHide: false,
                  hideOnError: true,
                  animationDuration: const Duration(seconds: 1),
                ),
              ),
                const SizedBox(height: 10,),
                Container(
                  width: 1000,
                  height: 450,
                  child: PlutoGrid(
                    onLoaded: (PlutoGridOnLoadedEvent event) =>
                    stateManagerDatos = event.stateManager,
                    configuration: const PlutoGridConfiguration(
                      style: PlutoGridStyleConfig(
                        cellTextStyle: TextStyle(fontSize: 12),
                        columnTextStyle: TextStyle(fontSize: 12),
                        columnHeight: 30,
                        rowHeight: 30,
                      ),
                      enterKeyAction: PlutoGridEnterKeyAction.toggleEditing,

                    ),
                    columns: [
                      PlutoColumn(title: 'ID',
                          field: 'id',
                          type: PlutoColumnType.number(),
                          width: 0),
                      PlutoColumn(
                        suppressedAutoSize: true,
                        title: 'PRODUCTO (DESCRIPCION)',
                        field: 'producto',
                        type: PlutoColumnType.text(),
                        width: 400,
                        renderer: (rendererContext) {
                          return Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.remove_circle_outlined,
                                ),
                                onPressed: () {
                                  if (rendererContext.stateManager.refRows
                                      .length == 1)
                                    return;
                                  rendererContext.stateManager
                                      .removeRows([rendererContext.row]);
                                  updateTotal();
                                },
                                iconSize: 18,
                                color: Colors.red,
                                padding: const EdgeInsets.all(0),
                              ),
                              Expanded(
                                child: Text(
                                  rendererContext.row.cells[rendererContext
                                      .column.field]!.value
                                      .toString(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      PlutoColumn(title: 'CANTIDAD',
                          field: 'cantidad',
                          type: PlutoColumnType.number(),
                          width: 150),
                      PlutoColumn(title: 'PRECIO',
                          field: 'precio',
                          type: PlutoColumnType.currency(
                              symbol: Globals.symbol, decimalDigits: 0),
                          width: 150),
                      PlutoColumn(title: 'TOTAL',
                          field: 'total',
                          type: PlutoColumnType.currency(
                              symbol: Globals.symbol, decimalDigits: 0),
                          width: 150),
                      PlutoColumn(title: 'IVA',
                          field: 'iva',
                          type: PlutoColumnType.currency(
                              symbol: '%', decimalDigits: 0),
                          width: 150,
                          readOnly: true),
                    ],
                    rows: [
                    ],
                    onChanged: (a){
                      if(a.columnIdx==2){
                        a.row.cells['total']?.value=a.row.cells['precio']?.value *a.row.cells['cantidad']?.value;
                        updateTotal();
                      } else if(a.columnIdx==3){
                        a.row.cells['total']?.value=a.row.cells['precio']?.value *a.row.cells['cantidad']?.value;
                        updateTotal();
                      }
                    },
                  ),
                ),
                const SizedBox(height: 10,),
                Container(
                  width: 1000,
                  height: 120,
                  child: Stack(
                    children: [
                      Positioned(
                          top: 10,
                          right: 2,
                          child: Text('Total ${Globals.symbol}${Globals
                              .formatNumberToLocate(total)}',
                            style: const TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold),)),
                      Positioned(
                          top: 10,
                          left: 2,
                          child: ElevatedButton.icon(onPressed: () async {
                            if (tipoPago == null) {
                              Globals.showMessage(
                                  'Seleccione un tipo de Pago', context);
                              return;
                            }
                            if (tipoDocumento == null) {
                              Globals.showMessage(
                                  'Seleccione un tipo de Documento', context);
                              return;
                            }
                            if (cliente == null) {
                              Globals.showMessage(
                                  'Seleccione el Cliente', context);
                              return;
                            }
                            if (caja == null) {
                              Globals.showMessage(
                                  'Seleccione la Caja', context);
                              return;
                            }
                            var items = stateManagerDatos.refRows.map((
                                element) =>
                            {
                              'productoId': element.cells['id']?.value ?? 0,
                              'precio': element.cells['precio']?.value ?? 0,
                              'cantidad': element.cells['cantidad']?.value ??
                                  0,
                              'descuento': 0,
                              'iva': element.cells['iva']?.value ?? 0,
                            }).toList();
                            var body = {
                              'sucursalId': storage.getItem('sucursal'),
                              'fecha': fecha.toIso8601String(),
                              'clientId': 0,
                              'userId': 0,
                              'periodo': Globals.periodo,
                              'tipoDocId': tipoDocumento?.id,
                              'entidadId': cliente?.id,
                              'cajaId': storage.getItem('caja'),
                              'numeroDoc': facturaController.text,
                              'TipoPagoId': tipoPago?.id,
                              'detalles': items
                            };
                            var result = await factProvider.registrarFactura(
                                body);
                            await limpiar();
                            var printProvider = Provider.of<PrintingProvider>(context, listen: false);
                            if (result.isNotEmpty) {
                              await printProvider.printPdfByBase64(result);
                            }
                          },
                              icon: const Icon(Icons.save),
                              label: const Text('Guardar Factura'))),
                      Positioned(
                          top: 10,
                          left: 200,
                          child: ElevatedButton.icon(onPressed: () async {
                            await limpiar();
                          },
                              icon: const Icon(Icons.cleaning_services_rounded),
                              label: const Text('Cancelar Operación')))
                    ],
                  ),
                )
              ],)),
              )
          ],
        ),
      ),
    );
  }
   limpiar() async{
    tipoPago=null;
    tipoDocumento=null;
    cliente=null;
    rucController.clear();
    condicionController.clear();
    stateManagerDatos.refRows.clear();
    searchClienteController.clear();
    fecha=DateTime.now();
    await refreshCajaDataFromApi();
    setState(() {

    });
    updateTotal();
  }
  void updateTotal(){
if(stateManagerDatos.refRows.isEmpty){
  total=0;
  return;
}
    total= stateManagerDatos.refRows
        .map((element) => element.cells['total']?.value)
        .reduce((previousValue, element) => previousValue + element );
    setState(() {

    });
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
