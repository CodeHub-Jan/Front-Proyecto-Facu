import 'dart:js_interop';

import 'package:centyneg_sys/commons/Globals.dart';
import 'package:centyneg_sys/providers/facturacion_provider.dart';
import 'package:centyneg_sys/providers/product_provider.dart';
import 'package:centyneg_sys/providers/sys_data_provider.dart';
import 'package:centyneg_sys/widgets/custom_container.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';

import '../commons/app_color.dart';
import '../models/items_models.dart';
import '../widgets/custom_dropdown_button2.dart';

class CompraScreen extends StatefulWidget {
  final int pedido;
  const CompraScreen({super.key, required this.pedido});

  @override
  State<CompraScreen> createState() => _CompraScreenState();
}

class _CompraScreenState extends State<CompraScreen> {
  DateTime fecha=DateTime.now();
  ItemModel? cliente, tipoPago;
  var rucController= TextEditingController();
  var facturaController= TextEditingController(text: '001-001-');
  var condicionController= TextEditingController();
  var timbradoController= TextEditingController();
  late PlutoGridStateManager stateManagerDatos;
  late PlutoGridStateManager stateManagerPagos;
  double total=0;

  var storage = LocalStorage(Globals.dataFileKeyName);
  @override
  Widget build(BuildContext context) {
    var dataProvider= Provider.of<SysDataProvider>(context);
    var productProvider= Provider.of<ProductProvider>(context);
    var factProvider= Provider.of<FacturacionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColor.white),
        title: Text(
          'Registrar Compra', style: TextStyle(color: AppColor.white),),
        backgroundColor: AppColor.darkBlue,),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30,),
            Center(
              child: CustomContainer(
color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 20),
                  containerWith: 1000, containerHeight: 900, child:  Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Row(
                children: [
                  if(widget.pedido==1)...[
                    const SizedBox(width: 20,),
                    SizedBox(
                      width: 450,
                      height: 50
                      ,
                      child: TextField(
                          controller: facturaController,
                          decoration: InputDecoration(
                              labelText: 'Nº FACTURA'),
                          style: TextStyle(
                              color: Colors.blue
                          )),
                    ),
                  ],
                  const SizedBox(width: 20,),
                   SizedBox(
                    width: 150,
                    height: 50
                    ,
                    child: TextField(
                        controller: rucController,
                        decoration: InputDecoration(
                            labelText: 'R.U.C'),
                        style: TextStyle(
                            color: Colors.blue
                        )),
                  ),
          if(widget.pedido==1)...[
            const SizedBox(width: 20,),
            SizedBox(
              width: 150,
              height: 50
              ,
              child: TextField(
                  controller: timbradoController,
                  decoration: InputDecoration(
                      labelText: 'TIMBRADO'),
                  style: TextStyle(
                      color: Colors.blue
                  )),
            ),
          ]

                ],
              ),
               const SizedBox(height: 20,),
                  Row(
                    children: [
                      _buildSelector(cliente, dataProvider.clients2, 'SELECCIONAR PROVEEDOR', 500,
                      onChange: (a) async{
                        cliente=a;
                        if(cliente !=null)
                          {
                            var temp= await factProvider.getClient(cliente?.id ?? 0);
                            rucController.text= '${temp['ruc']} - ${temp['dv']}';
                          }
                        setState(() {

                      });}),
                      const SizedBox(width: 20,),
                      SizedBox(
                          width: 250,
                          height: 50,
                          child: DropdownButton<DateTime>(
                              hint: const Text('Seleccionar Fecha'),
                              items: [
                                DateFormat('dd/MM/yyyy').format(
                                    fecha)
                              ]
                                  .map((e) =>
                                  DropdownMenuItem<DateTime>(child: Text(e)))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2001),
                                      lastDate: DateTime(2099))
                                      .then((date) {
                                    setState(() {
                                      fecha = date!;
                                    });
                                  });
                                });
                              })
                      )
                    ],
                  ),
                  const SizedBox(height: 10,),
                  SizedBox(height: 10,),
                  Container(
                    width: 1000,
                    height: 300,
                    child: PlutoGrid(
                      onChanged: (PlutoGridOnChangedEvent event) async {
                        var data= stateManagerDatos.getRowByIdx(event.rowIdx);
                        if(event.columnIdx==0){
                          var select= data?.cells['producto']?.value as ItemModel;
                          var product= await productProvider.getProduct(select.id);
                          data?.cells['precio']?.value=product['costo'];
                          data?.cells['iva']?.value=product['iva'];
                        }
                        data?.cells['total']?.value=data.cells['precio']?.value * data.cells['cantidad']?.value;
                        updateTotal();
                      },
                      onLoaded: (PlutoGridOnLoadedEvent event) => stateManagerDatos = event.stateManager,
                      configuration: const PlutoGridConfiguration(
                        style: PlutoGridStyleConfig(
                          cellTextStyle: TextStyle(fontSize: 12, color: Colors.redAccent),
                          columnTextStyle: TextStyle(fontSize: 12),
                          columnHeight: 30,
                          rowHeight: 30,
                        ),
                        enterKeyAction: PlutoGridEnterKeyAction.toggleEditing,

                      ),
                      columns: [
                        PlutoColumn(
                         suppressedAutoSize: true ,
                          title: 'PRODUCTO (SELECCIONAR)', field: 'producto',
                          type: PlutoColumnType.select(productProvider.products
                        .map((e) => ItemModel(e['id'], '${e['nombre']} - ${e['codigoBarra']}')).toList(), enableColumnFilter: true,
                            popupIcon: Icons.search
                        ), width: 400,
                          renderer: (rendererContext) {
                            return Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.add_circle,
                                  ),
                                  onPressed: () {
                                    rendererContext.stateManager.insertRows(
                                        rendererContext.rowIdx,[PlutoRow(cells: {
                                      'producto' : PlutoCell(value: ItemModel(0,'')),
                                      'cantidad': PlutoCell(value: 1),
                                      'precio': PlutoCell(value: 0),
                                      'total': PlutoCell(value: 0),
                                      'iva': PlutoCell(value: 0),
                                    })]
                                    );
                                  },
                                  iconSize: 18,
                                  color: Colors.green,
                                  padding: const EdgeInsets.all(0),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove_circle_outlined,
                                  ),
                                  onPressed: () {
                                    if(rendererContext.stateManager.refRows.length==1)
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
                                    rendererContext.row.cells[rendererContext.column.field]!.value
                                        .toString(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        PlutoColumn(title: 'CANTIDAD', field: 'cantidad', type: PlutoColumnType.number(), width: 150),
                        PlutoColumn(title: 'PRECIO', field: 'precio', type: PlutoColumnType.currency(symbol: Globals.symbol, decimalDigits: 0), width: 150),
                        PlutoColumn(title: 'TOTAL', field: 'total', type: PlutoColumnType.currency(symbol: Globals.symbol, decimalDigits: 0), width: 150),
                        PlutoColumn(title: 'IVA', field: 'iva', type: PlutoColumnType.currency(symbol: '%', decimalDigits: 0), width: 150),
                      ],
                      rows: [PlutoRow(cells: {
                        'producto' : PlutoCell(value: ItemModel(0,'')),
                        'cantidad': PlutoCell(value: 1),
                        'precio': PlutoCell(value: 0),
                        'total': PlutoCell(value: 0),
                        'iva': PlutoCell(value: 0),
                      })],
                    ),
                  ),
                  Container(
                    width: 1000,
                    height: 300,
                    child: Stack(
                      children: [
                        Positioned(
                          top: 10,
                            right:2,
                            child: Text('Total ${Globals.symbol}${Globals.formatNumberToLocate(total)}',style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),)),
                        Positioned(
                            top: 10,
                            left:2,
                            child: ElevatedButton.icon(onPressed: () async{
                              if(cliente == null){
                                Globals.showMessage('Seleccione el Cliente', context);
                                return;
                              }
                              if(stateManagerPagos.refRows.length==0){
                                Globals.showMessage('Cargue al menos un tipo de pago !', context);
                                return;
                              }
                              var pagos= stateManagerPagos.refRows
                                  .map((e) => {
                                'tipoPagoId': e.cells['tipo']?.value.id,
                                'bancoId': (e.cells['banco']?.value as ItemModel).id == 0 ? null : (e.cells['banco']?.value as ItemModel).id,
                                'vencimiento': (DateTime.parse(e.cells['vencimiento']?.value ?? '01-01-2001').toIso8601String()),
                                'monto': e.cells['monto']?.value,
                              }).toList();
                              var items= stateManagerDatos.refRows.map((element) => {
                                'productoId': element.cells['producto']?.value?.id ?? 0,
                                'precio':element.cells['precio']?.value ?? 0,
                                'cantidad':element.cells['cantidad']?.value ?? 0,
                                'iva':element.cells['iva']?.value ?? 0,
                              }).toList();
                              var body={
                                'fecha': fecha.toIso8601String(),
                                'clientId': 0,
                                'userId': 0,
                                'periodo':Globals.periodo,
                                'proveedorId' : cliente?.id,
                                'numeroDoc': facturaController.text,
                                'timbrado': timbradoController.text,
                                'detalles':items,
                                'sucursalId': storage.getItem('sucursal'),
                                'pagos':pagos
                              };
                              var result= await factProvider.registrarCompra(body);
                              if(result){
                                await limpiar();
                              }
                            }, icon: Icon(Icons.save), label: Text('Guardar Factura'))),
                        Positioned(
                            top: 10,
                            left:200,
                            child: ElevatedButton.icon(onPressed:() async{} , icon:Icon(Icons.cleaning_services_rounded), label: Text('Cancelar Operación'))),
                        Positioned(
                          top: 60,
                          child: SizedBox(
                              width: 1100,
                              height: 250,

                              child: PlutoGrid(
                                onChanged: (a){

                                },
                                configuration:  const PlutoGridConfiguration(
                                  style: PlutoGridStyleConfig(
                                      cellTextStyle: TextStyle(fontSize: 12),
                                      columnTextStyle: TextStyle(fontSize: 12),
                                      rowHeight: 25,
                                      columnHeight: 30
                                  ),
                                  scrollbar: PlutoGridScrollbarConfig(
                                    isAlwaysShown: true,
                                    draggableScrollbar: true,
                                  ),
                                  enableMoveDownAfterSelecting: false,
                                  enterKeyAction: PlutoGridEnterKeyAction.toggleEditing,

                                ),
                                columns: [
                                  PlutoColumn(title: 'Tipo de Pago', field: 'tipo', type: PlutoColumnType.select(dataProvider.tipoDePagos),width: 300,
                                    renderer: (rendererContext) {
                                      return Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.add_circle,
                                            ),
                                            onPressed: () {
                                              rendererContext.stateManager.insertRows(
                                                  rendererContext.rowIdx,[PlutoRow(cells: {
                                                'tipo' : PlutoCell(value: ItemModel(0,'')),
                                                'banco': PlutoCell(value: ItemModel(0,'')),
                                                'cheque': PlutoCell(value: ''),
                                                'vencimiento': PlutoCell(value: DateTime.now()),
                                                'obs': PlutoCell(value: ''),
                                                'monto': PlutoCell(value: '')
                                              })]
                                              );
                                            },
                                            iconSize: 18,
                                            color: Colors.green,
                                            padding: const EdgeInsets.all(0),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.remove_circle_outlined,
                                            ),
                                            onPressed: () {
                                              rendererContext.stateManager
                                                  .removeRows([rendererContext.row]);
                                            },
                                            iconSize: 18,
                                            color: Colors.red,
                                            padding: const EdgeInsets.all(0),
                                          ),
                                          Expanded(
                                            child: Text(
                                              rendererContext.row.cells[rendererContext.column.field]!.value
                                                  .toString(),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  PlutoColumn(title: 'Banco', field: 'banco', type: PlutoColumnType.select(dataProvider.bancos),width: 120),
                                  PlutoColumn(title: 'Cheque', field: 'cheque', type: PlutoColumnType.text(),width: 100),
                                  PlutoColumn(title: 'Vencimiento', field: 'vencimiento', type: PlutoColumnType.date(),width: 120),
                                  PlutoColumn(title: 'Observacion', field: 'obs', type: PlutoColumnType.text(),width: 150),
                                  PlutoColumn(title: 'Monto', field: 'monto', type: PlutoColumnType.currency(
                                      decimalDigits: 0, symbol: '₲', applyFormatOnInit: true),width: 150,
                                    footerRenderer: (rendererContext) {
                                      return PlutoAggregateColumnFooter(
                                        rendererContext: rendererContext,
                                        type: PlutoAggregateColumnType.sum,
                                        format: '###,###,###',
                                        alignment: Alignment.center,
                                      );
                                    },
                                  ),
                                ],
                                rows: [PlutoRow(cells: {
                                  'tipo' : PlutoCell(value: ItemModel(0,'')),
                                  'banco': PlutoCell(value: ItemModel(0,'')),
                                  'cheque': PlutoCell(value: ''),
                                  'vencimiento': PlutoCell(value: DateTime.now()),
                                  'obs': PlutoCell(value: ''),
                                  'monto': PlutoCell(value: '')
                                })],
                                onLoaded: (PlutoGridOnLoadedEvent event) => stateManagerPagos = event.stateManager,
                              )

                          ),
                        )
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
    cliente=null;
    rucController.clear();
    condicionController.clear();
    stateManagerDatos.refRows.clear();
    stateManagerPagos.refRows.clear();
    facturaController.text='001-001-';
    stateManagerDatos.insertRows(0, [PlutoRow(cells: {
      'producto' : PlutoCell(value: ItemModel(0,'')),
      'cantidad': PlutoCell(value: 1),
      'precio': PlutoCell(value: 0),
      'total': PlutoCell(value: 0),
      'iva': PlutoCell(value: 0),
    })]);
    stateManagerPagos.insertRows(0, [PlutoRow(cells: {
      'tipo' : PlutoCell(value: ItemModel(0,'')),
      'banco': PlutoCell(value: ItemModel(0,'')),
      'cheque': PlutoCell(value: ''),
      'vencimiento': PlutoCell(value: DateTime.now()),
      'obs': PlutoCell(value: ''),
      'monto': PlutoCell(value: '')
    })]);
  }
  void updateTotal(){

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
