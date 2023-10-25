import 'package:centyneg_sys/commons/Globals.dart';
import 'package:centyneg_sys/widgets/custom_container.dart';
import 'package:centyneg_sys/widgets/loading_widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:localstorage/localstorage.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../commons/app_color.dart';

class TransferenciaScreen extends StatefulWidget {
  const TransferenciaScreen({super.key});

  @override
  State<TransferenciaScreen> createState() => _TransferenciaScreenState();
}

class _TransferenciaScreenState extends State<TransferenciaScreen> {
  var dio= Dio(BaseOptions(baseUrl: Globals.apiUrl));
  var isLoading= true;
  var me={};
  List<_Cuenta> cuentas=[];
  List<_Boucher> bouchers=[];
  List<_Centro> centros=[];
  List<_Entidad> entidades=[];
 late PlutoGridStateManager manager;

  var storage = LocalStorage(Globals.dataFileKeyName);
  @override
  void initState() {
    loadDataFromApi();
    // TODO: implement initState
    super.initState();
  }
loadDataFromApi() async {
    setState(() {
      isLoading=true;
    });
    me= await Globals.getMe();
    cuentas = ((await dio.get('/api/transfe/get-cuentas',queryParameters: {'clientId':me['clientId']})).data as List).map((e) => _Cuenta(e['name'], e['id'], e['arqueo'], e['centro'], e['sub'])).toList();
    bouchers = ((await dio.get('/api/arqueos/listar-bouchers',queryParameters: {'clientId':me['clientId']})).data as List).map((e) => _Boucher(e['code'], e['id'])).toList();
    centros = ((await dio.get('/api/modules/get-centro-de-costos',queryParameters: {'clientId':me['clientId']})).data as List).map((e) => _Centro('${e['name']}(${e['code']})', e['id'])).toList();
    entidades = ((await dio.get('/api/entidades/get-all-gestion',queryParameters: {'clientId':me['clientId']})).data as List).map((e) => _Entidad('${e['fullName']}(${e['ruc']})', e['id'])).toList();
    setState(() {
      isLoading=false;
    });
  }
  DateTime date= DateTime.now();
  var formData= GlobalKey<FormBuilderState>();
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: isLoading ? const LoadingWidget() : SingleChildScrollView(
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: Stack(
            children: [
              Positioned(
                  top: 30,
                  left: size.width * 0.2,
                  child: CustomContainer(
                    containerWith: size.width * 0.60,
                    containerHeight: size.height * 0.30,
                    child: Stack(
                      children:[
                        Positioned(
                          left: 20,
                          child: FormBuilder(
                            key: formData,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 700,
                                  child: FormBuilderTextField(
                                    cursorColor: Colors.indigo,
                                    name: 'comentario',
                                    decoration: const InputDecoration(labelText: 'Comentario',prefixIcon: Icon(Icons.info)),
                                  ),
                                ),
                                SizedBox(
                                  width: 350,
                                  child: FormBuilderDateTimePicker(
                                    cursorColor: Colors.indigo,
                                    name: 'fecha',
                                    decoration:  const InputDecoration(labelText: 'Fecha', prefixIcon: Icon(Icons.date_range)),
                                    onChanged: (a){
                                      date=a ?? DateTime.now();
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 350,
                                  child: FormBuilderTextField(
                                    cursorColor: Colors.indigo,
                                    name: 'numero',
                                    decoration: const InputDecoration(labelText: 'Nº Transferencia', prefixIcon: Icon(Icons.numbers_outlined)),
                                  ),
                                ),
                                const SizedBox(height: 20,),
                                MaterialButton(
                                  color: AppColor.darkBlue,
                                  textColor: Colors.white,
                                  onPressed: () async {

                                    var body= {
                                      'periodo': Globals.periodo,
                                      'comentario': formData.currentState?.fields['comentario']?.value ?? '',
                                      'fecha': date.toIso8601String() ?? '',
                                      'clientId': me['clientId'],
                                      'userId': me['id'],
                                      'sucursalId': storage.getItem('sucursal'),
                                      'comprobante': formData.currentState?.fields['numero']?.value ?? '',
                                      'detalle': manager.refRows.map((e) => {
                                        'cuentaId' : e.cells['cuenta']?.value.id,
                                        'boucherId' : e.cells['boucher']?.value.id == 0 ? null:e.cells['boucher']?.value.id,
                                        'entidadId' :  e.cells['entidad']?.value.id == 0 ? null :  e.cells['entidad']?.value.id,
                                        'centroId' : e.cells['centro']?.value.id==0 ? null : e.cells['centro']?.value.id,
                                        'credito' : e.cells['credito']?.value,
                                        'debito' : e.cells['debito']?.value,
                                      }).toList()
                                    };
                                    var result= await dio.post('/api/transfe/generar-asiento',data: body);
                                    manager.refRows.clear();
                                    formData.currentState?.reset();
                                  },
                                  child: const Text('Registrar Operación'),
                                )
                              ],
                            ),
                          ),
                        ),
                         Positioned(
                            bottom: 20,
                            right: 30,
                            child: Row(
                          children: [
                            InkWell(child: const FaIcon(FontAwesomeIcons.add, color: Colors.green, size: 50,),onTap: (){
                              var rowCount= manager.refRows.length;
                              manager.insertRows(rowCount, [
                                PlutoRow(cells: {
                                  'cuenta':PlutoCell(value:''),
                                  'boucher':PlutoCell(value: ''),
                                  'entidad':PlutoCell(value: ''),
                                  'centro':PlutoCell(value: ''),
                                  'credito':PlutoCell(value: 0),
                                  'saldo':PlutoCell(value: 0),
                                  'debito':PlutoCell(value: 0),
                                })
                              ]);
                            },),
                            const SizedBox(width: 10,),
                            InkWell(child: const FaIcon(FontAwesomeIcons.remove, color: Colors.red,size: 50,), onTap: (){
                              manager.removeCurrentRow();
                            },),
                          ],
                        ))
                      ]
                    ),
                  )),
              Positioned(
                  top: 320,
                  left: size.width * 0.2,
                  child: CustomContainer(
                    containerWith: size.width * 0.60,
                    containerHeight: size.height * 0.50,
                    child: Stack(
                        children:[
                          PlutoGrid(
                            onSelected: (a){

                            },
                              onLoaded: (a)=> manager=a.stateManager,
                              onChanged: (a) async{
if(a.columnIdx==0){
  var row= a.row;
  var cuenta= row.cells['cuenta']?.value as _Cuenta;
  row.cells['entidad']?.value = cuenta.sub ? _Entidad('(SELECCIONAR)', 0) : _Entidad('(N/A)', 0);
  row.cells['boucher']?.value = cuenta.arqueo ? _Boucher('(SELECCIONAR)', 0) : _Boucher('(N/A)', 0);
  row.cells['centro']?.value = cuenta.centro ? _Centro('(SELECCIONAR)', 0) : _Centro('(N/A)', 0);
  row.cells['saldo']?.value = 0;
}
if(a.columnIdx == 1){
  var row= a.row;
  var cuenta= row.cells['boucher']?.value as _Boucher;
  row.cells['saldo']?.value = await getBoucherSaldo(cuenta.id);
}
                              },
                              configuration: const PlutoGridConfiguration(
                                style: PlutoGridStyleConfig(
                                  columnHeight: 20,
                                  cellTextStyle: TextStyle(fontSize: 13, color: Colors.blue),
                                  rowHeight: 23
                                ),
                                enterKeyAction: PlutoGridEnterKeyAction.toggleEditing
                              ),
                              columns: [
                            PlutoColumn(title: 'CUENTA', field: 'cuenta', type: PlutoColumnType.select(cuentas), width: 200),
                            PlutoColumn(title: 'BOUCHER', field: 'boucher', type: PlutoColumnType.select(bouchers), width: 200),
                                PlutoColumn(title: 'SALDO', field: 'saldo', type: PlutoColumnType.currency(symbol: '',decimalDigits: 0), width: 100),
                            PlutoColumn(title: 'ENTIDAD', field: 'entidad', type: PlutoColumnType.select(entidades,enableColumnFilter: true),enableSetColumnsMenuItem: true, width: 200),
                            PlutoColumn(title: 'CENTRO COSTO', field: 'centro', type: PlutoColumnType.select(centros), width: 200),
                            PlutoColumn(title: 'CREDITO', field: 'credito', type: PlutoColumnType.currency(symbol: '',decimalDigits: 0), width: 120),
                            PlutoColumn(title: 'DEBITO', field: 'debito', type: PlutoColumnType.currency(symbol: '',decimalDigits: 0), width: 120),
                          ], rows: [])
                        ]
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
  Future<double> getBoucherSaldo(int id) async{
    var result= await dio.get('/api/arqueos/get-saldo-boucher',
    queryParameters: {
      'id':id
    }
    );
    return (result.data as Map)['saldoNumber'];
  }
}

class _Boucher{
  String title;

  _Boucher(this.title, this.id);

  int id;
  @override
  String toString() {
    // TODO: implement toString
    return title;
  }
}

class _Entidad{
  String title;

  _Entidad(this.title, this.id);

  int id;
  @override
  String toString() {
    // TODO: implement toString
    return title;
  }
}
class _Centro{
  String title;

  _Centro(this.title, this.id);

  int id;
  @override
  String toString() {
    // TODO: implement toString
    return title;
  }
}
class _Cuenta{
  String title;

  _Cuenta(this.title, this.id, this.arqueo, this.centro, this.sub);

  int id;
  bool arqueo;
  bool centro;
  bool sub;

  @override
  String toString() {
    // TODO: implement toString
    return title;
  }
}
