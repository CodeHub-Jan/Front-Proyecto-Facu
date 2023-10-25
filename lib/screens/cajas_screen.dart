import 'package:centyneg_sys/commons/Globals.dart';
import 'package:centyneg_sys/commons/app_color.dart';
import 'package:centyneg_sys/models/items_models.dart';
import 'package:centyneg_sys/providers/sys_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';

class CajaScreen extends StatefulWidget {
  const CajaScreen({super.key});

  @override
  State<CajaScreen> createState() => _CajaScreenState();
}

class _CajaScreenState extends State<CajaScreen> {
  @override
  Widget build(BuildContext context) {
    var provider= Provider.of<SysDataProvider>(context);
    var size=MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColor.white),
        title: Text(
          'Listado de Cajas', style: TextStyle(color: AppColor.white),),
        backgroundColor: AppColor.darkBlue,),
      body:SingleChildScrollView(
        child: Column(
          children: [
Container(
  width: size.width,
  height: 1000,
  child: PlutoGrid(
    columns: [
      PlutoColumn(title: 'ID', field: 'id', type: PlutoColumnType.number(), readOnly: true, width: 250,
        renderer: (rendererContext) {
          return Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.add_circle,
                ),
                onPressed: () {
                  rendererContext.stateManager.insertRows(
                      rendererContext.rowIdx,[
                    PlutoRow(cells: {
                      'id': PlutoCell(value: 0),
                      'name': PlutoCell(value: ''),
                      'vigencia': PlutoCell(value: DateTime.now()),
                      'vencimiento': PlutoCell(value: DateTime.now()),
                      'sucursal': PlutoCell(value: ItemModel(0,'')),
                      'codigo': PlutoCell(value: 0),
                      'desde': PlutoCell(value:0),
                      'hasta': PlutoCell(value:0),
                      'timbrado': PlutoCell(value: ''),
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
                onPressed: () async {
                  if(rendererContext.stateManager.refRows.length==1) {
                    return;
                  }
                  var row= rendererContext.row;
                  var result=await provider.borrarCaja(row.cells['id']?.value ?? 0);
                if(result){
                  rendererContext.stateManager
                      .removeRows([rendererContext.row]);
                }else{
                  Globals.showMessage('NO SE PUEDE ELIMINAR ESTE TIPO DE PAGO, YA QUE ESTA ASOCIADO A UN ASIENTO, MODULO U OPERACIÓN', context);
                }
                },
                iconSize: 18,
                color: Colors.red,
                padding: const EdgeInsets.all(0),
              ),
              IconButton(
                icon: const Icon(
                  Icons.save,
                ),
                onPressed: () async {
var row= rendererContext.row;
var result= await provider.registrarCaja({
  'id':row.cells['id']?.value ?? 0,
  'codigo':row.cells['codigo']?.value,
  'sucursalId':row.cells['sucursal']?.value.id,
  'descripcion':row.cells['name']?.value,
  'vigencia':row.cells['vigencia']?.value,
  'vencimiento':row.cells['vencimiento']?.value,
  'desde':row.cells['desde']?.value,
  'hasta':row.cells['hasta']?.value,
  'timbrado':row.cells['timbrado']?.value,
});
if(result != 0){
  row.cells['id']?.value=result;
}
                },
                iconSize: 18,
                color: Colors.blueAccent,
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
      PlutoColumn(title: 'DESC', field: 'name', type: PlutoColumnType.text(), width: 300),
      PlutoColumn(title: 'FECHA VIGENCIA DESDE', field: 'vigencia', type: PlutoColumnType.date(), width: 200),
      PlutoColumn(title: 'FECHA VIGENCIA FIN', field: 'vencimiento', type: PlutoColumnType.date(), width: 200),
      PlutoColumn(title: 'SUCURSAL', field: 'sucursal', type: PlutoColumnType.select(provider.sucursales)),
      PlutoColumn(title: 'CODIGO', field: 'codigo', type: PlutoColumnType.number()),
      PlutoColumn(title: 'DESDE', field: 'desde', type: PlutoColumnType.number(),width: 100),
      PlutoColumn(title: 'HASTA', field: 'hasta', type: PlutoColumnType.number(),width: 100),
      PlutoColumn(title: 'TIMBRADO', field: 'timbrado', type: PlutoColumnType.text(),width: 150),
    ],
    rows: provider.cajasGestion.map((e) =>  PlutoRow(cells: {
      'id': PlutoCell(value: e['id']),
      'name': PlutoCell(value: e['descripcion']),
      'vigencia': PlutoCell(value: e['fechaDesde']),
      'vencimiento': PlutoCell(value: e['fechaHasta']),
      'sucursal': PlutoCell(value: ItemModel(e['sucursal']['id'],e['sucursal']['desc'])),
      'codigo': PlutoCell(value: e['codigo']),
      'desde': PlutoCell(value: e['desde']),
      'hasta': PlutoCell(value:e['hasta']),
      'timbrado': PlutoCell(value: e['timbrado']),
    })).toList(),
  ),
)
          ],
        ),
      ) ,
    );
  }
}
