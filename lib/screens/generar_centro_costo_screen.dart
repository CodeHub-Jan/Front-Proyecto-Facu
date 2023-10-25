import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:centyneg_sys/commons/Globals.dart';
import 'package:centyneg_sys/models/items_models.dart';
import 'package:centyneg_sys/providers/sys_data_provider.dart';
import 'package:centyneg_sys/widgets/custom_container.dart';
import 'package:centyneg_sys/widgets/custom_dropdown_button2.dart';
import 'package:centyneg_sys/widgets/loading_widget.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:empty_widget/empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import '../commons/app_color.dart';

class GenerarCentroCostoScreen extends StatefulWidget {
  const GenerarCentroCostoScreen({super.key});

  @override
  State<GenerarCentroCostoScreen> createState() => _GenerarCentroCostoScreenState();
}

class _GenerarCentroCostoScreenState extends State<GenerarCentroCostoScreen> {
  final dio= Dio(BaseOptions(baseUrl: Globals.apiUrl));
  DateTime? date = DateTime.now();
  DateTime? vencimiento = DateTime.now();
  ItemsClientModel? client = null;
  var yearController = TextEditingController(text: Globals.periodo.toString());
  var fechaController = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(DateTime.now()));
  var vencimientoController = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(DateTime.now()));
  var rucController = TextEditingController();
  var docController = TextEditingController(text: '001-001-');
  var comentarioController = TextEditingController();

  var pagoController = TextEditingController();
  var cuotasController = TextEditingController(text: '1');
  var intervaloController = TextEditingController(text: '30');
  var planCuentaController = TextEditingController();
  var tipoOperacionController = TextEditingController();
  var codigoCuentaController = TextEditingController();
  var saldoController = TextEditingController();
  final TextEditingController searchClientController = TextEditingController();
  var reciboMask = MaskTextInputFormatter(
      mask: '###-###-#######', filter: { "#": RegExp(r'[0-9]')});
  late SysDataProvider provider;

  ItemModel? tipoPago;
  ItemModel? tipoDoc;
  var dolarController= TextEditingController();
  var asientoGenerado=false;
  late PlutoGridStateManager stateGrid;

  var storage = LocalStorage(Globals.dataFileKeyName);
  @override
  void dispose() {
    searchClientController.dispose();
    super.dispose();
  }
  @override
  void initState() {
    // TODO: implement initState
    provider= Provider.of<SysDataProvider>(context,listen:false);
    loadDataFromApi();
  }
  var isLoading=true;
  loadDataFromApi() async{
    provider.getTiposPagos(6);
    await provider.getTiposDoc();
    await provider.getClients();
    await provider.getCentroDeCostos();
    await provider.getDepartamentos();
    await provider.loadImputablesCentroCosto();
    setState(() {
      isLoading=false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        ShowCaseWidget.of(context).startShowCase([_one])
    );
  }
  GlobalKey _one = GlobalKey();
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery
        .of(context)
        .size;
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColor.white),
        title: Text(
          'Registrar Egreso', style: TextStyle(color: AppColor.white),),
        backgroundColor: AppColor.darkBlue,),
      body: isLoading ? LoadingWidget() :  SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20,),
            Center(
              child: CustomContainer(
                containerHeight: size.height * 0.90,
                containerWith: size.width * 0.80,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      color: Colors.blueAccent.withOpacity(0.3),
                      width: size.width * 0.80,
                      height: size.height * 0.23,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Flexible(child: SizedBox(
                                width: 200,
                                height: 30,
                                child: TextField(
                                  readOnly: true,
                                  controller: fechaController,
                                  style: const TextStyle(fontSize: 14),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Fecha',
                                    labelStyle: TextStyle(fontSize: 12),

                                  ),
                                ),
                              ),),
                              const SizedBox(width: 20,),
                              Flexible(child: SizedBox(
                                width: 150,
                                child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white38
                                    ),
                                    onPressed: () async {
                                      var results = await showCalendarDatePicker2Dialog(
                                        context: context,
                                        config: CalendarDatePicker2WithActionButtonsConfig(),
                                        dialogSize: const Size(325, 400),
                                        value: [DateTime.now()],
                                        borderRadius: BorderRadius.circular(
                                            15),
                                      );
                                      date = results?.first;
                                      if (date != null) {
                                        var resultFromApi= await dio.get('/api/monedas/get-cotizacion-by-date',
                                            queryParameters: {
                                              'fromDate':date?.toIso8601String()
                                            }
                                        );
                                        dolarController.text= Globals.formatNumberToLocate((resultFromApi.data)['valor']);
                                        fechaController.text =
                                            DateFormat('dd/MM/yyyy').format(
                                                date!);
                                        setState(() {

                                        });
                                      }
                                    },
                                    icon: const Icon(Icons.calendar_month),
                                    label: const Text('Seleccionar Fecha')),
                              ),),

                              const SizedBox(width: 40,),
                              Flexible(child: SizedBox(
                                width: 200,
                                height: 30,
                                child: TextField(
                                  readOnly: false,
                                  controller: yearController,
                                  style: const TextStyle(fontSize: 14),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Periodo',
                                    labelStyle: TextStyle(fontSize: 12),

                                  ),
                                ),
                              ),),
                              const SizedBox(width: 10,),
                              Flexible(child: Container(
                                color:Colors.black12,
                                width: 180,
                                height: 70,
                                child: TextField(
                                  controller: dolarController,
                                  style: const TextStyle(fontSize: 30, color: Colors.black54),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Cotización Dolar',
                                    labelStyle: TextStyle(fontSize: 20, color:Colors.black87,),

                                  ),
                                ),
                              ),),
                            ],
                          ),
                          const SizedBox(height: 5,),
                          Row(
                            children: [
                              Flexible(child: Container(
                                width: 500,
                                height: 60,
                                child: TypeAheadField(
                                  textFieldConfiguration:  TextFieldConfiguration(
                                      autofocus: true,
                                      controller: searchClientController,
                                      style: const TextStyle(fontSize: 16),
                                      decoration: const InputDecoration(
                                          icon: Icon(Icons.account_circle_outlined),
                                          border: OutlineInputBorder(),
                                          hintText: 'Buscar un Cliente'
                                      )
                                  ),
                                  suggestionsCallback: (pattern) async {
                                    return await provider.entitiesBackSearch(pattern);
                                  },
                                  itemBuilder: (context, suggestion) {
                                    return ListTile(
                                      leading: const Icon(Icons.supervised_user_circle_sharp),
                                      title: Text(suggestion['fullName']),
                                      subtitle: Text('R.U.C ${suggestion['ruc']}'),
                                    );
                                  },
                                  onSuggestionSelected: (suggestion) async {
                                    client= await provider.getEntidad(suggestion['id']);
                                    if(client != null){
                                      rucController.text=client?.ruc ?? '';
                                      searchClientController.text=client?.title ?? '';
                                    }
                                  },
                                  hideSuggestionsOnKeyboardHide: false,
                                  hideOnError: true,
                                  animationDuration: Duration(seconds: 1),

                                  noItemsFoundBuilder: (_)=> Container(
                                      width: 400,
                                      height: 300,
                                      child: Column(
                                        children: [
                                          Container(
                                            width: 400,
                                            height: 230,
                                            child: EmptyWidget(
                                              image: null,
                                              packageImage: PackageImage.Image_1,
                                              title: 'No existe el cliente',
                                              subTitle: 'Parece que el cliente que buscas no existe, no que no, Edgar? :(',
                                              titleTextStyle: TextStyle(
                                                fontSize: 22,
                                                color: Color(0xff9da9c7),
                                                fontWeight: FontWeight.w500,
                                              ),
                                              subtitleTextStyle: TextStyle(
                                                fontSize: 14,
                                                color: Color(0xffabb8d6),
                                              ),
                                              hideBackgroundAnimation: false,
                                            ),
                                          ),

                                          SizedBox(height: 10,),
                                          Row(
                                            children: [
                                              Text("Para agregar el cliente, clic en el icono", style: TextStyle(fontSize: 20),),
                                              InkWell(child: Icon(Icons.add,color: Colors.green, size: 35,), onTap: (){
                                                print('hello');
                                                context.go('/registrar_cliente');
                                              },)
                                            ],
                                          )
                                        ],
                                      )
                                  ),
                                ),
                              )),
                              const SizedBox(width: 20,),
                              Flexible(child: SizedBox(
                                width: 200,
                                height: 30,
                                child: TextField(
                                  controller: rucController,
                                  readOnly: true,
                                  style: const TextStyle(fontSize: 14),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'R.U.C',
                                    labelStyle: TextStyle(fontSize: 12),

                                  ),
                                ),
                              ),),
                              const SizedBox(width: 20,),
                            ],
                          ),

                          const SizedBox(height: 10,),
                          Row(
                            children: [
                              CustomDropdownButton2(hint: 'Tipo de Comprobante',
                                  buttonWidth: 200,
                                  dropdownWidth: 200,
                                  buttonHeight: 30,
                                  value: tipoDoc,
                                  dropdownItems: provider.tiposDocs,
                                  onChanged: (a) {
                                    setState(() {
                                      tipoDoc = a;
                                    });
                                  }),
                              const SizedBox(width: 20,),
                              Flexible(child: SizedBox(
                                width: 200,
                                height: 30,
                                child: TextField(
                                  controller: docController,
                                  style: const TextStyle(fontSize: 14),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Recibo Nº',
                                    labelStyle: TextStyle(fontSize: 12),

                                  ),
                                ),
                              ),),
                              const SizedBox(width: 20,),
                              Flexible(child: SizedBox(
                                width: 1000,
                                height: 30,
                                child: TextField(
                                  controller: comentarioController,
                                  style: const TextStyle(fontSize: 14),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Comentario',
                                    labelStyle: TextStyle(fontSize: 12),

                                  ),
                                ),
                              ),),
                            ],
                          ),
                          const SizedBox(height: 10,),
                          Row(
                            children: [
                              ElevatedButton.icon(onPressed: asientoGenerado ? null: () async {
                                var resultCotizacion=
                                await dio.get('/api/monedas/check-cotizacion-by-date',
                                    queryParameters: {
                                      'fromDate':date?.toIso8601String()
                                    });
                                var checkDolar= (resultCotizacion.data as Map)['found'];
                                if(!checkDolar){
                                  var valor= await  showTextInputDialog(context: context, textFields: [
                                    const DialogTextField(hintText: 'Valor del Dolar',keyboardType:TextInputType.number)
                                  ],title: 'VALOR DEL DOLAR PARA LA FECHA');
                                  var dolar= double.parse(valor?[0] ?? '0');
                                  await dio.post('/api/monedas/registrar-cotizacion',
                                      data: {
                                        'fecha':date?.toIso8601String(),
                                        'valor':dolar,
                                        'moneda':2
                                      });
                                }
                                if(tipoDoc ==null){
                                  Globals.showMessage('Seleccione el tipo de documento', context);
                                  return;
                                }
                                if(client ==null){
                                  Globals.showMessage('Seleccione el cliente', context);
                                  return;
                                }
                                if(date ==null){
                                  Globals.showMessage('Seleccione la fecha', context);
                                  return;
                                }
                                if(vencimiento ==null){
                                  Globals.showMessage('Seleccione el primer vencimiento', context);
                                  return;
                                }
                                if(tipoPago ==null){
                                  Globals.showMessage('Seleccione el tipo de pago', context);
                                  return;
                                }
                                var data= await provider.getTypeOfPayment(tipoPago?.id ?? 0);
                                for (var element in stateGrid.refRows) {
                                  element.cells['moneda']?.value= ItemModel(data['monedaData']['id'], data['monedaData']['flag']);
                                }
                                var pagos= stateGrid.rows
                                    .map((e) => {
                                  'cuentaId': e.cells['cuenta']?.value.id,
                                  'centroCosto': e.cells['centro_costo']?.value.id == 0 ? null:e.cells['centro_costo']?.value.id ,
                                  'departamento': e.cells['departamento']?.value.id == 0 ? null:  e.cells['departamento']?.value.id,
                                  'comentario': e.cells['comentario']?.value,
                                  'comprobante': e.cells['doc']?.value,
                                  'value': e.cells['monto']?.value,
                                  'iva': e.cells['iva']?.value.id,
                                  'monedaId': e.cells['moneda']?.value.id,
                                }).toList();
var body={
  'fecha':date?.toIso8601String(),
  'periodo': Globals.periodo,
'comentario': comentarioController.text,
  'entidadId': client?.id,
  'tipoPagoId': tipoPago?.id  ,
  'tipoDocId':tipoDoc?.id ,
  'clientId':0,
  'userId':0,
  'cuotas': int.parse(cuotasController.text),
  'vencimiento': vencimiento?.toIso8601String(),
  'intervalo': int.parse(intervaloController.text),
  'docNumber':docController.text,
  'sucursalId': storage.getItem('sucursal'),
  'list':pagos
};
var result=await provider.generarCentro(body);
await Globals.showMessage(result, context);
clearData();
                                setState(() {

                                });
                              },
                                  icon: const Icon(Icons.book_outlined),
                                  label: const Text('Generar')),
                              const SizedBox(width: 10,),
                              ElevatedButton.icon(onPressed: () {
                                clearData();
                                setState(() {
                                  asientoGenerado=false;
                                });
                              },
                                  icon: const Icon(Icons.add_circle_sharp),
                                  label: const Text('Nuevo')),
                              const SizedBox(width: 10,),
                              ElevatedButton.icon(onPressed: () {},
                                  icon: const Icon(Icons.cancel),
                                  label: const Text('Cancelar')),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                      color: Colors.orangeAccent.withOpacity(0.3),
                      width: size.width * 0.80,
                      height: size.height * 0.17,
                      child: Column(
                        children: [
                          const SizedBox(height: 10,),
                          Row(
                            children: [
                              Showcase(
                                key: _one,
                                descTextStyle: TextStyle(fontSize: 18),
                                title: 'IMPORTANTE !',
                                description: 'Una vez termines de cargar todos los datos de tu centro de costo, Vuelve a seleccionar el tipo de pago antes de guardar la operación, esto hara que se iguale los tipos de moneda !',
                                child: CustomDropdownButton2(hint: 'Tipo de Pago',
                                    buttonWidth: 400,
                                    buttonHeight: 30,
                                    dropdownWidth: 400,
                                    value: tipoPago,
                                    dropdownItems: provider.tipoDePagos,
                                    onChanged: (a) async {
                                      var data= await provider.getTypeOfPayment(a?.id ?? 0);
                                      pagoController.text= data['tipo'];
                                      planCuentaController.text= data['cuenta'];
                                      codigoCuentaController.text=data['code'];
                                      saldoController.text=data['saldo'];
                                      tipoOperacionController.text= data['operacion'];
                                      for (var element in stateGrid.refRows) {
                                        element.cells['moneda']?.value= ItemModel(data['monedaData']['id'], data['monedaData']['flag']);
                                      }
                                      setState(() {
                                        tipoPago = a;
                                      });
                                    }),
                              ),

                              const SizedBox(width: 20,),
                              Flexible(child: SizedBox(
                                width: 150,
                                height: 30,
                                child: TextField(
                                  readOnly: true,
                                  controller: pagoController,
                                  style: const TextStyle(fontSize: 14),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Pago',
                                    labelStyle: TextStyle(fontSize: 12),

                                  ),
                                ),
                              ),),
                              const SizedBox(width: 20,),
                              Flexible(child: SizedBox(
                                width: 70,
                                height: 30,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  controller: cuotasController,
                                  style: const TextStyle(fontSize: 14),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Cuotas',
                                    labelStyle: TextStyle(fontSize: 12),

                                  ),
                                ),
                              ),),
                              const SizedBox(width: 20,),
                              Flexible(child: SizedBox(
                                width: 200,
                                height: 30,
                                child: TextField(
                                  readOnly: true,
                                  controller: vencimientoController,
                                  style: const TextStyle(fontSize: 14),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Primer Vencimiento',
                                    labelStyle: TextStyle(fontSize: 12),

                                  ),
                                ),
                              ),),
                              const SizedBox(width: 10,),
                              Flexible(child: SizedBox(
                                width: 150,
                                child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white38
                                    ),
                                    onPressed: () async {
                                      var results = await showCalendarDatePicker2Dialog(
                                        context: context,
                                        config: CalendarDatePicker2WithActionButtonsConfig(),
                                        dialogSize: const Size(325, 400),
                                        value: [DateTime.now()],
                                        borderRadius: BorderRadius.circular(15),
                                      );
                                      vencimiento = results?.first;
                                      if (vencimiento != null) {
                                        vencimientoController.text =
                                            DateFormat('dd/MM/yyyy').format(
                                                vencimiento!);
                                        setState(() {

                                        });
                                      }
                                    },
                                    icon: const Icon(Icons.calendar_month),
                                    label: const Text('Seleccionar Fecha')),
                              ),),
                              const SizedBox(width: 20,),
                              Flexible(child: SizedBox(
                                width: 100,
                                height: 30,
                                child: TextField(
                                  controller: intervaloController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(fontSize: 14),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Intervalo',
                                    labelStyle: TextStyle(fontSize: 12),

                                  ),
                                ),
                              ),),
                            ],
                          ),
                          const SizedBox(height: 10,),
                          Row(
                            children: [
                              Flexible(child: SizedBox(
                                width: 300,
                                height: 30,
                                child: TextField(
                                  controller: planCuentaController,
                                  style: const TextStyle(fontSize: 14),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Plan de Cuenta',
                                    labelStyle: TextStyle(fontSize: 12),

                                  ),
                                ),
                              ),),
                              const SizedBox(width: 20,),
                              Flexible(child: SizedBox(
                                width: 150,
                                height: 30,
                                child: TextField(
                                  controller: tipoOperacionController,
                                  style: const TextStyle(fontSize: 14),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Tipo de Operación',
                                    labelStyle: TextStyle(fontSize: 12),

                                  ),
                                ),
                              ),),
                              const SizedBox(width: 20,),
                              Flexible(child: SizedBox(
                                width: 200,
                                height: 30,
                                child: TextField(
                                  controller: codigoCuentaController,
                                  style: const TextStyle(fontSize: 14),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Codigo Cta.',
                                    labelStyle: TextStyle(fontSize: 12),

                                  ),
                                ),
                              ),),
                              const SizedBox(width: 20,),
                              Flexible(child: SizedBox(
                                width: 120,
                                height: 30,
                                child: TextField(
                                  controller: saldoController,
                                  style: const TextStyle(fontSize: 14),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Saldo',
                                    labelStyle: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),),
                            ],
                          ),
                    Container(
                      width: size.width * 0.80,
                      height: 40,
                      child:       Stack(
                        children: [
                          Positioned(
                              top: 10,
                              right: 220
                              ,
                              child: SizedBox(
                                width: 250,
                                height: 30,
                                child: TextField(
                                  controller: saldoController,
                                  style: const TextStyle(fontSize: 14),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Monto Actual',
                                    labelStyle: TextStyle(fontSize: 12),
                                  ),
                                ),
                              )),
                          Positioned(
                              top: 10,
                              right: 10
                              ,
                              child: SizedBox(
                                width: 200,
                                height: 30,
                                child: TextField(
                                  controller: saldoController,
                                  style: const TextStyle(fontSize: 14),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Saldo',
                                    labelStyle: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ))
                        ],
                      ),
                    )
                        ],
                      ),
                    ),
                  Container(
                    width: size.width * 0.80,
                    height: size.height * 0.50,
                    child:  PlutoGrid(
                        configuration:  const PlutoGridConfiguration(
                          style: PlutoGridStyleConfig(
                              cellTextStyle: TextStyle(fontSize: 12),
                              columnTextStyle: TextStyle(fontSize: 12),
                              rowHeight: 25,
                              columnHeight: 30,

                          ),
                          scrollbar: PlutoGridScrollbarConfig(
                            isAlwaysShown: true,
                            draggableScrollbar: true,
                          ),
                           enableMoveDownAfterSelecting: false,
                          columnSize: PlutoGridColumnSizeConfig(restoreAutoSizeAfterInsertColumn: true),
                          enterKeyAction: PlutoGridEnterKeyAction.toggleEditing,

                        ),
                        columns:
                      [
                        PlutoColumn(
                          suppressedAutoSize: true,
                          title: 'CUENTA.', field: 'cuenta', type: PlutoColumnType.select(provider.cuentasImputables,enableColumnFilter: true, popupIcon: Icons.search), width: 250,
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
                                        'cuenta': PlutoCell(value: ItemModel(0,'')),
                                        'comentario': PlutoCell(value: comentarioController.text),
                                        'doc': PlutoCell(value: docController.text),
                                        'centro_costo': PlutoCell(value: ItemModel(0,'')),
                                        'departamento': PlutoCell(value: ItemModel(0,'')),
                                        'monto': PlutoCell(value: 0),
                                        'moneda':  PlutoCell(value: ItemModel(1,'N/A')),
                                        'iva':  PlutoCell(value: ItemModel(3,'10%')),
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
                                  onPressed: () {
                                    rendererContext.stateManager
                                        .removeRows([rendererContext.row]);
                                  },
                                  iconSize: 18,
                                  color: Colors.red,
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
                        PlutoColumn(title: 'COMENTARIO.', field: 'comentario', type: PlutoColumnType.text(),width: 300),
                        PlutoColumn(title: 'COMPROBANTE.', field: 'doc', type: PlutoColumnType.text(),width: 200),
                        PlutoColumn(title: 'CENTRO DE COSTO.', field: 'centro_costo', type: PlutoColumnType.select(provider.centroDeCostos, ),width: 250, ),
                        PlutoColumn(title: 'DEPARTAMENTO.', field: 'departamento', type: PlutoColumnType.select(provider.departamentos),width: 200),
                        PlutoColumn(title: 'MONTO DEUDOR.', field: 'monto', type: PlutoColumnType.currency(
                            decimalDigits: 0, symbol: '', applyFormatOnInit: true) ,width: 150),
                        PlutoColumn(title: 'MONEDA.', field: 'moneda', readOnly: true, type: PlutoColumnType.select([], enableColumnFilter: true),  width: 100),
                        PlutoColumn(title: 'IVA.', field: 'iva', type: PlutoColumnType.select([ItemModel(1, '0%'),ItemModel(2, '5%'), ItemModel(3, '10%')]),width: 100),
                      ], rows: [

PlutoRow(cells: {
  'cuenta': PlutoCell(value: ItemModel(0,'')),
  'comentario': PlutoCell(value: ''),
  'doc': PlutoCell(value: ''),
  'centro_costo': PlutoCell(value: ItemModel(0,'')),
  'departamento': PlutoCell(value: ItemModel(0,'')),
  'monto': PlutoCell(value: 0),
  'moneda':  PlutoCell(value: ItemModel(1,'N/A')),
  'iva':  PlutoCell(value: ItemModel(3,'10%')),
}),
                    ],
                      onLoaded: (PlutoGridOnLoadedEvent event) => stateGrid = event.stateManager,
                    )
                  )

                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
  void clearData(){
    stateGrid.refRows.clear();
    rucController.clear();
    comentarioController.clear();
    docController.text='001-001-';
    pagoController.clear();
    cuotasController.text='1';
    intervaloController.text='30';
    planCuentaController.clear();
    saldoController.clear();
    codigoCuentaController.clear();
    tipoOperacionController.clear();
    tipoDoc=null;
    tipoPago=null;
    client=null;
    date=DateTime.now();
    vencimiento=DateTime.now();
    stateGrid.insertRows(
      0,[
      PlutoRow(cells: {
        'cuenta': PlutoCell(value: ItemModel(0,'')),
        'comentario': PlutoCell(value: comentarioController.text),
        'doc': PlutoCell(value: docController.text),
        'centro_costo': PlutoCell(value: ItemModel(0,'')),
        'departamento': PlutoCell(value: ItemModel(0,'')),
        'monto': PlutoCell(value: 0),
        'moneda':  PlutoCell(value: ItemModel(1,'N/A')),
        'iva':  PlutoCell(value: ItemModel(3,'10%')),
      })
    ]
    );
    setState(() {

    });
  }
}
