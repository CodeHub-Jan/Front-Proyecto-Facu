import 'package:centyneg_sys/commons/Globals.dart';
import 'package:centyneg_sys/commons/app_color.dart';
import 'package:centyneg_sys/models/items_models.dart';
import 'package:centyneg_sys/providers/sys_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';

class TipoPagoScreen extends StatefulWidget {
  const TipoPagoScreen({super.key});

  @override
  State<TipoPagoScreen> createState() => _TipoPagoScreenState();
}

class _TipoPagoScreenState extends State<TipoPagoScreen> {
  @override
  Widget build(BuildContext context) {
    var provider= Provider.of<SysDataProvider>(context);
    var size=MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColor.white),
        title: Text(
          'Tipos de Pago', style: TextStyle(color: AppColor.white),),
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
                      'tipo': PlutoCell(value: ItemModel(1,'')),
                      'moneda': PlutoCell(value: ItemModel(1,'')),
                      'cuenta': PlutoCell(value: ItemModel(1,'')),
                      'arqueo':PlutoCell(value: ItemModel(2,'NO')),
                      'operacion': PlutoCell(value: ItemModel(1,'')),
                    }),
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
                  var result=await provider.borrarTipoPago(row.cells['id']?.value ?? 0);
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
var result= await provider.registerTipoPago({
  'id':row.cells['id']?.value ?? 0,
  'name':row.cells['name']?.value,
  'tipo':row.cells['tipo']?.value.id,
  'monedaid':row.cells['moneda']?.value.id,
  'cuentaId':row.cells['cuenta']?.value.id,
  'arqueo':row.cells['arqueo']?.value.id == 1,
  'TipoOperacionId':row.cells['operacion']?.value.id,
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
      PlutoColumn(title: 'NOMBRE', field: 'name', type: PlutoColumnType.text(), width: 400),
      PlutoColumn(title: 'TIPO', field: 'tipo', type: PlutoColumnType.select([ItemModel(1, 'CONTADO'),ItemModel(2, 'CREDITO')])),
      PlutoColumn(title: 'MONEDA', field: 'moneda', type: PlutoColumnType.select(
        provider.monedas.map((e) => ItemModel(e['id'], '${e['name']} (${e['flag']})')).toList()
      )),
      PlutoColumn(title: 'CUENTA CONTABLE', field: 'cuenta', type: PlutoColumnType.select(provider.cuentasImputables, enableColumnFilter: true),width: 300),
      PlutoColumn(title: 'OPERACION( MODULO )', field: 'operacion', type: PlutoColumnType.select(provider.tipoOperaciones),width: 300),
      PlutoColumn(title: 'ARQUEO', field: 'arqueo', type: PlutoColumnType.select([ItemModel(1, 'SI'),ItemModel(2, 'NO')]),width: 130),
    ],
    rows: provider.allPagos.map((e) =>  PlutoRow(cells: {
      'id': PlutoCell(value: e['id']),
      'name': PlutoCell(value: e['name']),
      'tipo': PlutoCell(value: ItemModel(e['tipo']['id'],e['tipo']['name'])),
      'moneda': PlutoCell(value: ItemModel(e['moneda']['id'],e['moneda']['name'])),
      'cuenta': PlutoCell(value: ItemModel(e['cuenta']['id'],e['cuenta']['name'],arqueo: e['cuenta']['arqueo'])),
      'arqueo': PlutoCell(value: ItemModel(e['arqueo']['id'],e['arqueo']['name'])),
      'operacion': PlutoCell(value: ItemModel(e['operacion']['id'],e['operacion']['name'])),
    })).toList(),
    onChanged: (a){
    if(a.columnIdx==6){
      var cuenta= a.row.cells['cuenta']?.value;
      var arqueo= a.row.cells['arqueo']?.value;
      if(arqueo != null){
        print(arqueo.id);
        print(cuenta.arqueo);
        if(arqueo.id==1 && cuenta.arqueo == false){
          a.row.cells['arqueo']?.value= ItemModel(2, 'NO');
          Globals.showMessage('Estimado Usuario:\nPara Marcar un tipo de pago como Arqueo, la cuenta contable también debe de estar marcada como arqueo !', context);
        }
      }
    }
    },
  ),
)
          ],
        ),
      ) ,
    );
  }
}
