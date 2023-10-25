import 'package:centyneg_sys/commons/Globals.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class VentasTouchScreen extends StatefulWidget {
  const VentasTouchScreen({super.key});

  @override
  State<VentasTouchScreen> createState() => _VentasTouchScreenState();
}


class _VentasTouchScreenState extends State<VentasTouchScreen> {
final dio= Dio(BaseOptions(baseUrl: Globals.apiUrl));
loadDataFromApi() async{

}
  @override
  Widget build(BuildContext context) {
    var size= MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: size.width,
          height: size.height,
          child: Stack(
            children: [

            ],
          ),
        ),
      ),
    );
  }
}
