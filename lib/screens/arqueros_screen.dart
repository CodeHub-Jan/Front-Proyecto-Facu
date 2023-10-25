import 'dart:html';

import 'package:centyneg_sys/commons/Globals.dart';
import 'package:centyneg_sys/providers/facturacion_provider.dart';
import 'package:centyneg_sys/providers/printing_provider.dart';
import 'package:centyneg_sys/providers/product_provider.dart';
import 'package:centyneg_sys/providers/sys_data_provider.dart';
import 'package:centyneg_sys/widgets/loading_widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';
import 'package:slide_switcher/slide_switcher.dart';

import '../commons/app_color.dart';

class ArqueosScreen extends StatefulWidget {
  const ArqueosScreen({super.key});

  @override
  State<ArqueosScreen> createState() => _ArqueosScreenState();
}

class _ArqueosScreenState extends State<ArqueosScreen> {
  final dio= Dio(BaseOptions(baseUrl: Globals.apiUrl));
  var isLoading = true;
  late PlutoGridStateManager gridState;
  late PlutoGridStateManager gridBoucherState;
  late SysDataProvider dataProvider;
  var selectIndex = 0;
  List<PlutoRow> arqueos = [];
  List<PlutoRow> bouchers = [];
  List<PlutoRow> tipoDeCuentas = [];
  @override
  void initState() {
    dataProvider = Provider.of<SysDataProvider>(context, listen: false);
    loadDataFromApi();
    super.initState();
  }

