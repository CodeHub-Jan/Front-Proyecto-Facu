import 'package:centyneg_sys/widgets/custom_container.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:localstorage/localstorage.dart';

import '../commons/Globals.dart';
import '../commons/enums/operaciones_enum.dart';
import '../models/drop_item_model.dart';

class SelecSucursalScreen extends StatefulWidget {
  const SelecSucursalScreen({super.key});

  @override
  State<SelecSucursalScreen> createState() => _SelecSucursalScreenState();
}

class _SelecSucursalScreenState extends State<SelecSucursalScreen> {
  var storage= LocalStorage(Globals.dataFileKeyName);
  String route='';
  var me={};
  final dio= Dio(BaseOptions(baseUrl: Globals.apiUrl));
DropItemModel? sucursal;
  loadDataFromApi() async{
    me= await Globals.getMe();
  }

  @override
  void initState() {
    loadDataFromApi();
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    var size= MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
width: size.width,
          height: size.height,
          child: Column(
            children: [
              SizedBox(height: size.height * 0.20,),
              Center(child: CustomContainer(
                containerHeight: 200,containerWith: 400,child:  Stack(
                children: [
                  const Positioned(
                      top: 10,
                      left: 20,
                      child: Text('SELECCIONAR SUCURSAL',style: TextStyle(fontSize: 20, color: Colors.blue, fontWeight: FontWeight.bold),)),
                  Positioned(
                      top: 40,
                      left: 20,
                      child:  SizedBox(
                      width: 350,
                      height: 50
                      ,
                      child: DropdownSearch<DropItemModel>(
                        asyncItems: (String filter) =>  dio.get('/api/cajas/get-sucursales',queryParameters: {
                          'clientId':me['clientId']
                        }).then((value) => (value.data as List).map((e) => DropItemModel(e['id'], e['name'])).toList()),
                        itemAsString: (DropItemModel u) =>  u.title,
                        onChanged: (DropItemModel? data) {sucursal=data;},
                        dropdownDecoratorProps: const DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(labelText: "Sucursal"),
                        ),
                      )
                  )),
                  Positioned(top: 120, left: 20,
                  child: SizedBox(
                    child: ElevatedButton.icon(onPressed: (){
if(sucursal != null){
  print('SE DARA LA SUCURSAL');
  Globals.setSucursal(sucursal?.id ?? 0);
  context.go('/principal');
}

                    }, icon: const Icon(Icons.open_in_full), label: const Text('Seleccionar Sucursal')),
                  ),
                  )
                ],
              ),
              ),)
            ],
          ),
        ),
      ),
    );
  }
}
