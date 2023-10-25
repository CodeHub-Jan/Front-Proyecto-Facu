import 'package:centyneg_sys/commons/ThousandsSeparatorInputFormatter.dart';
import 'package:centyneg_sys/commons/app_color.dart';
import 'package:centyneg_sys/commons/extensions.dart';
import 'package:centyneg_sys/providers/sys_data_provider.dart';
import 'package:centyneg_sys/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';

class RegistrarCentroDeCostoScreen extends StatefulWidget {
  const RegistrarCentroDeCostoScreen({super.key});

  @override
  State<RegistrarCentroDeCostoScreen> createState() => _RegistrarCentroDeCostoScreenState();
}

class _RegistrarCentroDeCostoScreenState extends State<RegistrarCentroDeCostoScreen> {
  late SysDataProvider provider;
  @override
  void initState() {
    // TODO: implement initState
    provider= Provider.of<SysDataProvider>(context,listen:false);
  }

  var formData= GlobalKey<FormBuilderState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  SingleChildScrollView(
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
                        width: 150,
                        child: FormBuilderTextField(
                          cursorColor: Colors.indigo,
                          name: 'code',
                          decoration: const InputDecoration(labelText: 'Codigo'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      FormBuilderTextField(
                        cursorColor: Colors.indigo,
                        name: 'name',
                        decoration: const InputDecoration(labelText: 'NOMBRE'),
                      ),
                      const SizedBox(height: 10),
                      FormBuilderTextField(
                        cursorColor: Colors.indigo,
                        name: 'manager',
                        decoration: const InputDecoration(labelText: 'MANAGER'),
                      ),
                      const SizedBox(height: 10),
                      FormBuilderTextField(
                        cursorColor: Colors.indigo,
                        name: 'phone',
                        decoration: const InputDecoration(labelText: 'Nº DE CELULAR'),
                      ),
                      const SizedBox(height: 10),
                      FormBuilderTextField(
                        cursorColor: Colors.indigo,
                        name: 'value',
                        inputFormatters: [ThousandsSeparatorInputFormatter()],
                        decoration: const InputDecoration(labelText: 'VALOR'),
                      ),
                      const SizedBox(height: 10),
                      MaterialButton(
                        color: AppColor.darkBlue,
                        textColor: Colors.white,
                        onPressed: () async {
                        var result= await provider.registrarCentroCosto({
                          'code': formData.currentState?.fields['code']?.value,
                          'name': formData.currentState?.fields['name']?.value,
                          'manager': formData.currentState?.fields['manager']?.value,
                          'phone': formData.currentState?.fields['phone']?.value,
                          'value': double.parse(formData.currentState?.fields['value']?.value.toString().limpiarNumeroParaFormateo() ?? '0'),
                          'available':true
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
