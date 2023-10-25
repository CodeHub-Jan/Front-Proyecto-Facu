import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:centyneg_sys/commons/Globals.dart';
import 'package:centyneg_sys/commons/date_text_formatter.dart';
import 'package:centyneg_sys/models/asiento_manual_item_model.dart';
import 'package:centyneg_sys/models/items_models.dart';
import 'package:centyneg_sys/providers/sys_data_provider.dart';
import 'package:centyneg_sys/widgets/custom_container.dart';
import 'package:centyneg_sys/widgets/loading_widget.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../commons/ThousandsSeparatorInputFormatter.dart';
import '../commons/app_color.dart';
import '../models/drop_item_model.dart';
import '../widgets/custom_dropdown_button2.dart';

class AsientoManualScreen extends StatefulWidget {
  const AsientoManualScreen({super.key});

  @override
  State<AsientoManualScreen> createState() => _AsientoManualScreenState();
}

class _AsientoManualScreenState extends State<AsientoManualScreen> {
  final dio= Dio(BaseOptions(baseUrl: Globals.apiUrl,));
  var storage= LocalStorage(Globals.dataFileKeyName);
var isEditMode= false;
  DateTime? fecha = DateTime.now();
  ItemsClientModel? cliente;
  ItemModel? cuenta;
  ItemModel? tipoOperacion;
  var textStyle = const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.bold
  );
  var fechaController = TextEditingController();
  var periodoController = TextEditingController(
      text: Globals.periodo.toString());
  var comprobanteController = TextEditingController();
  var comentarioController = TextEditingController();
  var monedaController = TextEditingController(),
      debeController = TextEditingController(),
      searchController = TextEditingController(),
      searchAccountController = TextEditingController(),
      haberController = TextEditingController();
  double totDebe = 0;
  double totHaber = 0;

  List<AsientoManualItem> items = [];
  List<DropItemModel> monedas=[];
  void calculateValues() {
    totDebe = stateManager.refRows.isEmpty ? 0 : stateManager.refRows
        .map((e) =>
        double.parse(
            e.cells['debe']?.value.toString() ?? '0'))
        .reduce((a, b) => a + b);
    totHaber = stateManager.refRows.isEmpty ? 0 : stateManager.refRows
        .map((e) =>
        double.parse(
            e.cells['haber']?.value.toString() ?? '0'))
        .reduce((a, b) => a + b);
    setState(() {

    });
  }
  @override
  void initState() {
    super.initState();
    loadDataFromApi();
  }
  var me={};
  Future loadDataFromApi() async{
    isDataLoading=true;
    me=await Globals.getMe();
    var monedasResult= await dio.get('/api/monedas/get-monedas',queryParameters: {
      'clientId':me['clientId']
    });
    monedas=(monedasResult.data as List).map((e) => DropItemModel(e['id'], e['name'])).toList();
    var provider= Provider.of<SysDataProvider>(context,listen: false);
    data= await provider.loadAsientoManualGridData();
    await provider.loadOperaciones();
    await provider.getClients();
    isDataLoading=false;
    setState(() {

    });
  }
  var data={};
  var isDataLoading=false;
  var estadoAsiento=[ItemModel(1, 'PENDIENTE'),ItemModel(4, 'NO APLICA'),];
  var libros=[ItemModel(1, 'COMPRA'),ItemModel(2, 'VENTA'),ItemModel(2, 'NO APLICA')];
