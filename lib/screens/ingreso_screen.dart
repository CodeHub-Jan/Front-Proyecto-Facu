import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:centyneg_sys/commons/Globals.dart';
import 'package:centyneg_sys/commons/ThousandsSeparatorInputFormatter.dart';
import 'package:centyneg_sys/models/items_models.dart';
import 'package:centyneg_sys/providers/sys_data_provider.dart';
import 'package:centyneg_sys/widgets/custom_container.dart';
import 'package:centyneg_sys/widgets/custom_dropdown_button2.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:empty_widget/empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../commons/app_color.dart';
import '../models/ingreso_model.dart';
import '../providers/printing_provider.dart';
import '../widgets/loading_widget.dart';

class IngresoScreen extends StatefulWidget {
  const IngresoScreen({super.key});

  @override
  State<IngresoScreen> createState() => _IngresoScreenState();
}

class _IngresoScreenState extends State<IngresoScreen> {
  var centro=false;
  var facturaLegal=false;
  DateTime? date = DateTime.now();
  DateTime? vencimiento = DateTime.now();
  ItemsClientModel? client = null;
  var yearController = TextEditingController(
      text: Globals.periodo.toString());
  var fechaController = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(DateTime.now()));
  var vencimientoController = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(DateTime.now()));
  var rucController = TextEditingController();
  var docController = TextEditingController(text: '001-001-');
  var timbradoController = TextEditingController();
  var comentarioController = TextEditingController();
  var incluida10Controller = TextEditingController();
  var incluida5Controller = TextEditingController();
  var exentasController = TextEditingController();
  var gravada10Controller = TextEditingController();
  var iva10Controller = TextEditingController();
  var gravada5Controller = TextEditingController();
  var iva5Controller = TextEditingController();
  var totalIncluidasController = TextEditingController();
  var totalExentasController = TextEditingController();
  var totalGravadasController = TextEditingController();
  var totalIvaController = TextEditingController();
  var montoController = TextEditingController();
  var totalDeudorController = TextEditingController();
  var pagoController = TextEditingController();
  var cuotasController = TextEditingController(text: '1');
  var intervaloController = TextEditingController(text: '30');
  var planCuentaController = TextEditingController();
  var tipoOperacionController = TextEditingController();
  var codigoCuentaController = TextEditingController();
  var saldoController = TextEditingController();
  var boucherSaldoController= TextEditingController();
  var dolarController= TextEditingController();
  bool isAddNewClientVisible=false;
  final TextEditingController searchClientController = TextEditingController();
  final TextEditingController searchCuentaController = TextEditingController();
  var reciboMask = MaskTextInputFormatter(
      mask: '###-###-#######', filter: { "#": RegExp(r'[0-9]')});
  late SysDataProvider provider;
  var textStyle=  const TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.bold
  );

  var asientoGenerado=false;
  var asientoId=0;
  var canPrint=false;
  var isLegal=false;
  List<IngresoModel> listIngreso=[];

  var storage = LocalStorage(Globals.dataFileKeyName);
  @override
  void dispose() {
    searchClientController.dispose();
    super.dispose();
  }
  final dio= Dio(BaseOptions(baseUrl: Globals.apiUrl));
  var isLoading= true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadDataFromApi();
  }
  //Declaraciones
  _Centro? centroCosto;
  _Boucher? boucher;
  _TipoDePago? tipoDePago;
  _TipoDeCuenta? tipoDeCuenta;
  _Comprobante? tipoDoc;
  _Documento? _documento;
  bool haveBoucher=false;
  Map me={};
