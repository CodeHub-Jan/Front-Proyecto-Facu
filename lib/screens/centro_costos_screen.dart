import 'dart:html';

import 'package:centyneg_sys/commons/Globals.dart';
import 'package:centyneg_sys/providers/facturacion_provider.dart';
import 'package:centyneg_sys/providers/printing_provider.dart';
import 'package:centyneg_sys/providers/product_provider.dart';
import 'package:centyneg_sys/providers/sys_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';

import '../commons/app_color.dart';

class CentroDeCostosScreen extends StatefulWidget {
  const CentroDeCostosScreen({super.key});

  @override
  State<CentroDeCostosScreen> createState() => _CentroDeCostosScreenState();
}

class _CentroDeCostosScreenState extends State<CentroDeCostosScreen> {
  late PlutoGridStateManager gridState;
  var facturas=[];
  @override
  Widget build(BuildContext context) {
    var dataProvider = Provider.of<SysDataProvider>(context);


    dataProvider.getAllCentros()
        .then((value) =>
    {
      facturas = value,
      gridState.refRows.clear(),
      gridState.insertRows(0, facturas.map((e) =>
          PlutoRow(cells: {
            'id': PlutoCell(value: e['id']),
            'code': PlutoCell(value: e['code']),
            'name': PlutoCell(value: e['name']),
            'manager': PlutoCell(value: e['manager']),
            'phone': PlutoCell(value: e['phone']),
            'value': PlutoCell(value: e['value']),
            'opciones': PlutoCell(value: ''),
          })).toList())
    });

    var size = MediaQuery
        .of(context)
        .size;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColor.white),
        title: Text(
          'GESTION DE CENTRO DE COSTOS',
          style: TextStyle(color: AppColor.white),),
        backgroundColor: AppColor.darkBlue,),
      body: SingleChildScrollView(

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10,),
            Row(
              children: [
                SizedBox(
                  width: 90,
                  height: 70,
                  child: FittedBox(
                    child: FloatingActionButton(
                      backgroundColor: AppColor.darkBlue,
                      onPressed: () async {
context.go('/registrar_centro_costo');
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
            const SizedBox(height: 20,),
            SizedBox(
              width: size.width,
              height: size.height * 0.90,
              child: PlutoGrid(
                configuration: const PlutoGridConfiguration(
                  columnFilter: PlutoGridColumnFilterConfig(
                    debounceMilliseconds: 0,
                  ),
                  style: PlutoGridStyleConfig(
                    cellTextStyle: TextStyle(fontSize: 13,
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
                  PlutoColumn(title: 'CODIGO.',
                      field: 'code',
                      type: PlutoColumnType.text(),
                      width: 100,
                      readOnly: true),
                  PlutoColumn(title: 'NOMBRE.',
                      field: 'name',
                      type: PlutoColumnType.text(),
                      width: 300,
                      readOnly: true),
                  PlutoColumn(title: 'MANAGER.',
                      field: 'manager',
                      type: PlutoColumnType.text(),
                      width: 150,
                      readOnly: true),
                  PlutoColumn(title: 'TELEFONO.',
                      field: 'phone',
                      type: PlutoColumnType.text(),
                      width: 150,
                      readOnly: true),
                  PlutoColumn(title: 'VALOR.',
                      field: 'value',
                      type: PlutoColumnType.currency(symbol: '',decimalDigits: 0),
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
                              Icons.cancel_outlined,
                            ),
                            onPressed: () async {
                              var row= rendererContext.row;
var result= await dataProvider.borrarCentroDeCosto(row.cells['id']?.value);
if(result){
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
                ], rows: []
                , onLoaded: (a) {
                gridState = a.stateManager;
                a.stateManager.setShowColumnFilter(true);
              },
              ),
            )
          ],
        ),
      ),
    );
  }
}
