import 'package:centyneg_sys/commons/Globals.dart';
import 'package:centyneg_sys/providers/facturacion_provider.dart';
import 'package:centyneg_sys/providers/product_provider.dart';
import 'package:centyneg_sys/providers/sys_data_provider.dart';
import 'package:centyneg_sys/widgets/loading_widget.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/items_models.dart';
class CustomDrawer extends StatefulWidget {


  const CustomDrawer({Key? key}) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  var isLoading= true;
  var me={};
  loadDataFromApi() async{
    me= await Globals.getMe();
    setState(() {
      isLoading=false;
    });
  }
  @override
  void initState() {
    loadDataFromApi();
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    var provider= Provider.of<SysDataProvider>(context);
    var productProvider= Provider.of<ProductProvider>(context);
    return Drawer(
      child: isLoading? LoadingWidget() : ListView(
        padding: EdgeInsets.zero,
        children: [
          if(me['contabilidad'])...[
            ExpansionTile(title: Text('Contabilidad'), children: [
              ListTile(
                leading: const Icon(Icons.account_tree_sharp),
                title: const Text(
                  'Plan de Cuentas',
                  style: TextStyle(fontSize: 15.0),
                ),
                onTap: () async {
                  context.go('/plan_cuentas2');
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_circle_outlined),
                title: const Text(
                  'Ingresos',
                  style: TextStyle(fontSize: 15.0),
                ),
                onTap: () {
                  context.go('/ingresos');
                },
              ),
              ListTile(
                leading: const Icon(Icons.remove_circle),
                title: const Text(
                  'Egresos',
                  style: TextStyle(fontSize: 15.0),
                ),
                onTap: () {
                  context.go('/egresos');
                },
              ),
              ListTile(
                leading: const Icon(Icons.leaderboard_outlined),
                title: const Text(
                  'Generar Centro de Costo',
                  style: TextStyle(fontSize: 15.0),
                ),
                onTap: () async {

                  context.go('/centros_costos');
                },
              ),
              ListTile(
                leading: const Icon(Icons.leaderboard_outlined),
                title: const Text(
                  'Arqueos / Bouchers',
                  style: TextStyle(fontSize: 15.0),
                ),
                onTap: () async {

                  context.go('/arqueos');
                },
              ),
              ListTile(
                leading: const Icon(Icons.list_alt_outlined),
                title: const Text(
                  'Gestionar Centro de Costos',
                  style: TextStyle(fontSize: 15.0),
                ),
                onTap: () async {

                  context.go('/centro_de_costos');
                },
              ),
              ListTile(
                leading: const Icon(Icons.list_alt_outlined),
                title: const Text(
                  'Gestionar Departamentos',
                  style: TextStyle(fontSize: 15.0),
                ),
                onTap: () async {

                  context.go('/departamentos');
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_note_outlined),
                title: const Text(
                  'Gestion de Asientos Contables',
                  style: TextStyle(fontSize: 15.0),
                ),
                onTap: () async {

                  context.go('/asientos');
                },
              ),
              ListTile(
                leading: const Icon(Icons.bookmark_added_outlined),
                title: const Text(
                  'Asiento Manual',
                  style: TextStyle(fontSize: 15.0),
                ),
                onTap: () async {
                  provider.loadOperaciones();
                  provider.getClients();
                  context.go('/asiento_manual');

                },
              ),
              ListTile(
                leading: const Icon(Icons.bookmark_added_outlined),
                title: const Text(
                  'Tipos de Pago',
                  style: TextStyle(fontSize: 15.0),
                ),
                onTap: () async {
                  await provider.loadAllOperaciones();
                  await provider.loadAllPagos();
                  await provider.loadCuentasImputables();
                  await provider.loadMonedas();
                  context.go('/tipos_de_pago');
                },
              ),
              ListTile(
                leading: const Icon(Icons.supervised_user_circle_sharp),
                title: const Text(
                  'Entidades',
                  style: TextStyle(fontSize: 15.0),
                ),
                onTap: () async {
                  context.go('/clientes');
                },
              ),
              ListTile(
                leading: const Icon(Icons.payments),
                title: const Text(
                  'Orden de Pago',
                  style: TextStyle(fontSize: 15.0),
                ),
                onTap: () async {

                  context.go('/pagos');
                },
              ),
              ListTile(
                leading: const Icon(Icons.payments),
                title: const Text(
                  'Cobranza',
                  style: TextStyle(fontSize: 15.0),
                ),
                onTap: () async {
                  context.go('/cobranzas');
                },
              ),
              ListTile(
                leading: const Icon(Icons.account_balance_sharp),
                title: const Text(
                  'Transferencias',
                  style: TextStyle(fontSize: 15.0),
                ),
                onTap: () async {
                  context.go('/transferencias');
                },
              ),
              ListTile(
                leading: const FaIcon(FontAwesomeIcons.moneyCheck),
                title: const Text(
                  'Cotizaciones',
                  style: TextStyle(fontSize: 15.0),
                ),
                onTap: () async {
                  context.go('/listado-cotizaciones');
                },
              ),
            ],),
          ],
         if(me['facturacion'])...[
           ExpansionTile(

             title: Text('Facturación',style: TextStyle(fontSize: 15.0),), children: [
             ListTile(
               leading: const Icon(Icons.local_atm),
               title: const Text(
                 'Caja',
                 style: TextStyle(fontSize: 15.0),
               ),
               onTap: () async {
                 await provider.loadSucursales();
                 await provider.loadCajasGestion();
                 context.go('/caja');
               },
             ),
             ListTile(
               leading: const Icon(Icons.table_rows_rounded),
               title: const Text(
                 'Gestionar Tabla de Valores',
                 style: TextStyle(fontSize: 15.0),
               ),
               onTap: () async {
                 context.go('/gestion-tablas');
               },
             ),
             ListTile(
               leading: const Icon(Icons.sell_outlined),
               title: const Text(
                 'Generar Factura',
                 style: TextStyle(fontSize: 15.0),
               ),
               onTap: () async {
                 context.go('/facturas');
               },
             ),
             ListTile(
               leading: const Icon(Icons.touch_app),
               title: const Text(
                 'Pantalla de Ventas Touch',
                 style: TextStyle(fontSize: 15.0),
               ),
               onTap: () async {
                 context.go('/fact_touch');
               },
             ),
             ListTile(
               leading: const Icon(Icons.add_shopping_cart_rounded),
               title: const Text(
                 'Generar Compra',
                 style: TextStyle(fontSize: 15.0),
               ),
               onTap: () async {
                 await productProvider.loadProducts();
                 await provider.getClients2();
                 await provider.getBancos();
                 await provider.getTiposPagos(8);
                 context.go('/compra_screen');
               },
             ),
             ListTile(
               leading: const Icon(Icons.production_quantity_limits),
               title: const Text(
                 'Productos',
                 style: TextStyle(fontSize: 15.0),
               ),
               onTap: () async {
                 await productProvider.loadProducts();
                 context.go('/productos');
               },
             ),
             ListTile(
               leading: const Icon(Icons.warehouse_rounded),
               title: const Text(
                 'Sucursales',
                 style: TextStyle(fontSize: 15.0),
               ),
               onTap: () async {
                 await productProvider.loadProducts();
                 context.go('/sucursales');
               },
             ),
           ],),
         ],
    if(me['informes'])...[
      ExpansionTile(

        title: Text('Informes'), children: [
        ListTile(
          leading: const  FaIcon(FontAwesomeIcons.chartColumn),
          title: const Text(
            'Cuenta Corriente',
            style: TextStyle(fontSize: 15.0),
          ),
          onTap: () {
            context.go('/cuenta_corriente');
          },
        ),
        ListTile(
          leading: const FaIcon(FontAwesomeIcons.boxesStacked),
          title: const Text(
            'Informe de Stock',
            style: TextStyle(fontSize: 15.0),
          ),
          onTap: () {
            context.go('/informe-stock');
          },
        ),
        ListTile(
          leading: const FaIcon(FontAwesomeIcons.boxesStacked),
          title: const Text(
            'Informe de Rentabilidad',
            style: TextStyle(fontSize: 15.0),
          ),
          onTap: () {
            context.go('/informe-rentabilidad');
          },
        ),
        ListTile(
          leading: const FaIcon(FontAwesomeIcons.arrowTrendUp),
          title: const Text(
            'Informe de Boucher',
            style: TextStyle(fontSize: 15.0),
          ),
          onTap: () {
            context.go('/reporte_boucher');
          },
        ),
        ListTile(
          leading: const FaIcon(FontAwesomeIcons.book),
          title: const Text(
            'Reporte Centro de Costo',
            style: TextStyle(fontSize: 15.0),
          ),
          onTap: () {
            context.go('/report-centro');
          },
        ),
        ListTile(
          leading: const FaIcon(FontAwesomeIcons.book),
          title: const Text(
            'Libros',
            style: TextStyle(fontSize: 15.0),
          ),
          onTap: () {
            context.go('/libros');
          },
        ),
      ],),
    ],
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text(
              'Cerrar Sesión',
              style: TextStyle(fontSize: 15.0),
            ),
            onTap: () {
context.go('/main/0');
            },
          ),
        ],
      ),
    );
  }
}
