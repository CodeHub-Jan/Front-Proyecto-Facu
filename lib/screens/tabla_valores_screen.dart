import 'package:centyneg_sys/commons/Globals.dart';
import 'package:centyneg_sys/commons/app_color.dart';
import 'package:centyneg_sys/models/drop_item_model.dart';
import 'package:centyneg_sys/models/items_models.dart';
import 'package:centyneg_sys/providers/sys_data_provider.dart';
import 'package:centyneg_sys/widgets/loading_widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';

class TablaValoresScreen extends StatefulWidget {
  const TablaValoresScreen({super.key});

  @override
  State<TablaValoresScreen> createState() => _TablaValoresScreenState();
}

class _TablaValoresScreenState extends State<TablaValoresScreen> {
  final dio= Dio(BaseOptions(baseUrl: Globals.apiUrl));
  var isLoading=true;
  var items= [DropItemModel(2, "Marca"),DropItemModel(3, "COLOR"),DropItemModel(4, "PROCEDENCIA"),DropItemModel(5, "UNIDAD DE MEDIDA"),DropItemModel(2, "FAMILIA")];
var controller= TextEditingController();
  late PlutoGridStateManager manager;
  loadDataFromApi() async {
    me= await Globals.getMe();
    setState(() {
      isLoading=false;
    });
  }
  var me={};
  var formData= GlobalKey<FormBuilderState>();
  @override
  void initState() {
    loadDataFromApi();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var provider= Provider.of<SysDataProvider>(context);
    var size=MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColor.white),
        title: Text(
          'Tabla de Valores', style: TextStyle(color: AppColor.white),),
        backgroundColor: AppColor.darkBlue,),
      body: isLoading ? LoadingWidget() : SingleChildScrollView(
        child: Column(
          children: [
            FormBuilder(
        key: formData,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            SizedBox(
              width: 400,
              child: FormBuilderDropdown<DropItemModel>(
                items: items.map((e) => DropdownMenuItem<DropItemModel>(child: Text(e.title), value: e,)).toList(),
                onChanged: (a) async {
                  var result= await dio.get('/api/pro_modules/get-alll',
                  queryParameters: {
                    'clientId': me['clientId'],
                    'tipo':a?.id
                  }
                  );
                  manager.refRows.clear();
                  manager.insertRows(0, (result.data as List).map((e) => PlutoRow(cells: {
                    'id': PlutoCell(value: e['id']),
                    'desc': PlutoCell(value: e['name']),
                    'tipo': PlutoCell(value: e['tipo']),
                    'ope': PlutoCell(value: '')
                  })).toList());
                  setState(() {

                  });
                },
                name: 'tipos',
                decoration: const InputDecoration(labelText: 'Seleccionar el tipo'),
              ),
            ),
            SizedBox(
              width: 400,
              child: FormBuilderTextField(
                name: 'desc',
                controller: controller,
                decoration: const InputDecoration(labelText: 'DESCRIPCION'),
              ),
            ),
            const SizedBox(height: 10),
            MaterialButton(
              color: AppColor.darkBlue,
              textColor: Colors.white,
              onPressed: () async {
var result= await dio.post('/api/pro_modules/register',data: {
  'name' : controller.text,
  'clientId': me['clientId'],
  'tipo': formData.currentState?.fields['tipos']?.value.id
});
var data= await dio.get('/api/pro_modules/get-alll',
    queryParameters: {
      'clientId': me['clientId'],
      'tipo':formData.currentState?.fields['tipos']?.value.id
    }
);
manager.refRows.clear();
manager.insertRows(0, (data.data as List).map((e) => PlutoRow(cells: {
  'id': PlutoCell(value: e['id']),
  'desc': PlutoCell(value: e['name']),
  'tipo': PlutoCell(value: e['tipo']),
  'ope': PlutoCell(value: '')
})).toList());
setState(() {

});
controller.clear();
              },
              child: const Text('Registrar Datos'),
            )
            ],
          )),
SizedBox(height: 10,),
Container(
  width: size.width,
  height: 600,
  child: PlutoGrid(
    onLoaded: (a){
      manager= a.stateManager;
    },
    columns: [
      PlutoColumn(title: 'ID.',
          field: 'id',
          type: PlutoColumnType.text(),
          width: 0,readOnly: true),
      PlutoColumn(title: 'DESCRIPCION.',
          field: 'desc',
          type: PlutoColumnType.text(),
          width: 500,readOnly: true),
      PlutoColumn(title: 'TIPO.',
          field: 'tipo',
          type: PlutoColumnType.text(),
          width: 300,readOnly: true),
      PlutoColumn(title: 'OPE.',
        field: 'ope',
        type: PlutoColumnType.text(),
        width: 200,readOnly: true,
        renderer: (rendererContext) {
          return Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.delete,
                ),
                onPressed: () async {
                  EasyLoading.show(status: 'Generando Reporte');
                  var id= rendererContext.row.cells['id']?.value;
                  var result= await dio.put('/api/pro_modules/delete',queryParameters: {
                    'id':id
                  });
                  rendererContext.stateManager
                      .removeRows([rendererContext.row]);
                  EasyLoading.dismiss(animation: true);
                },
                iconSize: 18,
                color: Colors.red,
                padding: const EdgeInsets.all(0),
              ),
            ],
          );
        },
      ),
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
