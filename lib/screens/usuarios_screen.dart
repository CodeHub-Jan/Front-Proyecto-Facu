import 'package:centyneg_sys/models/items_models.dart';
import 'package:centyneg_sys/providers/product_provider.dart';
import 'package:centyneg_sys/providers/sys_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import '../commons/Globals.dart';
import '../commons/app_color.dart';

class UsuariosScreen extends StatefulWidget {
  final int clientId;
  const UsuariosScreen({super.key, required this.clientId});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  late PlutoGridStateManager gridState;

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<SysDataProvider>(context);
    provider.loadUsers(widget.clientId)
    .then((value) => {
      gridState.refRows.clear(),
      gridState.insertRows(0, value.map((e) => PlutoRow(cells: {
        'id':PlutoCell(value: e['id'] ?? 1),
        'name':PlutoCell(value: e['name'] ?? ''),
        'userName':PlutoCell(value: e['userName'] ?? ''),
        'last':PlutoCell(value: e['last'] ?? ''),
        'options': PlutoCell(value: '')
      })).toList())
    });
    var size = MediaQuery
        .of(context)
        .size;
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColor.white),
        title: Text(
          'Gestionar Usuarios',
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
                        context.go('/registrar_usuario/${widget.clientId}/0');
                      },
                      child: const Icon(
                        Icons.add,
                        size: 35,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 90,
                  height: 70,
                  child: FittedBox(
                    child: FloatingActionButton(
                      backgroundColor: AppColor.darkBlue,
                      onPressed: () async {
                       var usuarios= await provider.loadUsers(widget.clientId);
                       gridState.refRows.clear();
                       gridState.insertRows(0, usuarios.map((e) => PlutoRow(cells: {
                         'id':PlutoCell(value: e['id'] ?? 1),
                         'name':PlutoCell(value: e['name'] ?? ''),
                         'userName':PlutoCell(value: e['userName'] ?? ''),
                         'last':PlutoCell(value: e['last'] ?? ''),
                         'options': PlutoCell(value: '')
                       })).toList());
                      },
                      child: const Icon(
                        Icons.refresh,
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
                createFooter: (stateManager) {
                  stateManager.setPageSize(40, notify: false); // default 40
                  return PlutoPagination(stateManager);
                },
                configuration: const PlutoGridConfiguration(

                  columnFilter: PlutoGridColumnFilterConfig(

                    debounceMilliseconds: 0,
                  ),
                  style: PlutoGridStyleConfig(
                    cellTextStyle: TextStyle(fontSize: 13, color: Colors.blueAccent),
                    columnTextStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
                      type: PlutoColumnType.number(),
                      width: 100,
                  readOnly: true),
                  PlutoColumn(title: 'NOMBRE COMPLETO',
                      field: 'name',
                      type: PlutoColumnType.text()),
                  PlutoColumn(title: 'NOMBRE DE USUARIO',
                      field: 'userName',
                      type: PlutoColumnType.text()),
                  PlutoColumn(title: 'ULTIMO LOGIN',
                      field: 'last',
                      type: PlutoColumnType.text()),
                  PlutoColumn(title: 'OPCIONES',
                      field: 'options',
                      type: PlutoColumnType.text(),
                      width: 200,readOnly: true,
                    renderer: (rendererContext) {
                      return Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.password,
                            ),
                            onPressed: () {

                            },
                            iconSize: 25,
                            color: Colors.green,
                            padding: const EdgeInsets.all(0),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                            ),
                            onPressed: () async {
                              var row= rendererContext.row;
                              context.go('/registrar_usuario/${widget.clientId}/${row.cells['id']?.value ?? 0}');
                            },
                            iconSize: 25,
                            color: Colors.blue,
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
