import 'package:centyneg_sys/commons/ThousandsSeparatorInputFormatter.dart';
import 'package:centyneg_sys/commons/app_color.dart';
import 'package:centyneg_sys/commons/extensions.dart';
import 'package:centyneg_sys/providers/sys_data_provider.dart';
import 'package:centyneg_sys/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';

import '../models/drop_item_model.dart';

class RegistrarArqueoScreen extends StatefulWidget {
  const RegistrarArqueoScreen({super.key});

  @override
  State<RegistrarArqueoScreen> createState() => _RegistrarArqueoScreenState();
}

class _RegistrarArqueoScreenState extends State<RegistrarArqueoScreen> {
  late SysDataProvider provider;
  List<DropdownMenuItem<DropItemModel>> tipoPagos=[];
  List<DropdownMenuItem<DropItemModel>> users=[];
  List<DropdownMenuItem<DropItemModel>> bouchers=[];
  DateTime date=DateTime.now();
  var isLoading=true;
  @override
  void initState() {
    // TODO: implement initState
    provider= Provider.of<SysDataProvider>(context,listen:false);
    loadDataFromApi();
  }
  loadDataFromApi() async{
    var pagosProvider= await provider.getTipoPagoArqueo();
    var usuariosProvider= await provider.getUsuarios();
    var bouchersProvider= await provider.getBouchers();
    tipoPagos= pagosProvider.map((e) => DropdownMenuItem<DropItemModel>(child: Text(e['name']), value: DropItemModel(e['id'],e['name']),)).toList();
    users= usuariosProvider.map((e) => DropdownMenuItem<DropItemModel>(child: Text(e['name']), value: DropItemModel(e['id'],e['name']),)).toList();
    bouchers= bouchersProvider.map((e) => DropdownMenuItem<DropItemModel>(child: Text(e['code']), value: DropItemModel(e['id'],e['code']),)).toList();
    setState(() {
      isLoading=false;
    });
  }
  var formData= GlobalKey<FormBuilderState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading? LoadingWidget() : SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 30,),
            Center(
              child: SizedBox(
                width: 400,
                height: 400,
                child: FormBuilder(
                  key: formData,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 250,
                        child: FormBuilderTextField(
                          cursorColor: Colors.indigo,
                          name: 'apertura',
                          inputFormatters: [ThousandsSeparatorInputFormatter()],
                          decoration: const InputDecoration(labelText: 'Monto de Apertura'),
                        ),
                      ),
                      SizedBox(
                        width: 250,
                        child: FormBuilderDropdown<DropItemModel>(
                          items: users,
                          name: 'usuario',
                          decoration: const InputDecoration(labelText: 'Encargado'),
                        ),
                      ),
                      SizedBox(
                        width: 250,
                        child: FormBuilderDropdown<DropItemModel>(
                          items: tipoPagos,
                          name: 'pago',
                          decoration: const InputDecoration(labelText: 'Tipo de Pago'),
                        ),
                      ),
                      SizedBox(
                        width: 250,
                        child: FormBuilderDropdown<DropItemModel>(
                          items: bouchers,
                          name: 'boucher',
                          decoration: const InputDecoration(labelText: 'Boucher'),
                        ),
                      ),
                      SizedBox(
                        width: 250,
                        child: FormBuilderDateTimePicker(
                          onChanged: (a){
date= a ?? DateTime.now();
                          },
                          name: 'fecha',
                          decoration: const InputDecoration(labelText: 'Fecha de Apertura'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      MaterialButton(
                        color: AppColor.darkBlue,
                        textColor: Colors.white,
                        onPressed: () async {
                        var result= await provider.registrarArqueo({
                          'boucherId': formData.currentState?.fields['boucher']?.value.id,
                          'userId': formData.currentState?.fields['usuario']?.value.id,
                          'tipoPagoId': formData.currentState?.fields['pago']?.value.id,
                          'montoInicial': double.parse(formData.currentState?.fields['apertura']?.value.toString().limpiarNumeroParaFormateo() ?? '0'),
                          'fecha':date.toIso8601String()
                        });
                        print(result);
                        formData.currentState?.reset();
                        },
                        child: const Text('Registrar Centro de Costo'),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
