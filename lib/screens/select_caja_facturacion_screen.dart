import 'package:centyneg_sys/commons/Globals.dart';
import 'package:centyneg_sys/commons/app_color.dart';
import 'package:centyneg_sys/models/items_models.dart';
import 'package:centyneg_sys/providers/facturacion_provider.dart';
import 'package:centyneg_sys/widgets/custom_container.dart';
import 'package:centyneg_sys/widgets/custom_dropdown_button2.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

class SelectCajaFacturacionScreen extends StatefulWidget {
  const SelectCajaFacturacionScreen({super.key});

  @override
  State<SelectCajaFacturacionScreen> createState() => _SelectCajaFacturacionScreenState();
}

class _SelectCajaFacturacionScreenState extends State<SelectCajaFacturacionScreen> {
  var storage= LocalStorage(Globals.dataFileKeyName);
  ItemModel? caja;
  @override
  Widget build(BuildContext context) {
    var factProvider= Provider.of<FacturacionProvider>(context);
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColor.white),
        title: Text(
          'Seleccionar Caja', style: TextStyle(color: AppColor.white),),
        backgroundColor: AppColor.darkBlue,),
      body: SingleChildScrollView(
        child: Column(
       children: [
         SizedBox(height: 30,),
         Center(
           child: CustomContainer(containerWith: 400,containerHeight: 300,child: Column(
             children: [
               SizedBox(height: 20,),
               Icon(Icons.shopping_basket_outlined,size: 90,),
              SizedBox(height: 20,),
               _buildSelector(caja, factProvider.cajas, 'SELECCIONAR CAJA', 350, onChange: (a) async{
                 caja=a;
                 factProvider.caja= await factProvider.getCaja(caja?.id??0);
                 setState(() {

                 });
               }),
               SizedBox(height: 20,),
               ElevatedButton.icon(onPressed: () async{
                 storage.setItem('caja', caja?.id);
                 context.go('/facturacion');
               }, icon: Icon(Icons.transit_enterexit_outlined), label: Text('Ingresar a Facturación'))
             ],
           ),)
         )
       ],
        ),
      ),
    );
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
