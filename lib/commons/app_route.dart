import 'package:centyneg_sys/commons/enums/operaciones_enum.dart';
import 'package:centyneg_sys/screens/arqueros_screen.dart';
import 'package:centyneg_sys/screens/asientos_screen.dart';
import 'package:centyneg_sys/screens/boucher_reporte_screen.dart';
import 'package:centyneg_sys/screens/centro_costos_screen.dart';
import 'package:centyneg_sys/screens/clientes_screen.dart';
import 'package:centyneg_sys/screens/cuenta_corriente_screen.dart';
import 'package:centyneg_sys/screens/departamentos_screen.dart';
import 'package:centyneg_sys/screens/informe_rentabilidad_screen.dart';
import 'package:centyneg_sys/screens/informe_stock_screen.dart';
import 'package:centyneg_sys/screens/listado_cobranzas.dart';
import 'package:centyneg_sys/screens/listado_egresos_screen.dart';
import 'package:centyneg_sys/screens/listado_op_screen.dart';
import 'package:centyneg_sys/screens/listado_transferencia.dart';
import 'package:centyneg_sys/screens/main_screen.dart';
import 'package:centyneg_sys/screens/plan_de_cuentas_screen2.dart';
import 'package:centyneg_sys/screens/registrar_arqueo_screen.dart';
import 'package:centyneg_sys/screens/registrar_boucher_screen.dart';
import 'package:centyneg_sys/screens/registrar_cuenta_screen.dart';
import 'package:centyneg_sys/screens/registrar_tipo_cuenta.dart';
import 'package:centyneg_sys/screens/select_sucursal_screen.dart';
import 'package:centyneg_sys/screens/tabla_valores_screen.dart';
import 'package:centyneg_sys/screens/tipo_docs_screen.dart';
import 'package:centyneg_sys/screens/transferencia_screen.dart';
import 'package:centyneg_sys/screens/usuarios_screen.dart';
import 'package:centyneg_sys/screens/ventas_touch_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:showcaseview/showcaseview.dart';

import '../screens/asiento_edit_screen.dart';
import '../screens/asiento_manual_screen.dart';
import '../screens/balance_general_screen.dart';
import '../screens/cajas_screen.dart';
import '../screens/cobranza_screen.dart';
import '../screens/compra_screen.dart';
import '../screens/egreso_screen.dart';
import '../screens/facturacion_screen.dart';
import '../screens/facturas_screen.dart';
import '../screens/generar_centro_costo_screen.dart';
import '../screens/generate_report_centro_screen.dart';
import '../screens/ingreso_screen.dart';
import '../screens/libros_screen.dart';
import '../screens/listado_centro_costo_screen.dart';
import '../screens/listado_ingresos_screen.dart';
import '../screens/orden_pago_screen.dart';
import '../screens/plan_de_cuentas_screen.dart';
import '../screens/principal_screen.dart';
import '../screens/productos_screen.dart';
import '../screens/registar_producto_screen.dart';
import '../screens/registrar_centro_costo_screen.dart';
import '../screens/registrar_cliente_screen.dart';
import '../screens/registrar_departamento_screen.dart';
import '../screens/select_caja_facturacion_screen.dart';
import '../screens/sucursales_screen.dart';
import '../screens/tipo_pago_screen.dart';

class AppRoute {

