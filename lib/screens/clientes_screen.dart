import 'package:centyneg_sys/providers/product_provider.dart';
import 'package:centyneg_sys/providers/sys_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';

import '../commons/app_color.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  late PlutoGridStateManager gridState;

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<SysDataProvider>(context);
    provider.getAllClientes()
    .then((value) => {
      gridState.refRows.clear(),
      gridState.insertRows(0, value.map((e) =>
          PlutoRow(cells: {
            'id': PlutoCell(value: e['id']),
            'ruc': PlutoCell(value: e['ruc']),
            'name': PlutoCell(value: e['fullName']),
            'address': PlutoCell(value: e['address'] ?? ''),
            'email': PlutoCell(value: e['email'] ?? ''),
            'registro': PlutoCell(value: e['registro']),
          })).toList())
    }
    );
    var size = MediaQuery
        .of(context)
        .size;
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColor.white),
        title: Text(
          'Mantenimiento de Entidades',
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
                       context.go('/registrar_cliente');
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
                       var clientes= await provider.getAllClientes();
                        gridState.refRows.clear();
                        gridState.insertRows(0,clientes.map((e) =>
                            PlutoRow(cells: {
                              'id': PlutoCell(value: e['id']),
                              'ruc': PlutoCell(value: e['ruc']),
                              'name': PlutoCell(value: e['fullName']),
                              'address': PlutoCell(value: e['address'] ?? ''),
                              'email': PlutoCell(value: e['email'] ?? ''),
                              'registro': PlutoCell(value: e['registro']),
                            })).toList() );
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
                  PlutoColumn(title: 'R.U.C.',
                      field: 'ruc',
                      type: PlutoColumnType.text(),
                      width: 150,readOnly: true),
                  PlutoColumn(title: 'NOMBRE COMPLETO',
                      field: 'name',
                      type: PlutoColumnType.text(),
                      width: 300,readOnly: true),
                  PlutoColumn(title: 'DIRECCIÓN',
                      field: 'address',
                      type: PlutoColumnType.text(),
                      width: 300,readOnly: true),
                  PlutoColumn(title: 'EMAIL',
                      field: 'email',
                      type: PlutoColumnType.text(),
                      width: 200,readOnly: true),
                  PlutoColumn(title: 'FECHA DE REGISTRO',
                      field: 'registro',
                      type: PlutoColumnType.text(),
                      width: 200,readOnly: true),
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