loadDataFromApi() async{
   me= await Globals.getMe();
   isLoading=false;
   setState(() {

   });
}
var isAnotherMoney=false;
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery
        .of(context)
        .size;
    provider = Provider.of<SysDataProvider>(context);
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColor.white),
        title: Text(
          'Registrar Ingreso', style: TextStyle(color: AppColor.white),),
        backgroundColor: AppColor.darkBlue,),
      body: isLoading? const LoadingWidget() : SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20,),
            Center(
              child: CustomContainer(
                containerHeight: size.height * 0.95,
                containerWith: size.width * 0.80,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                      color: Colors.blueAccent.withOpacity(0.3),
                      width: size.width * 0.80,
                      height: size.height * 0.40,
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
                              const SizedBox(width: 500,),
                              if(haveBoucher)
                                Flexible(child: Container(
                                  color:Colors.black,
                                  width: 250,
                                  height: 70,
                                  child: TextField(
                                    controller: boucherSaldoController,
                                    style: const TextStyle(fontSize: 30, color: Colors.lightGreenAccent),
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Saldo Boucher',
                                      labelStyle: TextStyle(fontSize: 15, color:Colors.lightGreenAccent,),

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
                          const SizedBox(height: 20,),
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
                                  animationDuration: const Duration(seconds: 1),

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
                                            titleTextStyle: const TextStyle(
                                              fontSize: 22,
                                              color: Color(0xff9da9c7),
                                              fontWeight: FontWeight.w500,
                                            ),
                                            subtitleTextStyle: const TextStyle(
                                              fontSize: 14,
                                              color: Color(0xffabb8d6),
                                            ),
                                            hideBackgroundAnimation: false,
                                          ),
                                        ),

                                        const SizedBox(height: 10,),
                                        Row(
                                          children: [
                                            const Text("Para agregar el cliente, clic en el icono", style: TextStyle(fontSize: 20),),
                                            InkWell(child: const Icon(Icons.add,color: Colors.green, size: 35,), onTap: (){
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
                           SizedBox(
                             width: 300,
                             height: 50,
                             child: DropdownSearch<_TipoDeCuenta>(
                               asyncItems: (f)=>dio.get('/api/accounts/get-tipos-de-cuenta-by-filtro', queryParameters: {
                                 'clientId': me['clientId'],
                                 'tipo':1
                               }).then((value) => (value.data as List).map((e) => _TipoDeCuenta(e['name'],e['id'],e['centro'])).toList()),
                               itemAsString: (u)=>u.name,
                               dropdownDecoratorProps: const DropDownDecoratorProps(
                                 dropdownSearchDecoration: InputDecoration(labelText: "Tipo de Cuenta"),
                               ),
                               onChanged: (a){
                                 centro= a?.centro ?? false;
                                 if(!centro){
                                   centroCosto=null;
                                 }
                                 tipoDeCuenta=a;
                                 setState(() {

                                 });
                               },
                             ),
                           ),
                              const SizedBox(width: 10,),
                              if(centro)
                                SizedBox(
                                  width: 300,
                                  height: 50,
                                  child: DropdownSearch<_Centro>(
                                    asyncItems: (f)=>dio.get('/api/modules/get-centro-de-costos', queryParameters: {
                                      'clientId': me['clientId'],
                                      'tipo':2
                                    }).then((value) => (value.data as List).map((e) => _Centro('${e['name']}(${e['code']})',e['id'])).toList()),
                                    itemAsString: (u)=>u.name,
                                    dropdownDecoratorProps: const DropDownDecoratorProps(
                                      dropdownSearchDecoration: InputDecoration(labelText: "Centro de Costo"),
                                    ),
                                    onChanged: (a){
                                      centroCosto=a;
                                    },
                                  ),
                                )
                            ],
                          ),

                          const SizedBox(height: 10,),
                          Row(
                            children: [
                              SizedBox(
                                width: 300,
                                height: 50,
                                child: DropdownSearch<_Comprobante>(
                                  asyncItems: (f)=>dio.get('/api/modules/get-documentos', queryParameters: {
                                    'clientId': me['clientId'],
                                  }).then((value) => (value.data as List).map((e) => _Comprobante(e['name'],e['id'],e['auto'],e['valor'],e['legal'])).toList()),
                                  itemAsString: (u)=>u.name,
                                  dropdownDecoratorProps: const DropDownDecoratorProps(
                                    dropdownSearchDecoration: InputDecoration(labelText: "Tipo de Comprobante"),
                                  ),
                                  onChanged: (a){
                                    tipoDoc=a;
                                    isLegal= a?.isLegal ?? false;
                                    if(a?.auto ?? false){
                                      docController.text=a?.value ?? '';
                                    }else{
                                      docController.text='001-001-';
                                    }
                                    setState(() {
                                      canPrint=a?.auto ?? false;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 20,),
                              Flexible(child: SizedBox(
                                width: 200,
                                height: 30,
                                child: TextField(
                                  controller: docController,
                                  style: const TextStyle(fontSize: 14),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Doc. Nº',
                                    labelStyle: TextStyle(fontSize: 12),

                                  ),
                                ),
                              ),),
                              if(isLegal)
                             ...[
                               const SizedBox(width: 10,),
                               SizedBox(
                                 width: 300,
                                 height: 50,
                                 child: DropdownSearch<_Documento>(
                                   asyncItems: (f)=>dio.get('/api/modules/get-documentos-impresion-by-client', queryParameters: {
                                     'id': me['clientId'],
                                   }).then((value) => (value.data as List).map((e) => _Documento(e['name'],e['id'])).toList()),
                                   itemAsString: (u)=>u.name,
                                   dropdownDecoratorProps: const DropDownDecoratorProps(
                                     dropdownSearchDecoration: InputDecoration(labelText: "Tipo de Comprobante"),
                                   ),
                                   onChanged: (a){
_documento=a;
                                   },
                                 ),
                               ),
                               const SizedBox(width: 20,),
                               Flexible(child: SizedBox(
                                 width: 150,
                                 height: 30,
                                 child: TextField(
                                   controller: timbradoController,
                                   style: const TextStyle(fontSize: 14),
                                   decoration: const InputDecoration(
                                     border: OutlineInputBorder(),
                                     labelText: 'Timbrado Nº',
                                     labelStyle: TextStyle(fontSize: 12),

                                   ),
                                 ),
                               ),),
                             ],
                              const SizedBox(width: 20,),
                              Flexible(child: SizedBox(
                                width: 500,
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
                              Flexible(child: SizedBox(
                                width: 200,
                                height: 30,
                                child: TextField(
                                  inputFormatters: isAnotherMoney ? []: [
                                     ThousandsSeparatorInputFormatter()
                                  ],
                                  keyboardType: TextInputType.number,
                                  controller: incluida10Controller,
                                  onChanged: (a){
                                    changeDataFromFields();
                                  },
                                  style: const TextStyle(fontSize: 14),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Incluida 10%',
                                    labelStyle: TextStyle(fontSize: 12),

                                  ),
                                ),
                              ),),
                              const SizedBox(width: 20,),
                              Flexible(child: SizedBox(
                                width: 200,
                                height: 30,
                                child: TextField(
                                  controller: incluida5Controller,
                                  inputFormatters: isAnotherMoney ? []: [
                                     ThousandsSeparatorInputFormatter()
                                  ],
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(fontSize: 14),
                                  onChanged: (a){
                                    changeDataFromFields();
                                  },
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Incluida 5%',
                                    labelStyle: TextStyle(fontSize: 12),

                                  ),
                                ),
                              ),),
                              const SizedBox(width: 20,),
                              Flexible(child: SizedBox(
                                width: 200,
                                height: 30,
                                child: TextField(
                                  controller: exentasController,
                                  inputFormatters: isAnotherMoney ? []: [
                                     ThousandsSeparatorInputFormatter()
                                  ],
                                  onChanged: (a){
                                    changeDataFromFields();
                                  },
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(fontSize: 14),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Exentas',
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
                                  inputFormatters: isAnotherMoney ? []: [
                                     ThousandsSeparatorInputFormatter()
                                  ],
                                  keyboardType: TextInputType.number,
                                  controller: gravada10Controller,
                                  style: const TextStyle(fontSize: 14),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Gravada 10%',
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
                                  inputFormatters: isAnotherMoney ? []: [
                                     ThousandsSeparatorInputFormatter()
                                  ],
                                  keyboardType: TextInputType.number,
                                  controller: iva10Controller,
                                  style: const TextStyle(fontSize: 14),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Iva 10%',
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
                              Flexible(child: SizedBox(
                                width: 200,
                                height: 30,
                                child: TextField(
                                  controller: gravada5Controller,
                                  readOnly: true,
                                  inputFormatters: isAnotherMoney ? []: [
                                     ThousandsSeparatorInputFormatter()
                                  ],
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(fontSize: 14),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Gravada 5%',
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
                                  inputFormatters: isAnotherMoney ? []: [
                                     ThousandsSeparatorInputFormatter()
                                  ],
                                  keyboardType: TextInputType.number,
                                  controller: iva5Controller,
                                  style: const TextStyle(fontSize: 14),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Iva 5%',
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
                                  inputFormatters: isAnotherMoney ? []: [
                                     ThousandsSeparatorInputFormatter()
                                  ],
                                  keyboardType: TextInputType.number,
                                  controller: totalIncluidasController,
                                  style: const TextStyle(fontSize: 14),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Total Incluidas',
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
                                  inputFormatters: isAnotherMoney ? []: [
                                     ThousandsSeparatorInputFormatter()
                                  ],
                                  keyboardType: TextInputType.number,
                                  controller: totalExentasController,
                                  style: const TextStyle(fontSize: 14),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Total Exentas',
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
                              Flexible(child: SizedBox(
                                width: 200,
                                height: 30,
                                child: TextField(
                                  readOnly: true,
                                  inputFormatters: isAnotherMoney ? []: [
                                     ThousandsSeparatorInputFormatter()
                                  ],
                                  keyboardType: TextInputType.number,
                                  controller: totalGravadasController,
                                  style: const TextStyle(fontSize: 14),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Total Gravadas',
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
                                  inputFormatters: isAnotherMoney ? []: [
                                     ThousandsSeparatorInputFormatter()
                                  ],
                                  keyboardType: TextInputType.number,
                                  controller: totalIvaController,
                                  style: const TextStyle(fontSize: 14),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Total Iva',
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
                                  inputFormatters: isAnotherMoney ? []: [
                                     ThousandsSeparatorInputFormatter()
                                  ],
                                  keyboardType: TextInputType.number,
                                  controller: montoController,
                                  style: const TextStyle(fontSize: 14),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Monto',
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
                                  inputFormatters: isAnotherMoney ? []: [
                                     ThousandsSeparatorInputFormatter()
                                  ],
                                  keyboardType: TextInputType.number,
                                  controller: totalDeudorController,
                                  style: const TextStyle(fontSize: 14),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Total Deudor',
                                    labelStyle: TextStyle(fontSize: 12),

                                  ),
                                ),
                              ),),
                              const SizedBox(width: 30,),
                              ElevatedButton.icon(onPressed: asientoGenerado ? null: () async {
                                var result=
                                    await dio.get('/api/monedas/check-cotizacion-by-date',
                                    queryParameters: {
                                      'fromDate':date?.toIso8601String()
                                    });
                                var checkDolar= (result.data as Map)['found'];
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

                              
    double incluida10=0, incluida5=0, exentas=0;
    if(incluida10Controller.text.isNotEmpty){
    incluida10=  double.parse(isAnotherMoney ? incluida10Controller.text :  incluida10Controller.text.replaceAll('.', ''));
    }
    if(incluida5Controller.text.isNotEmpty){
    incluida5= double.parse(isAnotherMoney ? incluida5Controller.text :  incluida5Controller.text.replaceAll('.', ''));
    }
    if(exentasController.text.isNotEmpty){
    exentas= double.parse(isAnotherMoney ? exentasController.text :  exentasController.text.replaceAll('.', ''));
    }
    if(tipoDePago == null){
      Globals.showMessage('Seleccionar un Tipo de Pago', context);
      return;
    }
    if(tipoDoc == null){
      Globals.showMessage('Seleccionar un Tipo de Documento', context);
      return;
    }
                                if(client == null){
                                  Globals.showMessage('Seleccionar un cliente', context);
                                  return;
                                }
                                if(tipoDeCuenta == null){
                                  Globals.showMessage('Seleccionar un Plan de Cuenta', context);
                                  return;
                                }
                                if((tipoDePago?.arqueo ?? false) && boucher == null){
                                  Globals.showMessage('El tipo de pago que has seleccionado esta marcado como Boucher, por lo tanto seleccione antes de continuar', context);
                                  return;
                                }

var asiento= {
  'sucursalId': storage.getItem('sucursal'),
  'fecha' : date?.toIso8601String(),
  'periodo': Globals.periodo,
  'tipoOperacionId': 1,
  'numeroComprobante': docController.text,
  'comentario':comentarioController.text,
  'idAsiento':0,
  'entidadId' : client?.id,
  'clientId': me['clientId'],
  'tipoDocId': tipoDoc?.id,
  'boucherId': boucher?.id,
  'timbrado': 'N/A',
  'gravada10': (incluida10 / 1.1),
  'iva10': (incluida10 / 11),
  'gravada5': (incluida5 / 1.05),
  'iva5': (incluida5 / 21),
  'exenta': exentas,
  'libro': (tipoDePago?.name?.contains('C_INTER')  ?? false)? 3 : 2,
  'userId':me['id'],
  'cuotas': int.parse(cuotasController.text),
  'intervalo':int.parse(intervaloController.text),
  'tipoDeCuentaId': tipoDeCuenta?.id,
  'tipoDePagoId': tipoDePago?.id,
  'vencimiento' : vencimiento?.toIso8601String(),
  'centroCostoId': centroCosto?.id,
  'facturaLegal': isLegal,
  'tipoImpresionId': isLegal ? _documento?.id ?? 0 : null
};
var data= await provider.generarIngreso(asiento);
listIngreso=data.$2;
asientoId=data.$3;
Globals.showMessage(data.$1, context);
                                setState(() {
                                  asientoGenerado=true;
                                });
                              },
                                  icon: const Icon(Icons.book_outlined),
                                  label: const Text('Generar')),
                              const SizedBox(width: 10,),
                              ElevatedButton.icon(onPressed: () {
                                clearData();
                                setState(() {
                                  asientoGenerado=false;
                                  canPrint=false;
                                });
                              },
                                  icon: const Icon(Icons.add_circle_sharp),
                                  label: const Text('Nuevo')),
                              const SizedBox(width: 10,),
                              ElevatedButton.icon(onPressed: () {},
                                  icon: const Icon(Icons.cancel),
                                  label: const Text('Cancelar')),
                              const SizedBox(width: 10,),
                              if(canPrint)
                                ElevatedButton.icon(onPressed: () async {
                                  if(asientoId==0)return;
                                  var print= Provider.of<PrintingProvider>(context,listen: false);
                                  var api= await dio.get('/api/reportes/generar-comprobante-interno',
                                      queryParameters: {
                                        'id':asientoId
                                      }
                                  );
                                  var base64= api.data;
                                  await print.printPdfByBase64(base64);
                                },
                                    icon: const Icon(Icons.print),
                                    label: const Text('Imprimir')),
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
                      height: size.height * 0.16,
                      child: Column(
                        children: [
                          const SizedBox(height: 10,),
                          Row(
                            children: [
                              SizedBox(
                                width: 300,
                                height: 50,
                                child: DropdownSearch<_TipoDePago>(
                                  asyncItems: (f)=>dio.get('/api/typeofpayments/get-all', queryParameters: {
                                    'clientId': me['clientId'],
                                    'tipoId':1
                                  }).then((value) => (value.data as List).map((e) => _TipoDePago(e['name'],e['id'],e['arqueo'])).toList()),
                                  itemAsString: (u)=>u.name,
                                  onChanged: (a) async{
                                    var data= await provider.getTipoDePago(1, a?.id ?? 0);
                                    haveBoucher=a?.arqueo ?? false;
                                    pagoController.text= data['tipo'];
                                    planCuentaController.text= data['cuenta'];
                                    codigoCuentaController.text=data['code'];
                                    saldoController.text=data['saldo'];
                                    tipoOperacionController.text= data['operacion'];
                                    var moneda= await provider.getMonedaByTipoPago(a?.id ?? 0);
                                    print(moneda);
                                    setState(() {
                                      isAnotherMoney=moneda['tipo'] != 1;
                                      tipoDePago = a;
                                    });
                                  },
                                  dropdownDecoratorProps: const DropDownDecoratorProps(
                                    dropdownSearchDecoration: InputDecoration(labelText: "Tipo de Pago"),
                                  ),
                                ),
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
                              const SizedBox(width: 20,),
                              if(haveBoucher)
                              SizedBox(
                                width: 300,
                                height: 50,
                                child: DropdownSearch<_Boucher>(
                                  asyncItems: (f)=>dio.get('/api/arqueos/listar-bouchers', queryParameters: {
                                    'clientId': me['clientId'],
                                  }).then((value) => (value.data as List).map((e) => _Boucher(e['code'],e['id'])).toList()),
                                  itemAsString: (u)=>u.name,
                                  dropdownDecoratorProps: const DropDownDecoratorProps(
                                    dropdownSearchDecoration: InputDecoration(labelText: "Boucher"),
                                  ),
                                  onChanged: (a) async{
                                    var fecth= await dio.get('/api/arqueos/get-saldo-boucher',
                                    queryParameters: {
                                      'id':a?.id
                                    }
                                    );
                                    var data= fecth.data as Map;
                                    boucherSaldoController.text=data['saldo'];
                                    boucher=a;
                                  },
                                ),
                              )
                            ],
                          ),

                        ],
                      ),
                    ),
                    SfDataGrid(
                      source: IngresoDataSource(sourceData: listIngreso),
                      columnWidthMode: ColumnWidthMode.fill,
                      columns: <GridColumn>[
                        GridColumn(
                            columnName: 'cuenta',
                            label: Container(
                                padding: const EdgeInsets.all(5.0),
                                alignment: Alignment.center,
                                child:  Text(
                                  'CUENTA',
                                  style: textStyle,
                                ))),
                        GridColumn(
                            width: 100,
                            columnName: 'estado',
                            label: Container(
                                padding: const EdgeInsets.all(5.0),
                                alignment: Alignment.center,
                                child:  Text(
                                  'ESTADO',
                                  style: textStyle,
                                ))),
                        GridColumn(
                            columnName: 'comentario',
                            label: Container(
                                padding: const EdgeInsets.all(5.0),
                                alignment: Alignment.center,
                                child:  Text(
                                  'COMENTARIO',
                                  style: textStyle,
                                ))),
                        GridColumn(
                            columnName: 'comprobante',
                            label: Container(
                                padding: const EdgeInsets.all(5.0),
                                alignment: Alignment.center,
                                child:  Text(
                                  'COMPROBANTE',
                                  style: textStyle,
                                ))),
                        GridColumn(
                            width: 120,
                            columnName: 'moneda',
                            label: Container(
                                padding: const EdgeInsets.all(5.0),
                                alignment: Alignment.center,
                                child:  Text(
                                  'MONEDA',
                                  style: textStyle,
                                ))),
                        GridColumn(
                            width: 100,
                            columnName: 'cuotas',
                            label: Container(
                                padding: const EdgeInsets.all(5.0),
                                alignment: Alignment.center,
                                child:  Text(
                                  'CUOTAS',
                                  style: textStyle,
                                ))),
                        GridColumn(
                            columnName: 'cambio',
                            label: Container(
                                padding: const EdgeInsets.all(5.0),
                                alignment: Alignment.center,
                                child:  Text(
                                  'CAMBIO',
                                  style: textStyle,
                                ))),
                        GridColumn(
                            columnName: 'debe',
                            label: Container(
                                padding: const EdgeInsets.all(5.0),
                                alignment: Alignment.center,
                                child:  Text(
                                  'MONTO DEUDOR',
                                  style: textStyle,
                                ))),
                        GridColumn(
                            width: 200,
                            columnName: 'haber',
                            label: Container(
                                padding: const EdgeInsets.all(5.0),
                                alignment: Alignment.center,
                                child:  Text(
                                  'MONTO ACREEDOR',
                                  style: textStyle,
                                ))),
                        GridColumn(
                            columnName: 'montoOrigen',
                            label: Container(
                                padding: const EdgeInsets.all(5.0),
                                alignment: Alignment.center,
                                child:  Text(
                                  'MONTO ORIGEN',
                                  style: textStyle,
                                ))),
                        GridColumn(
                            columnName: 'vencimiento',
                            label: Container(
                                padding: const EdgeInsets.all(5.0),
                                alignment: Alignment.center,
                                child:  Text(
                                  'VENCIMIENTO',
                                  style: textStyle,
                                ))),
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
  void changeDataFromFields(){
    double incluida10=0, incluida5=0, exentas=0, totalIva=(incluida10 / 11) + (incluida5 / 21), totalIncluidas=incluida10 + incluida5,

        totalGravadas=(incluida10 / 1.1) + (incluida5 / 1.05),total= incluida10+incluida5+exentas;
    try{
      if(incluida10Controller.text.isNotEmpty){
        incluida10= double.parse(isAnotherMoney ? incluida10Controller.text : incluida10Controller.text.replaceAll('.', ''));
      }
      if(incluida5Controller.text.isNotEmpty){
        incluida5= double.parse(isAnotherMoney ? incluida5Controller.text : incluida5Controller.text.replaceAll('.', ''));
      }
      if(exentasController.text.isNotEmpty){
        exentas= double.parse(isAnotherMoney ? exentasController.text : exentasController.text.replaceAll('.', ''));
      }
      totalGravadas=(incluida10 / 1.1) + (incluida5 / 1.05);
      totalIva=(incluida10 / 11) + (incluida5 / 21);
      totalIncluidas=incluida10 + incluida5;
      total= incluida10+incluida5+exentas;
      gravada10Controller.text=  NumberFormat.decimalPatternDigits(decimalDigits: isAnotherMoney? 2 : 0, locale: 'es-PY').format((incluida10 / 1.1));
      iva10Controller.text= NumberFormat.decimalPatternDigits(decimalDigits:  isAnotherMoney? 2 : 0, locale: 'es-PY').format((incluida10 / 11));
      gravada5Controller.text=  NumberFormat.decimalPatternDigits(decimalDigits:  isAnotherMoney? 2 : 0, locale: 'es-PY').format((incluida5 / 1.05));
      iva5Controller.text= NumberFormat.decimalPatternDigits(decimalDigits:  isAnotherMoney? 2 : 0, locale: 'es-PY').format((incluida5 / 21));
      totalExentasController.text=NumberFormat.decimalPatternDigits(decimalDigits:  isAnotherMoney? 2 : 0, locale: 'es-PY').format(exentas);
      totalGravadasController.text=NumberFormat.decimalPatternDigits(decimalDigits:  isAnotherMoney? 2 : 0, locale: 'es-PY').format(totalGravadas);
      totalIvaController.text=NumberFormat.decimalPatternDigits(decimalDigits:  isAnotherMoney? 2 : 0, locale: 'es-PY').format(totalIva);
      totalIncluidasController.text=NumberFormat.decimalPatternDigits(decimalDigits:  isAnotherMoney? 2 : 0, locale: 'es-PY').format(totalIncluidas);
      montoController.text=NumberFormat.decimalPatternDigits(decimalDigits:  isAnotherMoney? 2 : 0, locale: 'es-PY').format(total);
      totalDeudorController.text=NumberFormat.decimalPatternDigits(decimalDigits:  isAnotherMoney? 2 : 0, locale: 'es-PY').format(total);
    }on Exception catch(_){

    }
  }
  void showAddIcon(){
    setState(() {
      isAddNewClientVisible=true;
    });
  }
 
  void clearData(){
    searchClientController.clear();
    gravada10Controller.clear();
    iva10Controller.clear();
    gravada5Controller.clear();
    iva5Controller.clear();
    totalExentasController.clear();
    totalGravadasController.clear();
    totalIvaController.clear();
    totalIncluidasController.clear();
    montoController.clear();
    totalDeudorController.clear();
    incluida10Controller.clear();
    incluida5Controller.clear();
    exentasController.clear();
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
    tipoDePago=null;
    client=null;
    boucher=null;
    tipoDeCuenta=null;
    date=DateTime.now();
    asientoId=0;
    vencimiento=DateTime.now();
    listIngreso.clear();
    setState(() {

    });
  }
}
class IngresoDataSource extends DataGridSource {
  /// Creates the employee data source class with required details.
  IngresoDataSource({required List<IngresoModel> sourceData}) {
    _sourceData = sourceData
        .map<DataGridRow>((e) =>
        DataGridRow(cells: [
          DataGridCell<String>(columnName: 'cuenta', value: e.cuenta),
          DataGridCell<String>(columnName: 'estado', value: e.estado),
          DataGridCell<String>(columnName: 'comentario', value: e.comentario),
          DataGridCell<String>(columnName: 'comprobante', value: e.comprobante),
          DataGridCell<String>(columnName: 'moneda', value: e.moneda),
          DataGridCell<String>(columnName: 'cuotas', value: e.cuotas),
          DataGridCell<String>(columnName: 'cambio', value: e.cambio),
          DataGridCell<String>(columnName: 'debe', value: e.debe),
          DataGridCell<String>(columnName: 'haber', value: e.haber),
          DataGridCell<String>(columnName: 'montoOrigen', value: e.montoOrigen),
          DataGridCell<String>(columnName: 'vencimiento', value: e.vencimiento),
        ]))
        .toList();
  }

  List<DataGridRow> _sourceData = [];

  @override
  List<DataGridRow> get rows => _sourceData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((e) {
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8.0),
            child: Text(e.value.toString()),
          );
        }).toList());
  }
}

class _TipoDePago{
  String name;
  int id;
  bool arqueo;

  _TipoDePago(this.name, this.id, this.arqueo);
}

class _TipoDeCuenta{
  String name;
  int id;
  bool centro;
  _TipoDeCuenta(this.name, this.id, this.centro);
}
class _Boucher{
  String name;
  int id;
  _Boucher(this.name, this.id);
}
class _Comprobante{
  String name;
  int id;
  bool auto;
  bool isLegal;
  _Comprobante(this.name, this.id, this.auto, this.value, this.isLegal);

  String value;
}
class _Centro{
  String name;
  int id;
  _Centro(this.name, this.id);
}
class _Documento{
  String name;
  int id;
  _Documento(this.name, this.id);
}