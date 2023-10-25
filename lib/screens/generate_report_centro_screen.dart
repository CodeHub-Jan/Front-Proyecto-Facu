import 'package:centyneg_sys/commons/Globals.dart';
import 'package:centyneg_sys/models/drop_item_model.dart';
import 'package:centyneg_sys/providers/printing_provider.dart';
import 'package:date_field/date_field.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:web_smooth_scroll/web_smooth_scroll.dart';

class GenerateReportCentroScreen extends StatefulWidget {
  const GenerateReportCentroScreen({super.key});

  @override
  State<GenerateReportCentroScreen> createState() => _GenerateReportCentroScreenState();
}

class _GenerateReportCentroScreenState extends State<GenerateReportCentroScreen> {
  // Controllers
  late ScrollController _scrollController;
  var isLoading = true;
  var showGrid = false;
  List<PlutoRow> listResumen = [];
  List<PlutoRow> listExpandedInfo = [];
  final dio = Dio(BaseOptions(baseUrl: Globals.apiUrl));
  var all = false;
  DateTime desde = DateTime(Globals.periodo, 1, 1),
      hasta = DateTime(Globals.periodo, 12, 31);
  DropItemModel? centro;
  var me = {};

  late PlutoGridStateManager manager;
  late PlutoGridStateManager managerResumen;

