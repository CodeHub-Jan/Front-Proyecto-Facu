import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:animated_text_lerp/animated_text_lerp.dart';
import 'package:centyneg_sys/commons/Globals.dart';
import 'package:centyneg_sys/models/items_models.dart';
import 'package:centyneg_sys/widgets/custom_container.dart';
import 'package:centyneg_sys/widgets/loading_widget.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../commons/app_color.dart';
import '../providers/sys_data_provider.dart';
import '../widgets/custom_dropdown_button2.dart';

class OrdenPagoScreen extends StatefulWidget {
  const OrdenPagoScreen({super.key});

  @override
  State<OrdenPagoScreen> createState() => _OrdenPagoScreenState();
}

class _OrdenPagoScreenState extends State<OrdenPagoScreen> {
  late SysDataProvider provider;
  @override
  void initState() {
    provider = Provider.of<SysDataProvider>(context, listen: false);
    loadDataFromApi();
    // TODO: implement initState
    super.initState();
  }
  var storage= LocalStorage(Globals.dataFileKeyName);
  var isLoading=true;
  var me={};
  var saldo=0;
  var haveArqueo=false;
  loadComprobanteNumber() async{
    var numberResult= await dio.get('/api/modules/get-op-number',
        queryParameters: {
          'clientId': me['clientId'],
          'periodo': Globals.periodo,
          'sucursalId': storage.getItem('sucursal'),
        }
    );
    opController.text= numberResult.data['number'];
  }
  loadDataFromApi() async{
    setState(() {
      isLoading=true;
    });
    await provider.getClients();
    await provider.loadImputablesOp();
    await provider.getTiposPagos(4);
    await provider.getBancos();
    await provider.getNumber(2);
    me=await Globals.getMe();
    await loadComprobanteNumber();
    var boucherResult= await dio.get('/api/arqueos/listar-bouchers',
        queryParameters: {
          'clientId':me['clientId']
        });
    var pagosResult= await dio.get('/api/typeofpayments/get-all',
        queryParameters: {
          'clientId':me['clientId'],
          'tipoId':4
        });
    bouchers=(boucherResult.data as List).map((e) => _Boucher(e['code'], e['id'])).toList();
    pagos=(pagosResult.data as List).map((e) => _Tipo(e['name'], e['id'], e['arqueo'])).toList();
    setState(() {
      isLoading=false;
    });
  }
  final dio= Dio(BaseOptions(baseUrl: Globals.apiUrl));
  List<_Boucher> bouchers=[];
  List<_Tipo> pagos=[];
  DateTime fecha = DateTime.now();
  ItemsClientModel? cliente;
  ItemModel? cuenta;
  var searchClientController = TextEditingController();
  var periodoController = TextEditingController(text: Globals.periodo.toString());
  var opController = TextEditingController();
  var comentarioController = TextEditingController();
  var textStyle=  const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.bold
  );
  late PlutoGridStateManager stateManagerDatos;
  late PlutoGridStateManager stateManagerPagos;
  List<PlutoRow> rowsDatos= [];
  List<dynamic> originalData=[];
  String total='Total a Pagar: 0';
  List<PlutoRow> rowsPagos= [PlutoRow(cells: {
    'tipo' : PlutoCell(value: _Tipo('',0,false)),
    'banco': PlutoCell(value: ItemModel(0,'')),
    'cheque': PlutoCell(value: ''),
    'vencimiento': PlutoCell(value: DateTime.now()),
    'obs': PlutoCell(value: ''),
    'boucher': PlutoCell(value: _Boucher('', 0)),
    'monto': PlutoCell(value: '')
  })];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColor.white),
        title: Text(
          'Orden de Pago', style: TextStyle(color: AppColor.white),),
        backgroundColor: AppColor.darkBlue,),
      body: isLoading ? LoadingWidget() : SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20,),
            Center(
              child: CustomContainer(
                padding: const EdgeInsets.symmetric(
                    vertical: 20, horizontal: 20),
                containerWith: 1200,
                containerHeight: 820,
                child: Stack(
                  children: [
                    if(haveArqueo)
                      Positioned(
                          top: 10,
                          right: 2,
                          child: SizedBox(
                              width: 300,
                              height: 100,
                              child: // default usage
                              Row(
                                  children: [
                                    const Text('Saldo:',style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
                                    AnimatedNumberText(
                                      saldo, // int or double
                                      curve: Curves.easeIn,
                                      duration: const Duration(seconds: 1),
                                      style: const TextStyle(fontSize: 30),
                                      formatter: (value) {
                                        final formatted =
                                        NumberFormat.currency(decimalDigits: 0,symbol: '').format(value);
                                        return formatted;
                                      },
                                    ),
                                  ]
                              )
                          )),
                    Positioned(left: 10,
                      top: 12, child: SizedBox(
                        width: 120,
                        height: 50
                        ,
                        child: TextField(
                            controller: periodoController,
                            decoration: const InputDecoration(
                                labelText: 'Periodo'), style: const TextStyle(
                            color: Colors.blue
                        )),
                      ),
                    ),
                    Positioned(left: 150,
                      top: 20, child: SizedBox(
                          width: 160,
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
                      ,
                    ),
                    Positioned(
                        left: 320,
                        top: 75,
                        child: CustomDropdownButton2(
                            hint: 'Seleccionar Cuenta',
                            buttonWidth: 390,
                            dropdownWidth: 390,
                            buttonHeight: 30,
                            value: cuenta,
                            dropdownItems: provider.cuentasImputables,
                            onChanged: (a) async {
                              setState(() {
                                cuenta=a;
                              });
                              if(cliente !=null){
                                originalData= await provider.getPendientes(cliente?.id ?? 0, cuenta?.id?? 0);
                                rowsDatos= originalData.map((e) =>  PlutoRow(cells: {
                                  'id': PlutoCell(value: e['id']),
                                  'estado': PlutoCell(value: e['estado']),
                                  'asiento': PlutoCell(value: e['asiento']),
                                  'cuota': PlutoCell(value: e['cuota']),
                                  'doc': PlutoCell(value: e['doc']),
                                  'fecha': PlutoCell(value: e['fecha']),
                                  'vencimiento': PlutoCell(value: e['vencimiento']),
                                  'monto_original': PlutoCell(value: e['monto_original']),
                                  'saldo': PlutoCell(value: e['saldo']),
                                  'monto': PlutoCell(value: 0),
                                })).toList();
                                stateManagerDatos.refRows.clear();
                                stateManagerDatos.insertRows(0,rowsDatos);
                              }
                            })

                    ),
                    Positioned(
                        left: 10,
                        top: 120,
                        child: CustomDropdownButton2Client(
                            searchData: DropdownSearchData(
                              searchController: searchClientController,
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
                                  controller: searchClientController,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: const EdgeInsets
                                        .symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    hintText: 'Buscar un Cliente..',
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
                                    .contains(searchValue.toUpperCase()) ||
                                    item.value!.ruc
                                        .toUpperCase()
                                        .contains(searchValue.toUpperCase());
                              },
                            ),
                            hint: 'Seleccionar Entidad',

                            buttonWidth: 700,
                            dropdownWidth: 700,
                            buttonHeight: 30,
                            dropdownHeight: 250,
                            value: cliente,
                            dropdownItems: provider.clients,
                            onChanged: (a) async {
                              cliente = a;
                              if(cliente !=null){
                                originalData= await provider.getPendientes(cliente?.id ?? 0, cuenta?.id?? 0);
                                rowsDatos= originalData.map((e) =>  PlutoRow(cells: {
                                  'id': PlutoCell(value: e['id']),
                                  'estado': PlutoCell(value: e['estado']),
                                  'asiento': PlutoCell(value: e['asiento']),
                                  'cuota': PlutoCell(value: e['cuota']),
                                  'doc': PlutoCell(value: e['doc']),
                                  'fecha': PlutoCell(value: e['fecha']),
                                  'vencimiento': PlutoCell(value: e['vencimiento']),
                                  'monto_original': PlutoCell(value: e['monto_original']),
                                  'saldo': PlutoCell(value: e['saldo']),
                                  'monto': PlutoCell(value: 0),
                                })).toList();
                                stateManagerDatos.refRows.clear();
                                stateManagerDatos.insertRows(0,rowsDatos);
                                stateManagerDatos.setShowLoading(false);
                              }
                              setState(() {

                              });
                            })),
                    Positioned(left: 10,
                      top: 150, child: SizedBox(
                        width: 200,
                        height: 50
                        ,
                        child: TextField(
                          readOnly: true,
                            controller: opController,
                            decoration: const InputDecoration(
                                labelText: 'OP N°'), style: const TextStyle(
                            color: Colors.blue
                        )),
                      ),
                    ),
                    Positioned(left: 220,
                      top: 150, child: SizedBox(
                        width: 550,
                        height: 50
                        ,
                        child: TextField(
                            controller: comentarioController,
                            decoration: const InputDecoration(
                                labelText: 'Comentario'),
                            style: const TextStyle(
                                color: Colors.blue
                            )),
                      ),
                    ),
                    Positioned(
                        top: 220,
                        child: Container(
                          width: 1100,
                          height: 20,
                          color: Colors.green[300],
                          child: const Text('SELECCIONAR DOCUMENTOS PENDIENTES'),
                        )),
                    Positioned(
                        top: 250,
                        child: SizedBox(
                          width: 1100,
                          height: 250,
                          child:PlutoGrid(
                            onLoaded: (PlutoGridOnLoadedEvent event) => stateManagerDatos = event.stateManager,
                            onRowChecked: (a){
                              var sum= stateManagerDatos.rows
                                  .where((element) => element.checked ?? false)
                                  .map((e) =>  e.cells['monto'] == null ? 0 : e.cells['monto']?.value).toList();
                             total='Total a Pagar: ${Globals.formatNumberToLocate(sum.reduce((a, b) => a+b ))}';
                             setState(() {
                               
                             });
                            },
                            onChanged: (a){
                              print(originalData.length);
                              var id=stateManagerDatos.getRowByIdx(a.rowIdx)?.cells['id']?.value ?? 0;
                              var data= originalData.where((element) => element['id']==id).firstOrNull;
                              if(data != null){
                                stateManagerDatos.getRowByIdx(a.rowIdx)?.cells['saldo']?.value= data['saldo'];
                              }
                              var entregado= a.value;
                              var saldo= stateManagerDatos.getRowByIdx(a.rowIdx)?.cells['saldo']?.value ?? 0;
                              if(entregado>saldo){
                                Globals.showMessage('Ingrese un valor valido !', context);
                              return;
                              }
                              if(entregado !=0){

                              }
                              var newSaldo= saldo-entregado;
                              stateManagerDatos.getRowByIdx(a.rowIdx)?.cells['saldo']?.value=newSaldo;
                              stateManagerDatos.getRowByIdx(a.rowIdx)?.cells['estado']?.value= entregado >= saldo ? 'CANCELADO' : 'AMORTIZADO';
                              var sum= stateManagerDatos.rows
                                  .where((element) => element.checked ?? false)
                                  .map((e) =>  e.cells['monto'] == null ? 0 : e.cells['monto']?.value).toList();
                              total='Total a Pagar: ${Globals.formatNumberToLocate(sum.reduce((a, b) => a+b ))}';
                              setState(() {

                              });
                              },
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
                                PlutoColumn(title: 'Id', field: 'id', type: PlutoColumnType.text(),width: 50, readOnly: true,),
                                PlutoColumn(title: 'Estado', field: 'estado', type: PlutoColumnType.text(),width: 130, readOnly: true, enableRowChecked: true),
                                PlutoColumn(title: 'ASIENTO', field: 'asiento', type: PlutoColumnType.text(),width:80 , readOnly: true),
                                PlutoColumn(title: 'Cuota', field: 'cuota', type: PlutoColumnType.text(),width: 80, readOnly: true),
                                PlutoColumn(title: 'Comprobante', field: 'doc', type: PlutoColumnType.text(),width: 130, readOnly: true),
                                PlutoColumn(title: 'Fecha', field: 'fecha', type: PlutoColumnType.text(),width: 100, readOnly: true),
                                PlutoColumn(title: 'Vencimiento', field: 'vencimiento', type: PlutoColumnType.text(),width: 100, readOnly: true),
                                PlutoColumn(title: 'Monto Original', field: 'monto_original', type: PlutoColumnType.currency(decimalDigits: 0,symbol: ''),width: 130,

                                    footerRenderer: (rendererContext) {
                                      return PlutoAggregateColumnFooter(
                                        padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 1),
                                        rendererContext: rendererContext,
                                        type: PlutoAggregateColumnType.sum,
                                         format: '###,###,###',
                                        alignment: Alignment.center,
                                      );
                                    },
                                    readOnly: true),
                                PlutoColumn(title: 'Saldo', field: 'saldo', type: PlutoColumnType.currency(decimalDigits: 0,symbol: '₲'),width: 130,
                                    footerRenderer: (rendererContext) {
                                      return PlutoAggregateColumnFooter(
                                        padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 1),
                                        rendererContext: rendererContext,
                                        type: PlutoAggregateColumnType.sum,
                                        format: '###,###,###',
                                        alignment: Alignment.center,
                                      );
                                    },
                                    readOnly: true),
                                PlutoColumn(title: 'Monto a Pagar', field: 'monto', type: PlutoColumnType.currency(decimalDigits: 0,symbol: '₲'),width: 130,),
                              ],
                              rows: rowsDatos,
                          )

                        ),

                    ),
                    Positioned(
                        top: 500,
                        right: 60,
                        child: Container(
                          width: 400,
                          height: 20,
                          color: Colors.grey[20],
                          child:  Text(total, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.right),
                        )),
                    Positioned(
                        top: 550,
                        child: Container(
                          width: 1100,
                          height: 20,
                          color: Colors.green[300],
                          child: const Text('SELECCIONAR FORMAS DE PAGO'),
                        )),

                    Positioned(
                      top: 580,
                      child: SizedBox(
                        width: 1100,
                        height: 150,

                            child: PlutoGrid(
                              onChanged: (a) async{
                                if(a.columnIdx==0){
                                  if(a?.value != null){
                                    haveArqueo= a?.value.arqueo ?? false;
                                    a.row.cells['boucher']?.value= haveArqueo ? _Boucher('(SELECCIONAR)', 0) :  _Boucher('(N/A)', 0);
                                    setState(() {

                                    });
                                  }}
                                if(a.columnIdx==2){
                                  var boucherId=a.row.cells['boucher']?.value.id ?? 0;
                                  var saldoResult= await dio.get('/api/arqueos/get-saldo-boucher', queryParameters: {
                                    'id': boucherId
                                  });
                                  saldo=(saldoResult.data as Map)['saldoNumber'];
                                  setState(() {

                                  });
                                }
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
                                PlutoColumn(title: 'Tipo de Pago', field: 'tipo', type: PlutoColumnType.select(pagos),width: 300,
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
                                              'boucher': PlutoCell(value: ''),
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
                                PlutoColumn(title: 'Banco', field: 'banco', type: PlutoColumnType.select(provider.bancos),width: 120),
                                PlutoColumn(title: 'Boucher', field: 'boucher', type: PlutoColumnType.select(bouchers),width: 120),
                                PlutoColumn(title: 'Cheque', field: 'cheque', type: PlutoColumnType.text(),width: 100),
                                PlutoColumn(title: 'Vencimiento', field: 'vencimiento', type: PlutoColumnType.date(),width: 120),
                                PlutoColumn(title: 'Observacion', field: 'obs', type: PlutoColumnType.text(),width: 150),
                                PlutoColumn(title: 'Monto', field: 'monto', type: PlutoColumnType.currency(
                                    decimalDigits: 0, symbol: '', applyFormatOnInit: true),width: 150,
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
                              rows: rowsPagos,
                              onLoaded: (PlutoGridOnLoadedEvent event) => stateManagerPagos = event.stateManager,
                            )

                    )),
                    Positioned(
                        top: 740,
                        right: 60,
                        child: ElevatedButton.icon(onPressed: ()async{
                          var resultCotizacion=
                          await dio.get('/api/monedas/check-cotizacion-by-date',
                              queryParameters: {
                                'fromDate':fecha?.toIso8601String()
                              });
                          var checkDolar= (resultCotizacion.data as Map)['found'];
                          if(!checkDolar){
                            var valor= await  showTextInputDialog(context: context, textFields: [
                              const DialogTextField(hintText: 'Valor del Dolar',keyboardType:TextInputType.number)
                            ],title: 'VALOR DEL DOLAR PARA LA FECHA');
                            var dolar= double.parse(valor?[0] ?? '0');
                            await dio.post('/api/monedas/registrar-cotizacion',
                                data: {
                                  'fecha':fecha?.toIso8601String(),
                                  'valor':dolar,
                                  'moneda':2
                                });
                          }
                       try{
                         if(cliente == null){
                           Globals.showMessage('Seleccione un cliente', context);
                           return;
                         }
                         if(cuenta == null){
                           Globals.showMessage('Seleccione una cuenta', context);
                           return;
                         }
                         var me= await provider.getMe();
                         var asientos= rowsDatos.where((element) => element.checked ?? false)
                             .map((e) => {
                           'asientoId': e.cells['id']?.value ?? 0,
                           'value':  e.cells['monto']?.value ?? 0,
                           'pagoId': 0,
                           'bancoId': 0,
                           'vencimiento': null,
                           'obs': '',
                           'cheque': '',
                           'docNumber': e.cells['doc']?.value ?? ''
                         }).toList();
                         var pagos= rowsPagos
                             .map((e) => {
                               'asientoId':0,
                           'pagoId': e.cells['tipo']?.value.id,
                           'bancoId': (e.cells['banco']?.value as ItemModel).id,
                           'vencimiento': (DateTime.parse(e.cells['vencimiento']?.value ?? '01-01-2001').toIso8601String()),
                           'obs': e.cells['obs']?.value,
                           'cheque': e.cells['cheque']?.value,
                           'value': e.cells['monto']?.value,
                           'docNumber':'',
                           'boucherId':e.cells['tipo']?.value.arqueo ? e.cells['boucher']?.value.id : null
                         }).toList();
                         var tot= asientos.map((e) => e['value']).reduce((a,b) =>a + b);
                         var totPago= pagos.map((e) => e['value']).reduce((a,b) =>a + b);
                         if(totPago != tot){
                           Globals.showMessage('Los montos no pueden ser diferentes', context);
                           return;
                         }
                         var result= await provider.generarOp({
                           'fecha': fecha.toIso8601String(),
                           'periodo': Globals.periodo,
                           'comentario' : comentarioController.text,
                           'entidadId':cliente?.id,
                           'cuentaId': cuenta?.id,
                           'clientId':me['clientId'],
                           'userId':me['id'],
                           'asientos':asientos,
                           'comprobante': opController.text,
                           'sucursalId': storage.getItem('sucursal'),
                           'pagos':pagos
                         });
                         Globals.showMessage(result, context);
                         clear();
                         await loadComprobanteNumber();
                       }on Exception catch(e) {
                         Globals.showMessage('Ocurrio un error, comunicalo al programador\n ${e.toString()}', context);
                       }
                        }, icon: const Icon(Icons.save), label: const Text('Guardar Operación')))
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
  void clear(){
    comentarioController.clear();
    cliente =null;
    cuenta=null;
    stateManagerDatos.refRows.clear();
    stateManagerPagos.refRows.clear();
    stateManagerPagos.insertRows(0, [PlutoRow(cells: {
      'tipo' : PlutoCell(value: ItemModel(0,'')),
      'banco': PlutoCell(value: ItemModel(0,'')),
      'cheque': PlutoCell(value: ''),
      'vencimiento': PlutoCell(value: DateTime.now()),
      'obs': PlutoCell(value: ''),
      'monto': PlutoCell(value: ''),
      'boucher': PlutoCell(value: ''),
    })]);
    total='Total a Pagar 0.00';
    setState(() {

    });
  }
}
class _Boucher {
  String name;

  _Boucher(this.name, this.id);

  int id;

  @override
  String toString() {
    // TODO: implement toString
    return name;
  }
}
class _Tipo {
  String name;
  bool arqueo;
  _Tipo(this.name, this.id, this.arqueo);

  int id;

  @override
  String toString() {
    // TODO: implement toString
    return name;
  }
}