late PlutoGridStateManager stateManager;
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<SysDataProvider>(context);
    return  Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColor.white),
        title: Text(
          'Asiento Manual', style: TextStyle(color: AppColor.white),),
        backgroundColor: AppColor.darkBlue,),
      body: isDataLoading? LoadingWidget() : SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20,),
            Center(child: CustomContainer(
                containerWith: 1500, containerHeight: 600, child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 20, horizontal: 20),
                  color: Colors.blue.withOpacity(0.2),
                  width: 1500,
                  height: 150,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 20,),
                          Flexible(child: SizedBox(
                            width: 200,
                            height: 30,
                            child:
                            TextField(
                              onChanged: (a){
                        if(fechaController.text.length ==10){
                         try{
                        fecha= DateFormat('dd/MM/yyyy').parse(fechaController.text);
                        print(fecha);
                         } on FormatException catch(e){
                           Globals.showMessage('Tu formato de fecha no es valido, vuelva a intentarlo', context);
                         }

                        }
                              },
                              inputFormatters: [DateTextFormatter()],
                              controller: fechaController,
                              style: const TextStyle(fontSize: 14),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Seleccionar Fecha',
                                labelStyle: TextStyle(fontSize: 12),

                              ),
                            )
                          ),),
                          const SizedBox(width: 10,),
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
                                    value: [fecha],
                                    borderRadius: BorderRadius.circular(15),
                                  );
                                  fecha = results?.first;
                                  if (fecha != null) {
                                    fechaController.text =
                                        DateFormat('dd/MM/yyyy').format(
                                            fecha!);
                                    setState(() {

                                    });
                                  }
                                },
                                icon: const Icon(Icons.calendar_month),
                                label: const Text('Seleccionar Fecha')),
                          ),),
                          const SizedBox(width: 10,),
                          CustomDropdownButton2(
                              hint: 'Seleccionar Operacion',
                              buttonWidth: 200,
                              dropdownWidth: 200,
                              buttonHeight: 30,
                              value: tipoOperacion,
                              dropdownItems: provider.operaciones,
                              onChanged: (a) {
                                //       tipoDeCuenta=a;
                                setState(() {
                                  tipoOperacion = a;
                                });
                              }),
                          const SizedBox(width: 20,),
                          Flexible(child: SizedBox(
                            width: 400,
                            height: 30,
                            child: TextField(
                              readOnly: false,
                              controller: comprobanteController,
                              style: const TextStyle(fontSize: 14),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Comprobante',
                                labelStyle: TextStyle(fontSize: 12),

                              ),
                            ),
                          ),),
                          SizedBox(width: 20,),
                        ],
                      ),
                      const SizedBox(height: 20,),
                      Row(
                        children: [
                          const SizedBox(width: 20,),
                          Flexible(child: SizedBox(
                            width: 100,
                            height: 30,
                            child: TextField(
                              readOnly: true,
                              controller: periodoController,
                              style: const TextStyle(fontSize: 14),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Periodo',
                                labelStyle: TextStyle(fontSize: 12),

                              ),
                            ),
                          ),),
                          const SizedBox(width: 20,),
                          Flexible(
                            flex: 2,
                            child: SizedBox(
                              width: 500,
                              height: 30,
                              child: TextField(
                                readOnly: false,
                                controller: comentarioController,
                                style: const TextStyle(fontSize: 14),
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Comentario',
                                  labelStyle: TextStyle(fontSize: 12),

                                ),
                              ),
                            ),),
                          const SizedBox(width: 10,),
                          CustomDropdownButton2Client(
                              searchData: DropdownSearchData(
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

                              buttonWidth: 300,
                              dropdownWidth: 500,
                              buttonHeight: 30,
                              value: cliente,
                              dropdownItems: provider.clients,
                              onChanged: (a) {
                                setState(() {
                                  cliente = a;
                                });
                              }),

                        ],
                      ),
                    ],
                  ),
                ),
                Container(width: 1500, height: 450, child: PlutoGrid(
                    mode: PlutoGridMode.popup,
                    configuration: const PlutoGridConfiguration(
                      style: PlutoGridStyleConfig(
                          cellTextStyle: TextStyle(fontSize: 11),
                          columnTextStyle: TextStyle(fontSize: 11)
                      ),
                      enableMoveDownAfterSelecting: false,
                      enterKeyAction: PlutoGridEnterKeyAction.toggleEditing,
                    ),
                    onLoaded: (a){
                      stateManager=a.stateManager;
                    },
                    onChanged: (a) async{
                      if(a.columnIdx==3){
                        print(a.row.cells['moneda']?.value.id);
                        var monedaResult= await dio.get('/api/monedas/get-moneda2',
                        queryParameters: {
                          'id': a.row.cells['moneda']?.value.id,
                          'fecha': fecha?.toIso8601String()
                        }, options:Options(
                                validateStatus: (status){return status! < 500;}
                            ) );
                        if(monedaResult.statusCode == 404){
                          var result=
                          await dio.get('/api/monedas/check-cotizacion-by-date',
                              queryParameters: {
                                'fromDate':fecha?.toIso8601String()
                              });

                          var checkDolar= (result.data as Map)['found'];
                          if(!checkDolar){
                            var valor= await showTextInputDialog(context: context, textFields: [
                              const DialogTextField(hintText: 'Valor del Dolar',keyboardType:TextInputType.number)
                            ],title: 'VALOR DEL DOLAR PARA LA FECHA');
                            var dolar= double.parse(valor?[0] ?? '0');
                            var body= {
                              'fecha':fecha?.toIso8601String(),
                              'valor':dolar,
                              'moneda':2
                            };
                            await dio.post('/api/monedas/registrar-cotizacion',
                                data:body);
                            a.row.cells['cambio']?.value= dolar;
                          }
                        }else{
                          a.row.cells['cambio']?.value= (monedaResult.data as Map)['valor'];
                        }

                      }
                      if(a.columnIdx == 7 || a.columnIdx ==8){
                        var moneda= a.row.cells['moneda']?.value;
                      if(moneda.id==0){
                        var result = showAlertDialog(context: context,title: 'Atención Usuario',message: 'Selecciona la moneda a utilizar en esta linea !');
                        return;
                      }else{
                        var value=  a.row.cells['cambio']?.value;
                        var debeOriginal= double.parse(a.row.cells['debe']?.value.toString() ?? '0');
                        var haberOrignal= double.parse(a.row.cells['haber']?.value.toString() ?? '0');
                        a.row.cells['origen']?.value= ((debeOriginal + haberOrignal));
                        a.row.cells['debe']?.value = a.row.cells['debe']?.value* value;
                        a.row.cells['haber']?.value = a.row.cells['haber']?.value* value;
                      }

                      }
                      if(a.columnIdx == 0){
                        a.row.cells['entidad']?.value= !a.value.sub ? ItemModel(0, 'N/A') : ItemModel(0, '(SELECCIONAR)');
                        a.row.cells['estado']?.value= !a.value.sub ? ItemModel(0, 'N/A') : ItemModel(0, '(SELECCIONAR)');;
                      }
                        if(a.row.cells['comentario']?.value.toString().isEmpty ?? false){
                          a.row.cells['comentario']?.value=comentarioController.text;
                        }
                        if(a.row.cells['comprobante']?.value.toString().isEmpty ?? false){
                          a.row.cells['comprobante']?.value=comprobanteController.text;
                        }

                    },
                    columns: [
                      PlutoColumn(title: 'CUENTA.',
                        field: 'cuenta',
                        type: PlutoColumnType.select(data['cuentas'].map((e) => ItemModel(e['id'], e['name'], moneda: e['moneda']['name'],cambio: e['moneda']['cambio'], monedaId: e['moneda']['id'], sub: e['sub'])).toList() ?? [], enableColumnFilter: true),
                        width: 300,
                        renderer: (rendererContext) {
                          return Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.add_circle,
                                ),
                                onPressed: () {
                                  rendererContext.stateManager.insertRows(
                                      rendererContext.rowIdx + 1,[
                                    PlutoRow(cells: {
                                      'cuenta':PlutoCell(value:ItemModel(0,'') ),
                                      'estado':PlutoCell(value:ItemModel(4,'') ),
                                      'entidad':PlutoCell(value:ItemModel(0,'') ),
                                      'moneda':PlutoCell(value: DropItemModel(0,'(SELECCIONAR)')),
                                      'cambio':PlutoCell(value: 0),
                                      'comentario':PlutoCell(value:comentarioController.text),
                                      'comprobante':PlutoCell(value:comprobanteController.text),
                                      'debe':PlutoCell(value:0),
                                      'haber':PlutoCell(value:0),
                                      'origen':PlutoCell(value:0),
                                    })
                                  ]
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
                                  calculateValues();
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
                      PlutoColumn(title: 'ESTADO.',
                          field: 'estado',
                          type: PlutoColumnType.select(estadoAsiento),
                          width: 100),
                      PlutoColumn(title: 'ENTIDAD.',
                          field: 'entidad',
                          type: PlutoColumnType.select(
                              data['clientes'].map((e) => ItemModel(e['id'], '${e['fullName']}(R.U.C ${e['ruc']})')).toList() ?? [], enableColumnFilter: true),
                          width: 150),
                      PlutoColumn(title: 'MONEDA.',
                          field: 'moneda',
                          readOnly: false,
                          type: PlutoColumnType.select(monedas),
                          width: 100),
                      PlutoColumn(title: 'CAMBIO.',
                          field: 'cambio',
                          readOnly: true,
                          type: PlutoColumnType.number(),
                          width: 100),
                      PlutoColumn(title: 'COMENTARIO.',
                          field: 'comentario',
                          type: PlutoColumnType.text(),
                          width: 200),

                      PlutoColumn(title: 'COMPROBANTE.',
                          field: 'comprobante',
                          type: PlutoColumnType.text(),
                          width: 150),
                      PlutoColumn(
                          title: 'DEUDOR.', field: 'debe', type: PlutoColumnType
                          .currency(symbol: '', decimalDigits: 0), width: 120),
                      PlutoColumn(title: 'ACREEDOR.',
                          field: 'haber',
                          type: PlutoColumnType.currency(
                              symbol: '', decimalDigits: 0),
                          width: 120),
                      PlutoColumn(title: 'ORIGEN.',
                          field: 'origen',
                          readOnly: true,
                          type: PlutoColumnType.currency(
                              symbol: '', decimalDigits: 0),
                          width: 120),
                    ], rows: [
                  PlutoRow(cells: {
                    'cuenta':PlutoCell(value:ItemModel(0,'') ),
                    'estado':PlutoCell(value:ItemModel(4,'') ),
                    'entidad':PlutoCell(value:ItemModel(0,'') ),
                    'moneda':PlutoCell(value:DropItemModel(0,'(SELECCIONAR)')),
                    'cambio':PlutoCell(value: 0),
                    'comentario':PlutoCell(value:comentarioController.text),
                    'comprobante':PlutoCell(value:comprobanteController.text),
                    'debe':PlutoCell(value:0),
                    'haber':PlutoCell(value:0),
                    'origen':PlutoCell(value:0),
                  })
                ])
                )
              ],
            ))),
            Container(
              width: 1500,
              height: 200,
              color: Colors.green.withOpacity(0.10),
              child: Stack(
                children: [
                  Positioned(right: 10,
                    top: 10,
                    child: Text(
                      'MONTO DEUDOR: ${Globals.formatNumberToLocate(totDebe)}',
                      style: TextStyle(fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColor.darkBlue),)
                    ,
                  ),
                  Positioned(right: 10,
                    top: 50,
                    child: Text('MONTO ACREEDOR: ${Globals.formatNumberToLocate(
                        totHaber)}', style: TextStyle(fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColor.darkBlue),)
                    ,
                  ),
                  Positioned(right: 10,
                    top: 90,
                    child: Text('DIFERENCIAS: ${Globals.formatNumberToLocate(
                        totDebe - totHaber)}', style: const TextStyle(fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),)
                    ,
                  ),
                  Positioned(right: 10,
                    top: 130, child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          primary: AppColor.darkBlue,
                          onPrimary: Colors.white,
                          shadowColor: Colors.greenAccent,
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32.0)),
                          minimumSize: const Size(120, 50),
                        ),
                        onPressed: () async {
                          if(checkBeforeSave()){
                           await showAlertDialog(context: context,title: 'Atención Usuario', message:'Debes de seleccionar la moneda para todas las lineas');
                           return;
                          }
                          if (tipoOperacion == null) {
                            Globals.showMessage(
                                'Seleccione un tipo de Operación', context);
                            return;
                          }
                          if (cliente == null) {
                            Globals.showMessage(
                                'Seleccione un Cliente', context);
                            return;
                          }
                          if (fecha == null) {
                            Globals.showMessage(
                                'Seleccione la Fecha!', context);
                            return;
                          }
                          if (totDebe != totHaber) {
                            Globals.showMessage(
                                'Cuadre el Asiento antes de guardarlo !',
                                context);
                            return;
                          }
                          var me = await provider.getMe();
                          var resultado = await provider.generaAsientoManual({
                            'fecha': fecha?.toIso8601String(),
                            'periodo': Globals.periodo,
                            'tipoOperacionId': tipoOperacion?.id,
                            'numeroComprobante': comprobanteController.text,
                            'comentario': comentarioController.text,
                            'entidadId': cliente?.id,
                            'clientId': me['clientId'],
                            'tipoDocId': 1,
                            'sucursalId': storage.getItem('sucursal'),
                            'userId': me['id'],
                            'details': stateManager.refRows.map((e) =>
                            {
                              'cuentaId': e.cells['cuenta']?.value.id,
                              'debe':  e.cells['debe']?.value,
                              'haber':  e.cells['haber']?.value,
                              'origen':  e.cells['origen']?.value,
                              'monedaId':  e.cells['cuenta']?.value.monedaId,
                              'comentario':  e.cells['comentario']?.value,
                              'entidadId':  e.cells['entidad']?.value?.id == 0 ? null :e.cells['entidad']?.value?.id ,
                              'estado':  e.cells['estado']?.value?.id,
                              'comprobante':  e.cells['comprobante']?.value,
                              'cambio': e.cells['cuenta']?.value.cambio
                            }).toList()
                          });
                          await Globals.showMessage(resultado, context);
                          clear();
                        },
                        icon: const Icon(Icons.save),
                        label: const Text('Guardar Asiento')),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
  bool checkBeforeSave(){
    return stateManager.refRows
        .any((element) => element.cells['moneda']?.value.id==0);
  }
  void clear(){
    stateManager.refRows.clear();

    totDebe=0;
    totHaber=0;
    cliente=null;
    tipoOperacion=null;
    fecha= DateTime.now();
    comprobanteController.clear();
    comentarioController.clear();
    stateManager.insertRows(0, [
      PlutoRow(cells: {
        'cuenta':PlutoCell(value:ItemModel(0,'') ),
        'estado':PlutoCell(value:ItemModel(4,'') ),
        'entidad':PlutoCell(value:ItemModel(0,'') ),
        'moneda':PlutoCell(value:''),
        'cambio':PlutoCell(value: 0),
        'comentario':PlutoCell(value:comentarioController.text),
        'comprobante':PlutoCell(value:comprobanteController.text),
        'debe':PlutoCell(value:0),
        'haber':PlutoCell(value:0),
        'origen':PlutoCell(value:0),
      })
    ]);
    setState(() {

    });
  }
}
