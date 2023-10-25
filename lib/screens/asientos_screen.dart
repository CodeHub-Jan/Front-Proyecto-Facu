import 'dart:html';

import 'package:centyneg_sys/commons/Globals.dart';
import 'package:centyneg_sys/providers/edit_data_provider.dart';
import 'package:centyneg_sys/providers/facturacion_provider.dart';
import 'package:centyneg_sys/providers/printing_provider.dart';
import 'package:centyneg_sys/providers/product_provider.dart';
import 'package:centyneg_sys/providers/sys_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';

import '../commons/app_color.dart';

class AsientosScreen extends StatefulWidget {
  const AsientosScreen({super.key});

  @override
  State<AsientosScreen> createState() => _AsientosScreenState();
}

class _AsientosScreenState extends State<AsientosScreen> {
  late PlutoGridStateManager gridState;
  var facturas=[];
  @override
  Widget build(BuildContext context) {
    var dataProvider = Provider.of<EditDataProvider>(context);


    dataProvider.getAsientos()
        .then((value) =>
    {
      facturas = value,
      gridState.refRows.clear(),
      gridState.insertRows(0, facturas.map((e) =>
          PlutoRow(cells: {
            'id': PlutoCell(value: e['id']),
            'comentario': PlutoCell(value: e['comentario']),
            'fecha': PlutoCell(value: e['fecha']),
            'comprobante': PlutoCell(value: e['numeroComprobante']),
            'asiento': PlutoCell(value: e['numeroAsiento']),
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
          'GESTION DE ASIENTOS',
          style: TextStyle(color: AppColor.white),),
        backgroundColor: AppColor.darkBlue,),
      body: SingleChildScrollView(

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  PlutoColumn(title: 'COMENTARIO.',
                      field: 'comentario',
                      type: PlutoColumnType.text(),
                      width: 300,
                      readOnly: true),
                  PlutoColumn(title: 'FECHA.',
                      field: 'fecha',
                      type: PlutoColumnType.text(),
                      width: 300,
                      readOnly: true),
                  PlutoColumn(title: 'COMPROBANTE.',
                      field: 'comprobante',
                      type: PlutoColumnType.text(),
                      width: 150,
                      readOnly: true),
                  PlutoColumn(title: 'Nº.',
                      field: 'asiento',
                      type: PlutoColumnType.text(),
                      width: 70,
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
var result=true;
if(result){
  window.location.reload();
}
                            },
                            iconSize: 25,
                            color: Colors.red,
                            padding: const EdgeInsets.all(0),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.edit_note_rounded,
                            ),
                            onPressed: () async {
                              var row= rendererContext.row;
                              var id= row?.cells['id']?.value ?? 0;
                              context.go('/gestion_asientos/$id');
                            },
                            iconSize: 25,
                            color: Colors.blueGrey,
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