  loadDataFromApi() async {
    var arqueosProvider = await dataProvider.getArqueos();
    var bouchersProvider = await dataProvider.getBouchers();
    var tipoDeCuentasProvider = await dataProvider.getTiposDeCuentasList();
    arqueos = arqueosProvider.map((e) =>
        PlutoRow(cells: {
          'id': PlutoCell(value: e['id']),
          'encargado': PlutoCell(value: e['encargado']),
          'fecha': PlutoCell(value: e['fecha']),
          'inicial': PlutoCell(value: e['inicial']),
          'rendicion': PlutoCell(value: e['rendicion']),
          'saldo': PlutoCell(value: e['saldo']),
          'tipoPago': PlutoCell(value: e['tipoPago']),
          'estado': PlutoCell(value: e['estado']),
          'opciones': PlutoCell(value: ''),
        }
        )).toList();
    bouchers = bouchersProvider.map((e) =>
        PlutoRow(cells: {
          'id': PlutoCell(value: e['id']),
          'encargado': PlutoCell(value: e['encargado']),
          'code': PlutoCell(value: e['code']),
          'estado': PlutoCell(value: e['estado']),
          'opciones': PlutoCell(value: ''),
        }
        )).toList();
    tipoDeCuentas = tipoDeCuentasProvider.map((e) =>
        PlutoRow(cells: {
          'id': PlutoCell(value: e['id']),
          'name': PlutoCell(value: e['name']),
          'operacion': PlutoCell(value: e['operacion']),
          'cuenta': PlutoCell(value: e['cuenta']),
          'opciones': PlutoCell(value: ''),
        }
        )).toList();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery
        .of(context)
        .size;
      return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.attach_money_outlined),text: 'Gestion de Arqueos'),
              Tab(icon: Icon(Icons.document_scanner_sharp),text: 'Gestion de Lotes'),
              Tab(icon: Icon(Icons.account_balance),text: 'Gestion de Tipos de Cuentas'),
            ],
          ),
          title: const Text('Gestion de Arqueos, Lotes y Tipos de Cuenta'),
        ),
        body: isLoading ? const LoadingWidget() : TabBarView(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 5,),
                  Row(
                    children: [
                      SizedBox(
                        width: 90,
                        height: 70,
                        child: FittedBox(
                          child: FloatingActionButton(
                            backgroundColor: AppColor.darkBlue,
                            onPressed: () async {
                              context.go('/registar-arqueo');
                            },
                            child: const Icon(
                              Icons.add,
                              size: 35,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5,),
                  SizedBox(
                    width: size.width,
                    height: size.height * 0.70,
                    child: PlutoGrid(
                      configuration: const PlutoGridConfiguration(
                        columnFilter: PlutoGridColumnFilterConfig(
                          debounceMilliseconds: 0,
                        ),
                        style: PlutoGridStyleConfig(
                          cellTextStyle: TextStyle(fontSize: 15,
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold),
                          columnTextStyle: TextStyle(fontSize: 15),
                          rowHeight: 25,
                          columnHeight: 30,
                        ),
                        scrollbar: PlutoGridScrollbarConfig(
                          isAlwaysShown: true,
                          draggableScrollbar: true,
                        ),
                        enableMoveDownAfterSelecting: false,
                        columnSize: PlutoGridColumnSizeConfig(
                            restoreAutoSizeAfterInsertColumn: true),
                        enterKeyAction: PlutoGridEnterKeyAction.toggleEditing,

                      ),
                      columns: [
                        PlutoColumn(title: 'ID.',
                            field: 'id',
                            type: PlutoColumnType.text(),
                            width: 0,
                            readOnly: true),
                        PlutoColumn(title: 'ENCARGADO.',
                            field: 'encargado',
                            type: PlutoColumnType.text(),
                            width: 150,
                            readOnly: true),
                        PlutoColumn(title: 'FECHA APERTURA.',
                            field: 'fecha',
                            type: PlutoColumnType.text(),
                            width: 200,
                            readOnly: true),
                        PlutoColumn(title: 'MONTO INI.',
                            field: 'inicial',
                            type: PlutoColumnType.currency(decimalDigits: 0,
                                symbol: ''),
                            width: 150,
                            readOnly: true),
                        PlutoColumn(title: 'MONTO REND.',
                            field: 'rendicion',
                            type: PlutoColumnType.currency(decimalDigits: 0,
                                symbol: ''),
                            width: 150,
                            readOnly: true),
                        PlutoColumn(title: 'SALDO.',
                            field: 'saldo',
                            type: PlutoColumnType.currency(decimalDigits: 0,
                                symbol: ''),
                            width: 150,
                            readOnly: true),
                        PlutoColumn(title: 'TIPO DE PAGO.',
                            field: 'tipoPago',
                            type: PlutoColumnType.text(),
                            width: 150,
                            readOnly: true),
                        PlutoColumn(title: 'ESTADO.',
                            field: 'estado',
                            type: PlutoColumnType.text(),
                            width: 150,
                            readOnly: true),
                        PlutoColumn(title: 'OPCIONES',
                          field: 'opciones',
                          type: PlutoColumnType.text(),
                          width: 100,
                          readOnly: true,
                          renderer: (rendererContext) {
                            return Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.close_sharp,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    var row = rendererContext.row;
                                    var result = true;
                                    if (result) {
                                      window.location.reload();
                                    }
                                  },
                                  iconSize: 25,
                                  color: Colors.red,
                                  padding: const EdgeInsets.all(0),
                                ),
                              ],
                            );
                          },
                        ),
                      ], rows: arqueos
                      , onLoaded: (a) {
                      gridState = a.stateManager;
                      a.stateManager.setShowColumnFilter(true);
                    },
                    ),
                  )
                ],
              ),
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 5,),
                  Row(
                    children: [
                      SizedBox(
                        width: 90,
                        height: 70,
                        child: FittedBox(
                          child: FloatingActionButton(
                            backgroundColor: AppColor.darkBlue,
                            onPressed: () async {
                              context.go('/registar-boucher');
                            },
                            child: const Icon(
                              Icons.add,
                              size: 35,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5,),
                  SizedBox(
                    width: size.width,
                    height: size.height * 0.70,
                    child: PlutoGrid(
                      configuration: const PlutoGridConfiguration(
                        columnFilter: PlutoGridColumnFilterConfig(
                          debounceMilliseconds: 0,
                        ),
                        style: PlutoGridStyleConfig(
                          cellTextStyle: TextStyle(fontSize: 15,
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold),
                          columnTextStyle: TextStyle(fontSize: 15),
                          rowHeight: 25,
                          columnHeight: 30,
                        ),
                        scrollbar: PlutoGridScrollbarConfig(
                          isAlwaysShown: true,
                          draggableScrollbar: true,
                        ),
                        enableMoveDownAfterSelecting: false,
                        columnSize: PlutoGridColumnSizeConfig(
                            restoreAutoSizeAfterInsertColumn: true),
                        enterKeyAction: PlutoGridEnterKeyAction
                            .toggleEditing,

                      ),
                      columns: [
                        PlutoColumn(title: 'ID.',
                            field: 'id',
                            type: PlutoColumnType.text(),
                            width: 0,
                            readOnly: true),
                        PlutoColumn(title: 'CODIGO.',
                            field: 'code',
                            type: PlutoColumnType.text(),
                            width: 200,
                            readOnly: true),
                        PlutoColumn(title: 'ENCARGADO.',
                            field: 'encargado',
                            type: PlutoColumnType.text(),
                            width: 200,
                            readOnly: true),
                        PlutoColumn(title: 'ESTADO.',
                            field: 'estado',
                            type: PlutoColumnType.text(),
                            width: 150,
                            readOnly: true),
                        PlutoColumn(
                          title: 'OPCIONES',
                          field: 'opciones',
                          type: PlutoColumnType.text(),
                          width: 100,
                          readOnly: true,
                          renderer: (rendererContext) {
                            return Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    var row = rendererContext.row;
                                  var result=  await dio.delete('/arqueos/borrar-boucher', queryParameters: {
                                      'id':row.cells['id']?.value ?? 0
                                    });
                                    if (result.statusCode == 200) {
                                      window.location.reload();
                                    }
                                  },
                                  iconSize: 25,
                                  color: Colors.red,
                                  padding: const EdgeInsets.all(0),
                                ),
                              ],
                            );
                          },
                        ),
                      ], rows: bouchers
                      , onLoaded: (a) {
                      gridBoucherState = a.stateManager;
                      a.stateManager.setShowColumnFilter(true);
                    },
                    ),
                  )
                ],
              ),
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 5,),
                  Row(
                    children: [
                      SizedBox(
                        width: 90,
                        height: 70,
                        child: FittedBox(
                          child: FloatingActionButton(
                            backgroundColor: AppColor.darkBlue,
                            onPressed: () async {
                              context.go('/registar-tipo-de-cuenta');
                            },
                            child: const Icon(
                              Icons.add,
                              size: 35,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5,),
                  SizedBox(
                    width: size.width,
                    height: size.height * 0.70,
                    child: PlutoGrid(
                      configuration: const PlutoGridConfiguration(
                        columnFilter: PlutoGridColumnFilterConfig(
                          debounceMilliseconds: 0,
                        ),
                        style: PlutoGridStyleConfig(
                          cellTextStyle: TextStyle(fontSize: 15,
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold),
                          columnTextStyle: TextStyle(fontSize: 15),
                          rowHeight: 25,
                          columnHeight: 30,
                        ),
                        scrollbar: PlutoGridScrollbarConfig(
                          isAlwaysShown: true,
                          draggableScrollbar: true,
                        ),
                        enableMoveDownAfterSelecting: false,
                        columnSize: PlutoGridColumnSizeConfig(
                            restoreAutoSizeAfterInsertColumn: true),
                        enterKeyAction: PlutoGridEnterKeyAction
                            .toggleEditing,

                      ),
                      columns: [
                        PlutoColumn(title: 'ID.',
                            field: 'id',
                            type: PlutoColumnType.number(),
                            width: 0,
                            readOnly: true),
                        PlutoColumn(title: 'NOMBRE.',
                            field: 'name',
                            type: PlutoColumnType.text(),
                            width: 200,
                            readOnly: true),
                        PlutoColumn(title: 'OPERACION.',
                            field: 'operacion',
                            type: PlutoColumnType.text(),
                            width: 120,
                            readOnly: true),
                        PlutoColumn(title: 'CUENTA.',
                            field: 'cuenta',
                            type: PlutoColumnType.text(),
                            width: 300,
                            readOnly: true),
                        PlutoColumn(
                          title: 'OPCIONES',
                          field: 'opciones',
                          type: PlutoColumnType.text(),
                          width: 100,
                          readOnly: true,
                          renderer: (rendererContext) {
                            return Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    var row = rendererContext.row;
                                    var result = await dataProvider.borrarTipoDeCuenta(row.cells['id']?.value ?? 0);
                                    if (result) {
                                      window.location.reload();
                                    }
                                  },
                                  iconSize: 25,
                                  color: Colors.red,
                                  padding: const EdgeInsets.all(0),
                                ),
                              ],
                            );
                          },
                        ),
                      ], rows: tipoDeCuentas
                      , onLoaded: (a) {
                      gridBoucherState = a.stateManager;
                      a.stateManager.setShowColumnFilter(true);
                    },
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

}
