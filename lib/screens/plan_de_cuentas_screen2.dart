
import 'package:centyneg_sys/commons/app_color.dart';
import 'package:centyneg_sys/providers/sys_data_provider.dart';
import 'package:centyneg_sys/widgets/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:go_router/go_router.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';

import '../models/Node.dart';

class PlanDeCuentasScreen2 extends StatefulWidget {
  const PlanDeCuentasScreen2({super.key});

  @override
  State<PlanDeCuentasScreen2> createState() => _PlanDeCuentasScreen2State();
}

class _PlanDeCuentasScreen2State extends State<PlanDeCuentasScreen2> {
  late PlutoGridStateManager gridManager;



  @override
  Widget build(BuildContext context) {
    var provider= Provider.of<SysDataProvider>(context);
    var size=MediaQuery.of(context).size;
    provider.loadCuentasContables()
    .then((value) => {
      gridManager.refRows.clear(),
      gridManager.insertRows(0, value.map((e) => PlutoRow(cells: {
        'id': PlutoCell(value: e['id']),
        'nivel1': PlutoCell(value: e['nivel1']),
        'nivel2': PlutoCell(value: e['nivel2']),
        'nivel3': PlutoCell(value: e['nivel3']),
        'nivel4': PlutoCell(value: e['nivel4']),
        'code': PlutoCell(value: e['code']),
        'sub': PlutoCell(value: e['sub']),
        'impu': PlutoCell(value: e['impu']),
        'dep': PlutoCell(value: e['dep']),
        'arq': PlutoCell(value: e['arq']),
        'mod': PlutoCell(value: e['mod']),
        'centro': PlutoCell(value: e['centro']),
        'moneda': PlutoCell(value: e['moneda']),
        'opciones': PlutoCell(value: ''),
      })).toList())
    });
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColor.white),
        title: Text('Plan de Cuentas', style: TextStyle(color: AppColor.white),),backgroundColor: AppColor.darkBlue,),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            SizedBox(height: 20,),
            Container(
              child: ElevatedButton.icon(onPressed: (){
                context.go('/registrar_cuenta/0');
              }, icon: Icon(Icons.add), label: Text('Registrar nuevo plan de cuenta')),
            ),
            SizedBox(height: 20,),
            Container(
              width: size.width ,
              height: size.height ,
              child: PlutoGrid(
                createFooter: (stateManager) {
                  stateManager.setPageSize(30, notify: false); // default 40
                  return PlutoPagination(stateManager);
                },
                configuration: const PlutoGridConfiguration(
                    columnFilter: PlutoGridColumnFilterConfig(

                      debounceMilliseconds: 0,
                    ),
                  style: PlutoGridStyleConfig(
                      columnTextStyle: TextStyle(fontSize: 12,color: Colors.blue),
                      cellTextStyle: TextStyle(fontSize: 12,color: Colors.indigo, fontWeight: FontWeight.bold),
                    rowHeight: 50
                  )
                ),
                onLoaded: (a) {
                  gridManager=a.stateManager;
                  a.stateManager.setShowColumnFilter(true);
                },
              columns: [
                PlutoColumn(title: 'ID', field: 'id', type: PlutoColumnType.number(),width: 0,),
                PlutoColumn(title: 'NIVEL 1', field: 'nivel1', type: PlutoColumnType.text(),width: 150),
                PlutoColumn(title: 'NIVEL 2', field: 'nivel2', type: PlutoColumnType.text(),width: 250),
                PlutoColumn(title: 'NIVEL 3', field: 'nivel3', type: PlutoColumnType.text(),width: 250),
                PlutoColumn(title: 'CODIGO', field: 'code', type: PlutoColumnType.text(),width: 150),
                PlutoColumn(title: 'NIVEL 4', field: 'nivel4', type: PlutoColumnType.text(),width: 300),
                PlutoColumn(title: 'SUB. CUENTA', field: 'sub', type: PlutoColumnType.text(),width: 100),
                PlutoColumn(title: 'IMPUTABLE', field: 'impu', type: PlutoColumnType.text(),width: 100),
                PlutoColumn(title: 'CENTRO COSTO', field: 'centro', type: PlutoColumnType.text(),width: 100),
                PlutoColumn(title: 'ARQUEO', field: 'arq', type: PlutoColumnType.text(),width: 100),
                PlutoColumn(title: 'MODULO', field: 'mod', type: PlutoColumnType.text(),width: 100),
                PlutoColumn(title: 'DEPARTAMENTO', field: 'dep', type: PlutoColumnType.text(),width: 100),
                PlutoColumn(title: 'MONEDA', field: 'moneda', type: PlutoColumnType.text(),width: 100),
                PlutoColumn(title: 'OPCIONES.', field: 'opciones', type: PlutoColumnType.text(),width: 100,

                  renderer: (rendererContext) {
                    return Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                          ),
                          onPressed: () async {
        var id= rendererContext.row.cells['id']?.value;
        context.go('/registrar_cuenta/$id');
                          },
                          iconSize: 25,
                          color: Colors.blueGrey,
                          padding: const EdgeInsets.all(0),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.disabled_visible,
                          ),
                          onPressed: () async {

                          },
                          iconSize: 25,
                          color: Colors.blueGrey,
                          padding: const EdgeInsets.all(0),
                        ),
                      ],
                    );
                  },),
              ],
                rows: [],
              )
              ),
          ]
        ),
      ),
    );
  }
}

