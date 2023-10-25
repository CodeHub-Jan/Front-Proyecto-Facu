import 'package:centyneg_sys/commons/app_route.dart';
import 'package:centyneg_sys/providers/edit_data_provider.dart';
import 'package:centyneg_sys/providers/facturacion_provider.dart';
import 'package:centyneg_sys/providers/graphics_provider.dart';
import 'package:centyneg_sys/providers/printing_provider.dart';
import 'package:centyneg_sys/providers/product_provider.dart';
import 'package:centyneg_sys/providers/sys_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const AppState());
}
class AppState extends StatelessWidget {
  const AppState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_)=> SysDataProvider()),
        ChangeNotifierProvider(create: (_)=> PrintingProvider()),
        ChangeNotifierProvider(create: (_)=> ProductProvider()),
        ChangeNotifierProvider(create: (_)=> FacturacionProvider()),
        ChangeNotifierProvider(create: (_)=> EditDataProvider()),
        ChangeNotifierProvider(create: (_)=> GraphicsProvider()),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'CloudNet',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: AppRoute.routes,
      builder: EasyLoading.init(),
    );
  }
}


