import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:centyneg_sys/commons/Globals.dart';
import 'package:centyneg_sys/models/drop_item_model.dart';
import 'package:centyneg_sys/widgets/loading_widget.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:empty_widget/empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:go_router/go_router.dart';
import 'package:pluto_grid/pluto_grid.dart';

class CuentaCorrienteScreen extends StatefulWidget {
  const CuentaCorrienteScreen({super.key});

  @override
  State<CuentaCorrienteScreen> createState() => _CuentaCorrienteScreenState();
}

class _CuentaCorrienteScreenState extends State<CuentaCorrienteScreen> {
  var entidadController= TextEditingController();
  DropItemModel? entidad;
  DropItemModel? tipo;
  DropItemModel? cuenta;
  final dio= Dio(BaseOptions(baseUrl: Globals.apiUrl));
  var isLoading=true;
  var me={};

  late PlutoGridStateManager grid;
  late PlutoGridStateManager gridResumenCuenta;
  late PlutoGridStateManager gridResumenEntidad;
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

  @override
  Widget build(BuildContext context) {
   var size= MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white70,
      body: isLoading ? const LoadingWidget() : SingleChildScrollView(
        child: SingleChildScrollView(
          child: Container(
            width: size.width,
            height: size.height * 2,
            color: Colors.white70,
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
                        top: 100,child: SizedBox(
                          width: 250,
                          height: 50,
                          child: TypeAheadField(
                            textFieldConfiguration:   TextFieldConfiguration(
                                autofocus: true,
                                style: const TextStyle(fontSize: 14),
                                controller: entidadController,
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: 'Buscar un Cliente'
                                )
                            ),
                            suggestionsCallback: (pattern) async {
                              var result= await dio.get('/api/cuenta-corriente/get-entidades', queryParameters: {
                                'clientId':me['clientId'],
                                'pattern':pattern
                              });
                              return result.data as List;
                            },
                            itemBuilder: (context, suggestion) {
                              return ListTile(
                                leading: const Icon(Icons.supervised_user_circle_sharp),
                                title: Text(suggestion['name']),
                                subtitle: Text('R.U.C ${suggestion['ruc']}'),
                              );
                            },
                            onSuggestionSelected: (suggestion) async {
                              entidad=DropItemModel(suggestion['id'], suggestion['name']);
                              entidadController.text=entidad?.title ?? '';
                            },
                            hideSuggestionsOnKeyboardHide: false,
                            hideOnError: true,
                            animationDuration: const Duration(seconds: 1),

                            noItemsFoundBuilder: (_)=> Container(
                                width: 400,
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
                                        subTitle: 'Parece que el cliente que buscas no existe',
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

                                  ],
                                )
                            ),
                          ),
                        ),
                      ),
                      Positioned(left: 20,
                        top: 150,child: SizedBox(
                          width: 250,
                          height: 50,
                          child: DropdownSearch<DropItemModel>(
                            asyncItems: (f)=>  (dio.get('/api/cuenta-corriente/get-cuentas',queryParameters: {
                              'clientId':me['clientId']
                            }).then((value) => (value.data as List).map((e) => DropItemModel(e['id'], e['name'])).toList())),
                            onChanged: (a){
                              cuenta=a;
                            },
                            selectedItem: cuenta,
                            dropdownDecoratorProps: const DropDownDecoratorProps(
                                dropdownSearchDecoration: InputDecoration(
                                    label: Text('Seleccionar Cuenta')
                                )
                            ),
                          ),
                        ),
                      ),
                      Positioned(left: 20,
                        top: 220,child: SizedBox(
                          width: 250,
                          height: 50,
                          child: DropdownSearch<DropItemModel>(
                            asyncItems: (f)=>  (dio.get('/api/cuenta-corriente/get-estados',queryParameters: {
                            }).then((value) => (value.data as List).map((e) => DropItemModel(e['id'], e['name'])).toList())),
                            onChanged: (a){
                              tipo=a;
                            },
                            selectedItem: tipo,
                            dropdownDecoratorProps: const DropDownDecoratorProps(
                                dropdownSearchDecoration: InputDecoration(
                                    label: Text('Estado del Documento')
                                )
                            ),
                          ),
                        ),
                      ),
                      Positioned(left: 20,
                        top: 300,child: SizedBox(
                          width: 120,
                          height: 50,
                          child: ElevatedButton.icon(onPressed: () async{
                            grid.refRows.clear();
                            gridResumenEntidad.refRows.clear();
                            gridResumenCuenta.refRows.clear();
                            var result= await dio.post('/api/entidades/generar-cuenta-corriente',data: {
                              'entidadId':entidad?.id,
                              'estado':tipo?.id,
                              'cuentaId':cuenta?.id,
                              'clientId':me['clientId']
                            }, options: Options(validateStatus: (i)=> i!<500));
                            grid.insertRows(0, (result.data['list'] as List).map((e) => PlutoRow(cells: {
                              'name':PlutoCell(value: e['name']),
                              'ruc':PlutoCell(value: e['ruc']),
                              'periodo':PlutoCell(value: e['periodo']),
                              'fecha':PlutoCell(value: e['fecha']),
                              'asiento':PlutoCell(value: e['asiento']),
                              'comprobante':PlutoCell(value: e['doc']),
                              'cuota':PlutoCell(value: e['cuota']),
                              'vence':PlutoCell(value: e['venc']),
                              'deudor':PlutoCell(value: e['debe']),
                              'acreedor':PlutoCell(value: e['haber']),
                              'saldo':PlutoCell(value: e['saldo']),
                              'operacion': PlutoCell(value: e['operacion'])
                            })).toList());
                            gridResumenEntidad.insertRows(0, (result.data['entidad'] as List).map((e) => PlutoRow(cells: {
                              'name':PlutoCell(value: e['name']),
                              'ruc':PlutoCell(value: e['ruc']),
                              'deudor':PlutoCell(value: e['debe']),
                              'acreedor':PlutoCell(value: e['haber']),
                              'saldo':PlutoCell(value: e['saldo']),
                            })).toList());
                            gridResumenCuenta.insertRows(0, (result.data['cuenta'] as List).map((e) => PlutoRow(cells: {
                              'cuenta':PlutoCell(value: e['cuenta']),
                              'deudor':PlutoCell(value: e['debe']),
                              'acreedor':PlutoCell(value: e['haber']),
                              'saldo':PlutoCell(value: e['saldo']),
                            })).toList());
                            cuenta=null;
                            entidad=null;
                            tipo=null;
                            setState(() {

                            });
                          }, icon: const Icon(Icons.search), label: const Text('Buscar')
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
                  child: Column(
                    children: [
                      const Text('DETALLE DE CUENTA CORRIENTE',style: TextStyle(fontSize: 40,fontWeight: FontWeight.bold, decoration: TextDecoration.underline),),
                      Container(
                        width: size.width * 0.80,
                        height: 600,
                        color: Colors.lightGreen.withOpacity(0.2),
                        child: PlutoGrid(
                          configuration: const PlutoGridConfiguration(
                              style: PlutoGridStyleConfig(
                          borderColor: Colors.white70,
                                  columnTextStyle: TextStyle(fontSize: 15,color: Colors.blueAccent),
                                  cellTextStyle: TextStyle(fontSize: 15,color: Colors.black87, fontWeight: FontWeight.bold),
                                rowHeight: 20,
                                columnHeight: 20
                              )
                          ),
                          onLoaded: (a)=> grid=a.stateManager,
                          columns: [
                            PlutoColumn(title: 'NOMBRE', field: 'name', type: PlutoColumnType.text(),width: 200),
                            PlutoColumn(title: 'RUC', field: 'ruc', type: PlutoColumnType.text(),width: 130),
                            PlutoColumn(title: 'PERIODO', field: 'periodo', type: PlutoColumnType.number(),width: 90),
                            PlutoColumn(title: 'FECHA OP.', field: 'fecha', type: PlutoColumnType.text(),width: 150),
                            PlutoColumn(title: 'Nº ASIENTO.', field: 'asiento', type: PlutoColumnType.text(),width: 100),
                            PlutoColumn(title: 'COMPROBANTE', field: 'comprobante', type: PlutoColumnType.text(),width: 230),
                            PlutoColumn(title: 'CUOTA Nº', field: 'cuota', type: PlutoColumnType.text(),width: 100),
                            PlutoColumn(title: 'VENCE', field: 'vence', type: PlutoColumnType.text(),width: 100),
                            PlutoColumn(title: 'CREDITO', field: 'deudor', type: PlutoColumnType.currency(symbol: '',decimalDigits: 0),width: 120),
                            PlutoColumn(title: 'DEBITO', field: 'acreedor', type: PlutoColumnType.currency(symbol: '',decimalDigits: 0),width: 120),
                            PlutoColumn(title: 'SALDO', field: 'saldo', type: PlutoColumnType.currency(symbol: '',decimalDigits: 0),width: 150),
                            PlutoColumn(title: 'OPERACION', field: 'operacion', type: PlutoColumnType.text(),width: 150),
                          ],
                          rows: [],
                        ),
                      ),
                      const Text('RESUMEN POR ENTIDAD',style: TextStyle(fontSize: 40,fontWeight: FontWeight.bold, decoration: TextDecoration.underline),),
                      Container(
                        width: size.width * 0.80,
                        height: 400,
                        color: Colors.lightGreen.withOpacity(0.2),
                        child: PlutoGrid(
                          configuration: const PlutoGridConfiguration(
                              style: PlutoGridStyleConfig(
                                  columnTextStyle: TextStyle(fontSize: 15,color: Colors.black87),
                                  cellTextStyle: TextStyle(fontSize: 15,color: Colors.blue, fontWeight: FontWeight.bold),
                                  rowHeight: 20,
                                  columnHeight: 20
                              )
                          ),
                          onLoaded: (a)=> gridResumenEntidad=a.stateManager,
                          columns: [
                            PlutoColumn(title: 'NOMBRE', field: 'name', type: PlutoColumnType.text(),width: 200),
                            PlutoColumn(title: 'RUC', field: 'ruc', type: PlutoColumnType.text(),width: 130),
                            PlutoColumn(title: 'CREDITO', field: 'deudor', type: PlutoColumnType.currency(symbol: '',decimalDigits: 0),width: 250),
                            PlutoColumn(title: 'DEBITO', field: 'acreedor', type: PlutoColumnType.currency(symbol: '',decimalDigits: 0),width: 250),
                            PlutoColumn(title: 'SALDO', field: 'saldo', type: PlutoColumnType.currency(symbol: '',decimalDigits: 0),width: 300),
                          ],
                          rows: [],
                        ),
                      ),
                      const Text('RESUMEN POR CUENTA',style: TextStyle(fontSize: 40,fontWeight: FontWeight.bold, decoration: TextDecoration.underline),),
                      Container(
                        width: size.width * 0.80,
                        height: 400,
                        color: Colors.lightGreen.withOpacity(0.2),
                        child: PlutoGrid(
                          configuration: const PlutoGridConfiguration(
                              style: PlutoGridStyleConfig(
                                  columnTextStyle: TextStyle(fontSize: 15,color: Colors.black87),
                                  cellTextStyle: TextStyle(fontSize: 15,color: Colors.blue, fontWeight: FontWeight.bold),
                                  rowHeight: 20,
                                  columnHeight: 20
                              )
                          ),
                          onLoaded: (a)=> gridResumenCuenta=a.stateManager,
                          columns: [
                            PlutoColumn(title: 'CUENTA', field: 'cuenta', type: PlutoColumnType.text(),width: 300),
                            PlutoColumn(title: 'CREDITO', field: 'deudor', type: PlutoColumnType.currency(symbol: '',decimalDigits: 0),width: 250),
                            PlutoColumn(title: 'DEBITO', field: 'acreedor', type: PlutoColumnType.currency(symbol: '',decimalDigits: 0),width: 250),
                            PlutoColumn(title: 'SALDO', field: 'saldo', type: PlutoColumnType.currency(symbol: '',decimalDigits: 0),width: 300),
                          ],
                          rows: [],
                        ),
                      ),

                    ]
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
