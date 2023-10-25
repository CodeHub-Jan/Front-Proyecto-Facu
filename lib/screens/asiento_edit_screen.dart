import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:centyneg_sys/commons/Globals.dart';
import 'package:centyneg_sys/commons/ThousandsSeparatorInputFormatter.dart';
import 'package:centyneg_sys/commons/extensions.dart';
import 'package:centyneg_sys/models/items_models.dart';
import 'package:centyneg_sys/providers/edit_data_provider.dart';
import 'package:centyneg_sys/widgets/loading_widget.dart';
import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';

import '../commons/app_color.dart';

class AsientoEditScreen extends StatefulWidget {

  final int id;
  const AsientoEditScreen({super.key, required this.id});

  @override
  State<AsientoEditScreen> createState() => _AsientoEditScreenState();
}

class _AsientoEditScreenState extends State<AsientoEditScreen> {
  var libros=[DropdownMenuItem<ItemModel>(value: ItemModel(1,'LIBRO DE COMPRA'),child: const Text('LIBRO DE COMPRA'), ),
    DropdownMenuItem<ItemModel>(child: const Text('LIBRO DE VENTA'), value: ItemModel(2,''), ),
    DropdownMenuItem<ItemModel>(child: const Text('NO APLICA'), value: ItemModel(3,''), ),
  ];
  var asientoInfo= {};
  DateTime? fecha;
  ItemModel? entidad;
  late EditDataProvider provider;
  var formData = GlobalKey<FormBuilderState>();
  late List<ItemModel> cuentas;
  late List<ItemModel> entidades;
bool isLoading=true;
  var comentarioController= TextEditingController();
  var entidadController= TextEditingController();
  var gravada10Controller= TextEditingController();
  var gravada5Controller= TextEditingController();
  var iva5Controller= TextEditingController();
  var iva10Controller= TextEditingController();
  var exentaController= TextEditingController();
  var fechaController= TextEditingController();
  ItemModel? libro;
  @override
  void initState() {
    // TODO: implement initState
    provider = Provider.of<EditDataProvider>(context, listen: false);
loadDataFromApi();
  }
  loadDataFromApi() async{
    cuentas = (await provider.getCuentas()).map((e) => ItemModel(e['id'], e['name'])).toList();
    entidades = (await provider.getEntidades()).map((e) => ItemModel(e['id'],'${e['fullName']} - ${e['ruc']}')).toList();
    var asiento = await provider.loadAsientoToEdit(widget.id);
libro= ItemModel(asiento['libro']['id'], asiento['libro']['name']);
    asientoInfo=asiento;
    comentarioController.text=asiento['comentario'];
    entidadController.text=asiento['entidad']['name'];
    gravada10Controller.text=asiento['gravada10'].toString();
    gravada5Controller.text=asiento['gravada5'].toString();
    iva10Controller.text=asiento['iva10'].toString();
    iva5Controller.text=asiento['iva5'].toString();
    exentaController.text=asiento['exenta'].toString();
    fecha= DateTime.parse(asiento['fecha']);

setState(() {
  isLoading=false;
});
  }
  late PlutoGridStateManager gridManager;
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery
        .of(context)
        .size;

