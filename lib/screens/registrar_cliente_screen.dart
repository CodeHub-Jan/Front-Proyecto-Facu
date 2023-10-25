import 'package:centyneg_sys/commons/Globals.dart';
import 'package:centyneg_sys/commons/ThousandsSeparatorInputFormatter.dart';
import 'package:centyneg_sys/models/items_models.dart';
import 'package:centyneg_sys/providers/product_provider.dart';
import 'package:centyneg_sys/providers/sys_data_provider.dart';
import 'package:centyneg_sys/widgets/custom_container.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../commons/app_color.dart';
import '../widgets/custom_dropdown_button2.dart';

class RegistrarClienteScreen extends StatefulWidget {
  const RegistrarClienteScreen({super.key});

  @override
  State<RegistrarClienteScreen> createState() => _RegistrarClienteScreenState();
}

class _RegistrarClienteScreenState extends State<RegistrarClienteScreen> {
var rucController= TextEditingController();
var dvController= TextEditingController();
var nameController= TextEditingController();
var addressController= TextEditingController();
var emailController= TextEditingController();
var dolar=false;
final dio= Dio(BaseOptions(baseUrl: Globals.apiUrl));
  @override
  Widget build(BuildContext context) {
    var provider= Provider.of<SysDataProvider>(context);
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColor.white),
        title: Text(
          'Registrar Cliente', style: TextStyle(color: AppColor.white),),
        backgroundColor: AppColor.darkBlue,),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30,),
            Center(child: CustomContainer(
              padding: const EdgeInsets.symmetric(vertical:20,horizontal: 40),
                containerWith: 500, containerHeight: 350, child:  Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
             Row(
              children: [
                SizedBox(
                  width: 200,
                  height: 50
                  ,
                  child: TextField(
                    controller: rucController,
                      decoration: const InputDecoration(
                          labelText: 'R.U.C'),
                      style: const TextStyle(
                          color: Colors.blue
                      ),
                    onSubmitted: (value) async  {
                      var result= await dio.get('/api/imports/get-entity',queryParameters: {'ruc': value});
                      nameController.text=result.data['name'];
                      dvController.text=result.data['dv'].toString();
                    },
                  ),
                ),
                const SizedBox(width: 20,),
                SizedBox(
                  width: 100,
                  height: 50
                  ,
                  child: TextField(
                    controller: dvController,
                      decoration: const InputDecoration(
                          labelText: 'D.V'),
                      style: const TextStyle(
                          color: Colors.blue
                      )),
                ),
              ],
            ),
                const SizedBox(height: 10,),
                SizedBox(
                  width: 320,
                  height: 50
                  ,
                  child: TextField(
                    controller: nameController,
                      decoration: const InputDecoration(
                          labelText: 'NOMBRE COMPLETO'),
                      style: const TextStyle(
                          color: Colors.blue
                      )),
                ),
                const SizedBox(height: 10,),
                SizedBox(
                  width: 320,
                  height: 50
                  ,
                  child: TextField(
                    controller: addressController,
                      decoration: const InputDecoration(
                          labelText: 'Dirección'),
                      style: const TextStyle(
                          color: Colors.blue
                      )),
                ),
                const SizedBox(height: 10,),
                SizedBox(
                  width: 320,
                  height: 50
                  ,
                  child: TextField(
                    controller: emailController,
                      decoration: const InputDecoration(
                          labelText: 'Email'),
                      style: const TextStyle(
                          color: Colors.blue
                      )),
                ),

                const SizedBox(height: 20,),
                SizedBox(
                  child: ElevatedButton.icon(onPressed: ()async{
                    var result= await provider.registrarCliente({
                      'ruc':rucController.text,
                      'fullName':nameController.text,
                      'registerAt':DateTime.now().toIso8601String(),
                      'dv':int.parse(dvController.text),
                      'address':addressController.text,
                      'proveedor':true,
                      'cliente':true,
                      'email':emailController.text,
                    });
                    if(result)
                      clear();
                  }, icon: const Icon(Icons.save), label: const Text('Guardar Producto')),
                )
              ],
            )))
          ],
        ),
      ),
    );
  }
void clear(){
nameController.clear();
addressController.clear();
dvController.clear();
emailController.clear();
rucController.clear();
    setState(() {

    });
}
  Widget _buildSelector(
      ItemModel? model, List<ItemModel> source,
      String title, double controlWith,{ bool showSearch=false, String searchTitle='', TextEditingController? searchController,
      Function(ItemModel? a)? onChange
      }) {
    return  CustomDropdownButton2(
    searchData: !showSearch  ? null:  DropdownSearchData(
      searchController: searchController,
      searchInnerWidgetHeight: 50,
      searchInnerWidget: Container(
        height: 50,
        padding: const EdgeInsets.only(
          top: 8,
          bottom: 4,
          right: 8,
          left: 8,
        ),
        child: TextFormField(
          expands: true,
          maxLines: null,
          controller: searchController,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets
                .symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            hintText: searchTitle,
            hintStyle: const TextStyle(
                fontSize: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                  8),
            ),
          ),
        ),
      ),
      searchMatchFn: (item, searchValue) {
        return item.value.toString()
            .toUpperCase()
            .contains(searchValue.toUpperCase());
      },
    ),
        hint: title,
        buttonWidth: controlWith,
        dropdownWidth: controlWith,
        dropdownHeight: 200,
        buttonHeight: 30,
        value: model,
        dropdownItems: source,
        onChanged: onChange);
  }
}
