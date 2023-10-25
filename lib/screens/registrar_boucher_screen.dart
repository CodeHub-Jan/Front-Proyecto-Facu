import 'package:centyneg_sys/commons/ThousandsSeparatorInputFormatter.dart';
import 'package:centyneg_sys/commons/app_color.dart';
import 'package:centyneg_sys/commons/extensions.dart';
import 'package:centyneg_sys/models/drop_item_model.dart';
import 'package:centyneg_sys/providers/sys_data_provider.dart';
import 'package:centyneg_sys/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';

class RegistrarBoucherScreen extends StatefulWidget {
  const RegistrarBoucherScreen({super.key});

  @override
  State<RegistrarBoucherScreen> createState() => _RegistrarBoucherScreenState();
}

class _RegistrarBoucherScreenState extends State<RegistrarBoucherScreen> {
  late SysDataProvider provider;
  var isLoading=true;
  List<DropdownMenuItem<DropItemModel>> operations=[];
  List<DropdownMenuItem<DropItemModel>> users=[];
  @override
  void initState() {
    // TODO: implement initState
    provider= Provider.of<SysDataProvider>(context,listen:false);
    loadDataFromApi();
  }
loadDataFromApi() async{
var operaciones= await provider.getOperaciones();
var usuarios= await provider.getUsuarios();
operations= operaciones.map((e) => DropdownMenuItem<DropItemModel>(child: Text(e['name']), value: DropItemModel(e['id'],e['name']),)).toList();
users= usuarios.map((e) => DropdownMenuItem<DropItemModel>(child: Text(e['name']), value: DropItemModel(e['id'],e['name']),)).toList();
setState(() {
  isLoading=false;
});
}
  var formData= GlobalKey<FormBuilderState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading? LoadingWidget() :  SingleChildScrollView(
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
                          name: 'code',
                          maxLength: 100,
                          decoration: const InputDecoration(labelText: 'Codigo'),
                        ),
                      ),
                      SizedBox(
                        width: 250,
                        child: FormBuilderTextField(
                          cursorColor: Colors.indigo,
                          name: 'monto',
                          maxLength: 16,
                          inputFormatters: [
                            ThousandsSeparatorInputFormatter()
                          ],
                          decoration: const InputDecoration(labelText: 'Monto Inicial'),
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
                      const SizedBox(height: 10),
                      MaterialButton(
                        color: AppColor.darkBlue,
                        textColor: Colors.white,
                        onPressed: () async {
                        var result= await provider.registrarBoucher({
                          'codigo': formData.currentState?.fields['code']?.value,
                          'monto': formData.currentState?.fields['monto']?.value.toString().limpiarNumeroParaFormateo(),
                          'userId': formData.currentState?.fields['usuario']?.value.id,
                          'isOpen': true
                        });
                        print(result);
                        formData.currentState?.reset();
                        },
                        child: const Text('Registrar Boucher'),
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
