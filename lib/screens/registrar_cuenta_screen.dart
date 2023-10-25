import 'package:centyneg_sys/commons/Globals.dart';
import 'package:centyneg_sys/models/drop_item_model.dart';
import 'package:centyneg_sys/providers/sys_data_provider.dart';
import 'package:centyneg_sys/widgets/custom_container.dart';
import 'package:centyneg_sys/widgets/loading_widget.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class RegistrarCuentaScreen extends StatefulWidget {
  const RegistrarCuentaScreen({super.key, required this.id});
final int id;
  @override
  State<RegistrarCuentaScreen> createState() => _RegistrarCuentaScreenState();
}

class _RegistrarCuentaScreenState extends State<RegistrarCuentaScreen> {
  var isLoading=true;
  late SysDataProvider provider;
  var data={};
  @override
  void initState() {
    // TODO: implement initState
    provider= Provider.of<SysDataProvider>(context,listen: false);
    loadDataFromApi();
  }
  loadDataFromApi() async{
    if(widget.id != 0) {
      data= await provider.getLevelFour(widget.id);
      if(data.isNotEmpty){
        nivel1= DropItemModel(data['levelOne']['id'], data['levelOne']['name']);
        nivel2= DropItemModel(data['levelTwo']['id'], data['levelTwo']['name']);
        nivel3= DropItemModel(data['levelThree']['id'], data['levelThree']['name']);
        nivel4= DropItemModel(data['id'], data['name']);
        moneda= DropItemModel(data['moneda']['id'], data['moneda']['name']);
        codeController.text=data['code'];
        nameController.text= data['name'];
        subCuenta= data['subCuenta'];
        centroCosto= data['centroCosto'];
        departamento= data['departamento'];
        arqueo= data['arquero'];
        modulo= data['modulo'];
        imputable= data['imputable'];
        transferencia= data['transferencia'];
        saldo=DropItemModel(data['saldo']['id'], data['saldo']['name']);
      }
    }
setState(() {
  isLoading=false;
});
  }
  DropItemModel? nivel1=null;
  DropItemModel? nivel2=null;
  DropItemModel? nivel3=null;
  DropItemModel? nivel4=null;
  DropItemModel? moneda=null;
  DropItemModel? saldo=null;
  var subCuenta=false;
  var departamento=false;
  var arqueo=false;
  var modulo=false;
  var imputable=false;
  var centroCosto=false;
  var transferencia=false;
  var codeController= TextEditingController();
  var nameController= TextEditingController();
  double containerHeight=950;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading ? LoadingWidget() : SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30,),
        Center(child:
          CustomContainer(containerWith: 600, containerHeight: containerHeight,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownSearch<DropItemModel>(
                asyncItems: (String filter) =>  provider.getLeveOne(),
                itemAsString: (DropItemModel u) =>  u.title,
                selectedItem: nivel1,
                onChanged: (DropItemModel? data) {nivel1=data;},
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(labelText: "Nivel 1"),
                ),
              ),
              const SizedBox(height: 5,),
              DropdownSearch<DropItemModel>(
                asyncItems: (String filter) =>  provider.getLeveTwo(nivel1?.id ?? 0),
                itemAsString: (DropItemModel u) =>  u.title,
                selectedItem: nivel2,
                onChanged: (DropItemModel? data) {nivel2=data;},
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(labelText: "Nivel 2"),
                ),
              ),
              const SizedBox(height: 5,),
              DropdownSearch<DropItemModel>(
                asyncItems: (String filter) =>  provider.getLevelThree(nivel2?.id ?? 0),
                itemAsString: (DropItemModel u) => u.title,
                selectedItem: nivel3,
                onChanged: (DropItemModel? data) {nivel3=data;},
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(labelText: "Nivel 3"),
                ),
              ),
              const SizedBox(height: 5,),
              DropdownSearch<DropItemModel>(
                asyncItems: (String filter) =>  provider.getMonedas(),
                itemAsString: (DropItemModel u) => u.title,
                selectedItem: moneda,
                onChanged: (DropItemModel? data) {moneda=data;},
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(labelText: "Moneda"),
                ),
              ),
              const SizedBox(height: 5,),
              DropdownSearch<DropItemModel>(
                items: [DropItemModel(1, 'SALDO DEUDOR'),DropItemModel(1, 'SALDO ACREEDOR')],
                selectedItem: saldo,
                onChanged: (DropItemModel? data) {saldo=data;},
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(labelText: "Tipo de Saldo"),
                ),
              ),
              const SizedBox(height: 5,),
              Container(
                child: TextField(
                  controller: codeController,
                  decoration: const InputDecoration(
                    label: Text('Codigo'),
                    icon: Icon(Icons.numbers)
                  ),
                ),
              ),
              const SizedBox(height: 5,),
              Container(
                child: TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                      label: Text('Nombre'),
                      icon: Icon(Icons.abc)
                  ),
                ),
              ),
              const SizedBox(height: 2,),
              Container(width: 250,height: 40,child:  CheckboxListTile(value: subCuenta, onChanged: (a){
                subCuenta=a ?? false;
                setState(() {

                });
              },title: const Text('Sub. Cuenta'),),),
              const SizedBox(height: 2,),
              Container(width: 250,height: 40,child:  CheckboxListTile(value: centroCosto, onChanged: (a){
                centroCosto=a ?? false;
                setState(() {

                });
              },title: const Text('Centro de Costo'),),),
              const SizedBox(height: 2,),
              Container(width: 250,height: 40,child:  CheckboxListTile(value: departamento, onChanged: (a){
                departamento=a ?? false;
                setState(() {

                });
              },title: const Text('Departamento'),),),
              const SizedBox(height: 2,),
              Container(width: 250,height: 40,child:  CheckboxListTile(value: imputable, onChanged: (a){
                imputable=a ?? false;
                setState(() {

                });
              },title: const Text('Imputable'),),),
              const SizedBox(height: 2,),
              Container(width: 250,height: 40,child:  CheckboxListTile(value: transferencia, onChanged: (a){
                transferencia=a ?? false;
                setState(() {

                });
              },title: const Text('Transferencia'),),),
              const SizedBox(height: 2,),
              Container(width: 250,height: 40,child:  CheckboxListTile(value: arqueo, onChanged: (a){
                arqueo=a ?? false;
                setState(() {

                });
              },title: const Text('Arqueo'),),),
              const SizedBox(height: 2,),
             Row(
               children: [
                 Container(width: 250,height: 40,child:  CheckboxListTile(value: modulo, onChanged: (a){
                   modulo=a ?? false;
                   containerHeight=modulo ? 1000 : 850;
                   setState(() {

                   });
                 },title: const Text('Modulos'),),),
                 SizedBox(width: 10,),
                if(modulo)
                  Container(
                    width: 250,
                    child: DropdownSearch<DropItemModel>.multiSelection(
                      asyncItems: (String? filter) => provider.getOperaciones().then((value) => value.map((e) => DropItemModel(e['id'], e['name'])).toList()),
                      items: [DropItemModel(1, 'MODULO 1'),DropItemModel(1, 'MODULO 2 (ESTO TODAVIA NO FUNCIONA')],
                      onChanged: (a) {

                      },
                      dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(labelText: "MODULOS"),
                      ),
                    ),
                  ),
               ],
             ),
              const SizedBox(height: 10,),
              ElevatedButton.icon(onPressed: () async{
              var result= await  provider.registrarCuentaContable({
                  'id': widget.id,
                  'nivel3Id' : nivel3?.id,
                  'monedaId': moneda?.id,
                  'name': nameController.text,
                  'code':codeController.text,
                  'departamento': departamento,
                  'subCuenta': subCuenta,
                  'centroCosto':centroCosto,
                  'saldo':saldo?.id,
                  'arqueo':arqueo,
                'transferencia': transferencia,
                'modulo':modulo,
                'imputable':imputable,
                });
              if(result){
             Globals.showMessage('Datos Guardados Exitosamente', context);
              }
              }, icon: const Icon(Icons.save), label: const Text('Guardar Datos'))
            ],
          )),)
          ],
        ),
      ),
    );
  }
}
