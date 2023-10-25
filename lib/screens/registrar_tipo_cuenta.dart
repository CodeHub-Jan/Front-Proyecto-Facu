import 'package:centyneg_sys/commons/ThousandsSeparatorInputFormatter.dart';
import 'package:centyneg_sys/commons/app_color.dart';
import 'package:centyneg_sys/commons/extensions.dart';
import 'package:centyneg_sys/models/items_models.dart';
import 'package:centyneg_sys/providers/sys_data_provider.dart';
import 'package:centyneg_sys/widgets/loading_widget.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:search_choices/search_choices.dart';

import '../models/drop_item_model.dart';

class RegistrarTipoCuentaScreen extends StatefulWidget {
  const RegistrarTipoCuentaScreen({super.key});

  @override
  State<RegistrarTipoCuentaScreen> createState() => _RegistrarTipoCuentaScreenState();
}

class _RegistrarTipoCuentaScreenState extends State<RegistrarTipoCuentaScreen> {
  late SysDataProvider provider;
  List<DropdownMenuItem<DropItemModel>> operaciones=[];
  List<DropdownMenuItem<DropItemModel>>  cuentas=[];
  DropItemModel? cuenta;
  var isLoading=true;
  @override
  void initState() {
    // TODO: implement initState
    provider= Provider.of<SysDataProvider>(context,listen:false);
    loadDataFromApi();
  }
  loadDataFromApi() async{
    var operacionesProvider= await provider.getOperaciones();
    var cuentasProvider= await provider.getListarImputables('');
    operaciones= operacionesProvider.map((e) => DropdownMenuItem<DropItemModel>(child: Text(e['name']), value: DropItemModel(e['id'],e['name']),)).toList();
    cuentas=cuentasProvider.map((e) => DropdownMenuItem<DropItemModel>(child: Text(e['name']), value: DropItemModel(e['id'],e['name']),)).toList();
    setState(() {
      isLoading=false;
    });
  }
  var formData= GlobalKey<FormBuilderState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading? const LoadingWidget() : SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30,),
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
                        width: 300,
                        child: FormBuilderTextField(
                          cursorColor: Colors.indigo,
                          name: 'name',
                          decoration: const InputDecoration(labelText: 'NOMBRE'),
                        ),
                      ),
                      SizedBox(
                        width: 300,
                        child: SearchChoices<DropItemModel>.single(
                          items: cuentas,
                          value: cuenta,
                          hint: "Selecccionar una Cuenta",
                          searchHint: 'Buscar una cuenta contable',
                          onChanged: (value) {
                            setState(() {
cuenta=value;
                            });
                          },
                          doneButton: "Listo",
                          displayItem: (item, selected) {
                            return (Row(children: [
                              selected
                                  ? const Icon(
                                Icons.check,
                                color: Colors.grey,
                              )
                                  : const Icon(
                                Icons.radio_button_unchecked,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 7),
                              Expanded(
                                child: item,
                              ),
                            ]));
                          },
                          isExpanded: true,
                        ),
                      ),
                      SizedBox(
                        width: 300,
                        child: FormBuilderDropdown<DropItemModel>(
                          items: operaciones,
                          name: 'operacion',
                          decoration: const InputDecoration(labelText: 'Operacion'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      MaterialButton(
                        color: AppColor.darkBlue,
                        textColor: Colors.white,
                        onPressed: () async {
                        var result= await provider.registrarTipoDeCuenta({
                          'cuenta': cuenta?.id,
                          'name':formData.currentState?.fields['name']?.value,
                          'operacion':formData.currentState?.fields['operacion']?.value.id,
                        });
                        print(result);
                        formData.currentState?.reset();
                        },
                        child: const Text('Registrar Tipo de Cuenta'),
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