  static final routes = GoRouter(
    navigatorKey: GlobalKey<NavigatorState>(),
    initialLocation: '/main/0',
    routes: [
      GoRoute(
        path: '/main/:mobile',
        builder: (BuildContext context, GoRouterState state) {
          var webMobile= int.parse(state.pathParameters['mobile'] ?? '0');
          return  MainScreen(webMobile: webMobile,);
        },
      ),
      GoRoute(
        path: '/registrar_centro_costo',
        builder: (BuildContext context, GoRouterState state) {
          return const RegistrarCentroDeCostoScreen();
        },
      ),
      GoRoute(
        path: '/centro_de_costos',
        builder: (BuildContext context, GoRouterState state) {
          return const CentroDeCostosScreen();
        },
      ),
      GoRoute(
        path: '/transferencias',
        builder: (BuildContext context, GoRouterState state) {
          return const ListadoTransferencia();
        },
      ),
      GoRoute(
          path: '/ingresos',
          builder: (_, state) {
            return const ListadoIngresoScreen();
          }
      ),
      GoRoute(
          path: '/transferencia',
          builder: (_, state) {
            return const TransferenciaScreen();
          }
      ),
      GoRoute(
          path: '/egresos',
          builder: (_, state) {
            return const ListadoEgresoScreen();
          }
      ),
      GoRoute(
          path: '/cobranzas',
          builder: (_, state) {
            return const ListadoCobranzasScreen();
          }
      ),
      GoRoute(
          path: '/docs',
          builder: (_, state) {
            return const TipoDocsScreen();
          }
      ),
      GoRoute(
          path: '/centros_costos',
          builder: (_, state) {
            return const ListadoCentroCostoScreen();
          }
      ),
      GoRoute(
          path: '/pagos',
          builder: (_, state) {
            return const ListadoOpScreen();
          }
      ),
      GoRoute(
        path: '/arqueos',
        builder: (BuildContext context, GoRouterState state) {
          return const ArqueosScreen();
        },
      ),
      GoRoute(
        path: '/registar-arqueo',
        builder: (BuildContext context, GoRouterState state) {
          return const RegistrarArqueoScreen();
        },
      ),
      GoRoute(
        path: '/informe-stock',
        builder: (BuildContext context, GoRouterState state) {
          return const InformeStockScreen();
        },
      ),
      GoRoute(
        path: '/informe-rentabilidad',
        builder: (BuildContext context, GoRouterState state) {
          return const InformeRentabilidadScreen();
        },
      ),
      GoRoute(
        path: '/cuenta_corriente',
        builder: (BuildContext context, GoRouterState state) {
          return const CuentaCorrienteScreen();
        },
      ),
      GoRoute(
        path: '/fact_touch',
        builder: (BuildContext context, GoRouterState state) {
          return const VentasTouchScreen();
        },
      ),
      GoRoute(
        path: '/reporte_boucher',
        builder: (BuildContext context, GoRouterState state) {
          return const BoucherReporteScreen();
        },
      ),
      GoRoute(
        path: '/registar-boucher',
        builder: (BuildContext context, GoRouterState state) {
          return const RegistrarBoucherScreen();
        },
      ),
      GoRoute(
        path: '/registar-tipo-de-cuenta',
        builder: (BuildContext context, GoRouterState state) {
          return const RegistrarTipoCuentaScreen();
        },
      ),
      GoRoute(
        path: '/principal',
        builder: (BuildContext context, GoRouterState state) {
          return ShowCaseWidget(
            builder: Builder(
                builder: (context) => const PrincipalScreen()
            ),
          );
        },
      ),
      GoRoute(
        path: '/plan_cuentas',
        builder: (BuildContext context, GoRouterState state) {
          return const PlanDeCuentasScreen();
        },
      ),
      GoRoute(
        path: '/plan_cuentas2',
        builder: (BuildContext context, GoRouterState state) {
          return const PlanDeCuentasScreen2();
        },
      ),
      GoRoute(
        path: '/registrar_cuenta/:id',
        builder: (BuildContext context, GoRouterState state) {
          return RegistrarCuentaScreen(
            id: int.parse(state.pathParameters['id'] ?? '0'),);
        },
      ),
      GoRoute(
        path: '/ingreso',
        builder: (BuildContext context, GoRouterState state) {
          return const IngresoScreen();
        },
      ),
      GoRoute(
        path: '/egreso',
        builder: (BuildContext context, GoRouterState state) {
          return const EgresoScreen();
        },
      ),
      GoRoute(
        path: '/balance_general',
        builder: (BuildContext context, GoRouterState state) {
          return const BalanceGeneralScreen();
        },
      ),
      GoRoute(
        path: '/asiento_manual',
        builder: (BuildContext context, GoRouterState state) {
          return const AsientoManualScreen();
        },
      ),
      GoRoute(
        path: '/orden_pago',
        builder: (BuildContext context, GoRouterState state) {
          return const OrdenPagoScreen();
        },
      ),
      GoRoute(
        path: '/cobranza',
        builder: (BuildContext context, GoRouterState state) {
          return  CobranzaScreen();
        },
      ),
      GoRoute(
        path: '/asiento_centro_costo',
        builder: (BuildContext context, GoRouterState state) {
          return
            ShowCaseWidget(
              builder: Builder(
                  builder: (context) => const GenerarCentroCostoScreen()
              ),
            );
        },
      ),
      GoRoute(
        path: '/gestion_asientos/:id',
        builder: (BuildContext context, GoRouterState state) {
          int asientoId = int.parse(state.pathParameters['id'] ?? '0');
          return AsientoEditScreen(id: asientoId);
        },
      ),
      GoRoute(
        path: '/asientos',
        builder: (BuildContext context, GoRouterState state) {
          return const AsientosScreen();
        },
      ),
      GoRoute(
        path: '/productos',
        builder: (BuildContext context, GoRouterState state) {
          return const ProductosScreen();
        },
      ),
      GoRoute(
        path: '/departamentos',
        builder: (BuildContext context, GoRouterState state) {
          return const DepartamentosScreen();
        },
      ),
      GoRoute(
        path: '/registrar-departamento',
        builder: (BuildContext context, GoRouterState state) {
          return const RegistrarDepartamentoScreen();
        },
      ),
      GoRoute(
        path: '/registrar_producto/:id/:edit',
        builder: (BuildContext context, GoRouterState state) {
          var productId= int.parse(state.pathParameters['id'] ?? '0');
          var edit= int.parse(state.pathParameters['edit'] ?? '0');
          return  RegistrarProductoScreen(productId: productId,edit: edit == 1 ? true : false,);
        },
      ),
      GoRoute(
        path: '/gestion-tablas',
        builder: (BuildContext context, GoRouterState state) {
        return const TablaValoresScreen();
        },
      ),
      GoRoute(
        path: '/facturacion',
        builder: (BuildContext context, GoRouterState state) {
          return const FacturacionScreen();
        },
      ),
      GoRoute(
        path: '/tipos_de_pago',
        builder: (BuildContext context, GoRouterState state) {
          return const TipoPagoScreen();
        },
      ),
      GoRoute(
        path: '/select_caja_screen',
        builder: (BuildContext context, GoRouterState state) {
          return const SelectCajaFacturacionScreen();
        },
      ),
      GoRoute(
        path: '/compra_screen',
        builder: (BuildContext context, GoRouterState state) {
          return const CompraScreen();
        },
      ),
      GoRoute(
        path: '/caja',
        builder: (BuildContext context, GoRouterState state) {
          return const CajaScreen();
        },
      ),
      GoRoute(
        path: '/facturas',
        builder: (BuildContext context, GoRouterState state) {
          return const FacturasScreen();
        },
      ),
      GoRoute(
        path: '/registrar_cliente',
        builder: (BuildContext context, GoRouterState state) {
          return const RegistrarClienteScreen();
        },
      ),
      GoRoute(
        path: '/clientes',
        builder: (BuildContext context, GoRouterState state) {
          return const ClientesScreen();
        },
      ),
      GoRoute(
        path: '/libros',
        builder: (BuildContext context, GoRouterState state) {
          return const LibrosScreen();
        },
      ),
      GoRoute(
        path: '/report-centro',
        builder: (BuildContext context, GoRouterState state) {
          return const GenerateReportCentroScreen();
        },
      ),
      GoRoute(
        path: '/select-sucursal',
        builder: (BuildContext context, GoRouterState state) {
          return  SelecSucursalScreen();
        },
      ),
      GoRoute(
        path: '/usuarios/:clientId',
        builder: (BuildContext context, GoRouterState state) {
          final clientId = int.parse(state.pathParameters['clientId'] ?? '0');
          return UsuariosScreen(clientId: clientId,);
        },
      ),
      GoRoute(
        path: '/sucursales',
        builder: (BuildContext context, GoRouterState state) {
          return const SucursalesScreen();
        },
      ),
    ],
  );

}