    return Scaffold(
      body: isLoading ? const LoadingWidget() :  SingleChildScrollView(
        child: Column(
          children: [
            Center(child: Container(
              width: size.width *2,
              height: size.height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30,),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                    width: size.width * 0.70,
                    height: size.height * 0.45,
                    color: Colors.blueAccent.withOpacity(0.10),
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
                                controller: comentarioController,

                                decoration: const InputDecoration(
                                    labelText: 'COMENTARIO'),

                              ),

                            ),

                            SizedBox(

                              width: 500,

                              child: FormBuilderTextField(

                                cursorColor: Colors.indigo,

                                name: 'entidad',
controller: entidadController,
                                decoration: const InputDecoration(
                                    labelText: 'CLIENTE'),

                              ),

                            ),
                            SizedBox(height: 10,),
                            SizedBox(
                                width: 200,
                                height: 50,
                                child: DateTimeFormField(
                                  dateFormat: DateFormat('dd/MM/yyyy'),
                                  initialValue: fecha,
                                  decoration: const InputDecoration(
                                    hintStyle: TextStyle(color: Colors.black45),
                                    errorStyle: TextStyle(color: Colors.redAccent),
                                    border: OutlineInputBorder(),
                                    suffixIcon: Icon(Icons.event_note),
                                    labelText: 'Fecha de Documento',
                                  ),
                                  mode: DateTimeFieldPickerMode.date,
                                  autovalidateMode: AutovalidateMode.always,
                                  onDateSelected: (DateTime value) {
                                    fecha=value;
                                  },
                                )
                            ),
                          Row(
                            children: [
                              SizedBox(
                                width: 250,
                                child: FormBuilderTextField(
                                  cursorColor: Colors.indigo,
                                  name: 'gravada10',
                                  inputFormatters: [ThousandsSeparatorInputFormatter()],
                                  controller: gravada10Controller,
                                  decoration: const InputDecoration(
                                      labelText: 'GRAVADA 10%'),
                                ),
                              ),
                              const SizedBox(width: 10,),
                              SizedBox(
                                width: 250,
                                child: FormBuilderTextField(
                                  cursorColor: Colors.indigo,
                                  name: 'iva10',
                                  inputFormatters: [ThousandsSeparatorInputFormatter()],
                                  controller: iva10Controller,
                                  decoration: const InputDecoration(
                                      labelText: 'IVA 10%'),
                                ),
                              ),
                            ],
                          ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 250,
                                  child: FormBuilderTextField(
                                    cursorColor: Colors.indigo,
                                    name: 'gravada5',
                                    inputFormatters: [ThousandsSeparatorInputFormatter()],
                                    controller: gravada5Controller,
                                    decoration: const InputDecoration(
                                        labelText: 'GRAVADA 5%'),
                                  ),
                                ),
                                const SizedBox(width: 10,),
                                SizedBox(
                                  width: 250,
                                  child: FormBuilderTextField(
                                    cursorColor: Colors.indigo,
                                    name: 'iva5',
                                    inputFormatters: [ThousandsSeparatorInputFormatter()],
                                    controller: iva5Controller,
                                    decoration: const InputDecoration(
                                        labelText: 'IVA 5%'),
                                  ),
                                ),
                              ],
                            ),
                          Row(
                            children: [
                              SizedBox(
                                width: 400,
                                child: FormBuilderTextField(
                                  cursorColor: Colors.indigo,
                                  name: 'exenta',
                                  inputFormatters: [ThousandsSeparatorInputFormatter()],
                                  controller: exentaController,
                                  decoration: const InputDecoration(
                                      labelText: 'EXENTA'),
                                ),
                              ),
                              const SizedBox(width: 10,),
                              SizedBox(
                                width: 400,
                                child: FormBuilderDropdown<ItemModel>(
                                  name: 'libros',
                                onChanged: (a){
libro=a;

                                },
                                items: libros,
                                  decoration: const InputDecoration(
                                      labelText: 'LIBRO CONTABLE'),
                                ),
                              ),
                              const SizedBox(width: 20,),
                              SizedBox(
                                width: 300,
                                height: 50,
                                child: MaterialButton(
                                  color: AppColor.darkBlue,
                                  textColor: Colors.white,
                                  onPressed: () async {
                                    var fields= formData.currentState?.fields;
var result= await provider.registrarCambios({
  'id':widget.id,
  'comentario':fields?['comentario']?.value,
  'fecha':fecha?.toIso8601String(),
  'gravada10': double.parse(fields?['gravada10']?.value.toString().limpiarNumeroParaFormateo() ?? '0'),
  'gravada5': double.parse(fields?['gravada5']?.value.toString().limpiarNumeroParaFormateo() ?? '0'),
  'iva10': double.parse(fields?['iva10']?.value.toString().limpiarNumeroParaFormateo() ?? '0'),
  'iva5': double.parse(fields?['iva5']?.value.toString().limpiarNumeroParaFormateo() ?? '0'),
  'exenta': double.parse(fields?['exenta']?.value.toString().limpiarNumeroParaFormateo() ?? '0'),
  'libro': libro?.id ?? 0,
  'detalle': gridManager.refRows.map((element) => {
    'id': element.cells['id']?.value,
    'entidadId': element.cells['entidad']?.value.id == 0 ? null : element.cells['entidad']?.value.id,
    'comentario': element.cells['comentario']?.value,
    'estado': element.cells['status']?.value.id,
    'cuentaId': element.cells['cuenta']?.value.id,
    'debe': element.cells['debe']?.value,
    'haber': element.cells['haber']?.value,

  }).toList()
});
if(result){
  await AwesomeDialog(
    context: context,
    width: 400,
btnCancel: null,
    dialogType: DialogType.success,
    animType: AnimType.topSlide,
    title: 'Asiento Editado Correctamente',
    desc: 'Se ha editado correctamente el Asiento Nº${widget.id}, Operación Exitosa!',
    descTextStyle: TextStyle(fontSize: 20),
    titleTextStyle: TextStyle(fontSize: 30),
    btnOkOnPress: () {},
  ).show();
}

                                  },
                                  child:  Text('Registrar Cambios al Asiento Nº ${widget.id}'),
                                )
                              ),
                            ],
                          )
                          ],)),
                  ),
                  const SizedBox(height: 20,),
            Container(
        width: size.width * 0.70,
        height: size.height * 0.40,
              child: PlutoGrid(
                onLoaded: (a){gridManager=a.stateManager;
                a.stateManager.insertRows(0, (asientoInfo['detalle'] as List).map((e) => PlutoRow(cells: {
                  'id': PlutoCell(value: e['id']),
                  'entidad': PlutoCell(value:ItemModel( e['entidad']['id'],e['entidad']['name'] )),
                  'debe': PlutoCell(value: e['deudor']),
                  'haber': PlutoCell(value: e['acreedor']),
                  'cuenta': PlutoCell(value: ItemModel( e['cuenta']['id'],e['cuenta']['name'] )),
                  'status': PlutoCell(value: ItemModel( e['status']['id'],e['status']['estado'])),
                  'comentario': PlutoCell(value: e['comentario']),
                })).toList());
                  },
                columns: [
                  PlutoColumn(title: 'ID', field: 'id', type: PlutoColumnType.number(),width: 50),
                  PlutoColumn(title: 'ENTIDAD', field: 'entidad', type: PlutoColumnType.select(entidades, enableColumnFilter: true),width: 200),
                  PlutoColumn(title: 'COMENTARIO', field: 'comentario', type: PlutoColumnType.text(),width: 200),
                  PlutoColumn(title: 'STATUS', field: 'status', type: PlutoColumnType.select([ItemModel(1, 'PENDIENTE'),ItemModel(2, 'AMORTIZADO'),ItemModel(3, 'CANCELADO'),ItemModel(4, 'NOAPLICA')]),width: 120),
                  PlutoColumn(title: 'CUENTA', field: 'cuenta', type: PlutoColumnType.select(cuentas, enableColumnFilter: true),width: 200),
                  PlutoColumn(title: 'DEUDOR', field: 'debe', type: PlutoColumnType.currency(symbol: '', decimalDigits: 0),width: 200),
                  PlutoColumn(title: 'ACREEDOR', field: 'haber', type: PlutoColumnType.currency(symbol: '', decimalDigits: 0),width: 200),
                ],
                rows: [],
              ),
            )
                ],
              ),
            ),)
          ],
        ),
      ),
    );
  }
}