  loadDataFromApi() async {
    me = await Globals.getMe();
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    loadDataFromApi();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery
        .of(context)
        .size;
    return Scaffold(
      body: WebSmoothScroll(
        controller: _scrollController,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _scrollController,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: size.height * 0.1,),
                Center(
                  child: Container(
                    color: Colors.blueGrey.withOpacity(0.3),
                    width: 500,
                    height: 500,
                    child: Stack(
                      children: [
                        Positioned(
                            left: 20,
                            top: 40,
                            child: Text(
                              'Generar Reporte por Centro de Costo'.toUpperCase(),
                              style: const TextStyle(fontSize: 20,
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold),)),
                        Positioned(
                            left: 30,
                            top: 80,
                            child: Column(
                              children: [
                                SizedBox(
                                  width: 400,
                                  height: 50,
                                  child: DropdownSearch<DropItemModel>(
                                    asyncItems: (f) =>
                                        dio.get(
                                            '/api/modules/get-centro-de-costos',
                                            queryParameters: {
                                              'clientId': me['clientId'],
                                              'tipo': 2
                                            }).then((value) =>
                                            (value.data as List)
                                                .map((e) =>
                                                DropItemModel(e['id'],
                                                    '${e['name']}(${e['code']})'))
                                                .toList()),
                                    dropdownDecoratorProps: const DropDownDecoratorProps(
                                      dropdownSearchDecoration: InputDecoration(
                                          labelText: 'Seleccionar Centro de Costo',
                                          labelStyle: TextStyle(
                                              color: Colors.blueAccent)
                                      ),
                                    ),
                                    onChanged: (v) {
                                      centro = v;
                                    },
                                  ),
                                ),
                                const SizedBox(height: 30,),
                                SizedBox(
                                    width: 400,
                                    height: 50,
                                    child: DateTimeFormField(
                                      dateFormat: DateFormat('dd/MM/yyyy'),
                                      initialValue: DateTime(
                                          Globals.periodo, 1, 1),
                                      decoration: const InputDecoration(
                                        labelStyle: TextStyle(
                                          color: Colors.blueAccent,),
                                        fillColor: Colors.blueAccent,
                                        border: OutlineInputBorder(),
                                        suffixIcon: Icon(Icons.event_note),
                                        labelText: 'Fecha de Desde',
                                      ),
                                      mode: DateTimeFieldPickerMode.date,
                                      autovalidateMode: AutovalidateMode.always,
                                      onDateSelected: (DateTime value) {
                                        desde = value;
                                      },
                                    )
                                ),
                                const SizedBox(height: 20,),
                                SizedBox(
                                    width: 400,
                                    height: 50,
                                    child: DateTimeFormField(
                                      dateFormat: DateFormat('dd/MM/yyyy'),
                                      initialValue: DateTime(
                                          Globals.periodo, 12, 31),
                                      decoration: const InputDecoration(
                                        labelStyle: TextStyle(
                                          color: Colors.blueAccent,),
                                        fillColor: Colors.blueAccent,
                                        border: OutlineInputBorder(),
                                        suffixIcon: Icon(Icons.event_note),
                                        labelText: 'Fecha de Hasta',
                                      ),
                                      mode: DateTimeFieldPickerMode.date,
                                      autovalidateMode: AutovalidateMode.always,
                                      onDateSelected: (DateTime value) {
                                        hasta = value;
                                      },
                                    )
                                ),
                                const SizedBox(height: 20,),
                                SizedBox(
                                  width: 400,
                                  height: 50,
                                  child: CheckboxListTile(
                                    title: const Text('Todos los Centro de Costo',
                                      style: TextStyle(
                                          color: Colors.blueAccent),),
                                    //    <-- label
                                    value: all,
                                    onChanged: (newValue) {
                                      setState(() {
                                        all = newValue ?? false;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(height: 20,),
                                SizedBox(width: 400,
                                  height: 50,
                                  child: ElevatedButton.icon(onPressed: () async {
                                    manager.refRows.clear();
                                    managerResumen.refRows.clear();
                                    setState(() {

                                    });
                                    EasyLoading.show(status: 'Generando Reporte');
                                    var result = await dio.post(
                                        '/api/reportes/generate-centro-costo-report',
                                        data: {
                                          'desde': desde.toIso8601String(),
                                          'hasta': hasta.toIso8601String(),
                                          'clientId': me['clientId'],
                                          'periodo': Globals.periodo,
                                          'centroCostoId': centro?.id ?? 0,
                                          'all': all
                                        });
                                    var list = result.data as List;
                                      listResumen = list.map((e) =>
                                          PlutoRow(cells: {
                                            'cuenta': PlutoCell(
                                                value: (e as Map)['cuenta']),
                                            'credito': PlutoCell(
                                                value: e['debe']),
                                            'debito': PlutoCell(
                                                value: e['haber']),
                                            'saldo': PlutoCell(value: e['saldo']),
                                          })).toList();
                                      managerResumen.insertRows(0, listResumen);
                                      listExpandedInfo = list.map((e) =>
                                          PlutoRow(cells: {
                                            'cuenta': PlutoCell(
                                                value: (e as Map)['cuenta']),
                                            'asiento': PlutoCell(value: '1'),
                                            'fecha': PlutoCell(value: ''),
                                            'comentario': PlutoCell(value: ''),
                                            'entidad': PlutoCell(value: ''),
                                            'comprobante': PlutoCell(value: ''),
                                            'modulo': PlutoCell(value: ''),
                                            'centro': PlutoCell(value: ''),
                                            'credito': PlutoCell(
                                                value: e['debe']),
                                            'debito': PlutoCell(
                                                value: e['haber']),
                                            'saldo': PlutoCell(value: e['saldo']),
                                          }, type: PlutoRowType.group(
                                              children: FilteredList<PlutoRow>(
                                                  initialList: (e['items'] as List)
                                                      .map((i) =>
                                                      PlutoRow(cells: {
                                                        'cuenta': PlutoCell(
                                                            value: (i as Map)['cuenta']),
                                                        'asiento': PlutoCell(
                                                            value: (i)['asiento']
                                                                .toString()),
                                                        'fecha': PlutoCell(
                                                            value: (i)['fecha']),
                                                        'comentario': PlutoCell(
                                                            value: (i)['comentario']),
                                                        'entidad': PlutoCell(
                                                            value: (i)['entidad']),
                                                        'comprobante': PlutoCell(
                                                            value: (i)['comprobante']),
                                                        'modulo': PlutoCell(
                                                            value: i['modulo']),
                                                        'centro': PlutoCell(
                                                            value: i['cuenta']),
                                                        'credito': PlutoCell(
                                                            value: i['debe']),
                                                        'debito': PlutoCell(
                                                            value: i['haber']),
                                                        'saldo': PlutoCell(
                                                            value: i['saldo']),
                                                      })).toList()
                                              ),
                                              expanded: true))).toList();
                                      manager.insertRows(0, listExpandedInfo);
                                    setState(() {

                                    });
                                    EasyLoading.dismiss(animation: true);
                                   if(all){
                                     _scrollController.animateTo(
                                       _scrollController.position.maxScrollExtent,
                                       duration: Duration(seconds: 2),
                                       curve: Curves.fastOutSlowIn,
                                     );
                                   }
                                    },
                                      icon: const FaIcon(
                                          FontAwesomeIcons.chartLine),

                                      label: const Text('Generar Reporte')),
                                )
                              ],
                            )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20,),
                  SizedBox(width: size.width, height: size.height,
                    child: PlutoGrid(
                        columns: [
                          PlutoColumn(title: 'CENTRO',
                              field: 'cuenta',
                              type: PlutoColumnType.text(),
                              width: 250),
                          PlutoColumn(title: 'ASIENTO',
                              field: 'asiento',
                              type: PlutoColumnType.text(),
                              width: 100),
                          PlutoColumn(title: 'FECHA',
                              field: 'fecha',
                              type: PlutoColumnType.text(),
                              width: 120),
                          PlutoColumn(title: 'COMENTARIO',
                              field: 'comentario',
                              type: PlutoColumnType.text(),
                              width: 250),
                          PlutoColumn(title: 'ENTIDAD',
                              field: 'entidad',
                              type: PlutoColumnType.text(),
                              width: 200),
                          PlutoColumn(title: 'COMPROBANTE',
                              field: 'comprobante',
                              type: PlutoColumnType.text(),
                              width: 200),
                          PlutoColumn(title: 'MODULO',
                              field: 'modulo',
                              type: PlutoColumnType.text(),
                              width: 100),
                          PlutoColumn(title: 'CUENTA',
                              field: 'centro',
                              type: PlutoColumnType.text(),
                              width: 250),
                          PlutoColumn(title: 'CREDITO',
                              field: 'credito',
                              type: PlutoColumnType.currency(
                                  symbol: '', decimalDigits: 0),
                              width: 150),
                          PlutoColumn(title: 'DEBITO',
                              field: 'debito',
                              type: PlutoColumnType.currency(
                                  symbol: '', decimalDigits: 0),
                              width: 150),
                          PlutoColumn(title: 'SALDO',
                              field: 'saldo',
                              type: PlutoColumnType.currency(
                                  symbol: '', decimalDigits: 0),
                              width: 150),
                        ],
                        rows: [],
                        onLoaded: (PlutoGridOnLoadedEvent e) {
                          manager = e.stateManager;
                          manager.setRowGroup(
                            PlutoRowGroupByColumnDelegate(
                              enableCompactCount: true,
                              showCount: false,
                              columns: [
                                manager.columns[0],
                              ],
                              showFirstExpandableIcon: true,
                            ),
                          );
                        },
                        configuration: const PlutoGridConfiguration(
                            style: PlutoGridStyleConfig(
                                columnHeight: 20,
                                rowHeight: 20,
                                columnTextStyle: TextStyle(
                                    fontSize: 15, color: Colors.black87),
                                cellTextStyle: TextStyle(
                                    fontSize: 15, color: Colors.blue)
                            ))
                    ),
                  ),
                const SizedBox(height: 10,),
                  Text('Resumnes:',style: TextStyle(fontSize: 40),),
                  SizedBox(width: size.width, height: size.height,
                    child: PlutoGrid(
                        columns: [
                          PlutoColumn(title: 'CENTRO',
                              field: 'cuenta',
                              type: PlutoColumnType.text(),
                              width: 500),
                          PlutoColumn(title: 'CREDITO',
                              field: 'credito',
                              type: PlutoColumnType.currency(
                                  symbol: '', decimalDigits: 0),
                              width: 200),
                          PlutoColumn(title: 'DEBITO',
                              field: 'debito',
                              type: PlutoColumnType.currency(
                                  symbol: '', decimalDigits: 0),
                              width: 200),
                          PlutoColumn(title: 'SALDO',
                              field: 'saldo',
                              type: PlutoColumnType.currency(
                                  symbol: '', decimalDigits: 0),
                              width: 200),
                        ],
                        rows: [],
                        onLoaded: (PlutoGridOnLoadedEvent e) {
                          managerResumen = e.stateManager;
                        },
                        configuration: const PlutoGridConfiguration(
                            style: PlutoGridStyleConfig(
                                columnHeight: 20,
                                rowHeight: 20,
                                columnTextStyle: TextStyle(
                                    fontSize: 15, color: Colors.black87),
                                cellTextStyle: TextStyle(
                                    fontSize: 15, color: Colors.blue)
                            ))
                    ),
                  )
              ]
          ),
        ),
      ),
    );
  }
}
