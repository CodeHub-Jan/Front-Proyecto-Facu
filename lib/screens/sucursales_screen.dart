import 'package:centyneg_sys/commons/Globals.dart';
import 'package:centyneg_sys/commons/app_color.dart';
import 'package:centyneg_sys/models/items_models.dart';
import 'package:centyneg_sys/providers/facturacion_provider.dart';
import 'package:centyneg_sys/providers/sys_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';

class SucursalesScreen extends StatefulWidget {
  const SucursalesScreen({super.key});

  @override
  State<SucursalesScreen> createState() => _SucursalesScreenState();
}

class _SucursalesScreenState extends State<SucursalesScreen> {
  late PlutoGridStateManager gridState;
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<FacturacionProvider>(context);
    provider.getSucursales().then((value) => {
      gridState.refRows.clear(),
      gridState.insertRows(0, value.map((e) =>
      PlutoRow(cells: {
        'id':PlutoCell(value: e['id']),
        'name':PlutoCell(value: e['name']),
        'encargado':PlutoCell(value: e['encargado']),
        'codigo':PlutoCell(value: e['codigo']),
        'telefono':PlutoCell(value: e['telefono']),
        'direccion':PlutoCell(value: e['direccion']),
        'opciones':PlutoCell(value: ''),
      })
      ).toList())
    });
    var size = MediaQuery
        .of(context)
        .size;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColor.white),
        title: Text(
          'Listado de Sucursales', style: TextStyle(color: AppColor.white),),
        backgroundColor: AppColor.darkBlue,),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: size.width,
              height: 1000,
              child: PlutoGrid(
                onLoaded: (a)=> gridState=a.stateManager,
                columns: [
                  PlutoColumn(
                    title: 'ID',
                    field: 'id',
                    type: PlutoColumnType.number(),
                    readOnly: true,
                    width: 250,
                    renderer: (rendererContext) {
                      return Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.add_circle,
                            ),
                            onPressed: () {
                              rendererContext.stateManager.insertRows(
                                  rendererContext.rowIdx, [
                                PlutoRow(cells: {
                                  'id':PlutoCell(value: 0),
                                  'name':PlutoCell(value:''),
                                  'encargado':PlutoCell(value: ''),
                                  'codigo':PlutoCell(value:''),
                                  'telefono':PlutoCell(value: ''),
                                  'direccion':PlutoCell(value: ''),
                                  'opciones':PlutoCell(value: ''),
                                })
                              ]
                              );
                            },
                            iconSize: 18,
                            color: Colors.green,
                            padding: const EdgeInsets.all(0),
                          ),
                          Expanded(
                            child: Text(
                              rendererContext.row.cells[rendererContext.column
                                  .field]!.value
                                  .toString(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  PlutoColumn(title: 'DESC',
                      field: 'name',
                      type: PlutoColumnType.text(),
                      width: 300),
                  PlutoColumn(title: 'ENCARGADO',
                      field: 'encargado',
                      type: PlutoColumnType.text(),
                      width: 150),
                  PlutoColumn(title: 'CODIGO',
                      field: 'codigo',
                      type: PlutoColumnType.number(),
                      width: 100),
                  PlutoColumn(title: 'TELEFONO',
                      field: 'telefono',
                      type: PlutoColumnType.text(),
                      width: 100),
                  PlutoColumn(title: 'DIRECCION',
                      field: 'direccion',
                      type: PlutoColumnType.text(),
                      width: 250),
                  PlutoColumn(
                    title: 'OPCIONES',
                    field: 'opciones',
                    type: PlutoColumnType.text(),
                    width: 70,
                    renderer: (rendererContext) {
                      return Row(
                        children: [

                          IconButton(
                            icon: const Icon(
                              Icons.save,
                            ),
                            onPressed: () async {
                              var row = rendererContext.row;
                              var result = await provider.registrarSucursal({
                                'id': row.cells['id']?.value ?? 0,
                                'codigo': row.cells['codigo']?.value ?? '',
                                'encargado': row.cells['encargado']?.value ?? '',
                                'desc': row.cells['name']?.value ?? '',
                                'telefono': row.cells['telefono']?.value ?? '',
                                'direccion': row.cells['direccion']?.value ?? '',
                              });
                              if (result.isNotEmpty) {
                                row.cells['id']?.value=result['id'];
                                await Globals.showMessage(
                                    'Se ha guardado los cambios correctamente',
                                    context);
                              }
                            },
                            iconSize: 25,
                            color: Colors.blue,
                            padding: const EdgeInsets.all(0),
                          ),
                        ],
                      );
                    },)
                ],
                rows: [],
              ),
            )
          ],
        ),
      ),
    );
  }
}
