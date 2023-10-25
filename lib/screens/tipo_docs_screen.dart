import 'package:centyneg_sys/commons/Globals.dart';
import 'package:dio/dio.dart';
import 'package:editable/editable.dart';
import 'package:flutter/material.dart';

class TipoDocsScreen extends StatefulWidget {
  const TipoDocsScreen({super.key});

  @override
  State<TipoDocsScreen> createState() => _TipoDocsScreenState();
}

class _TipoDocsScreenState extends State<TipoDocsScreen> {
  final _editableKey = GlobalKey<EditableState>();
  final dio= Dio(BaseOptions(baseUrl: Globals.apiUrl));
  @override
  Widget build(BuildContext context) {
   return Scaffold(
      body: SingleChildScrollView(
        child: Container(

          width: 1000,
          height: 500,
          child: Editable(
            key: _editableKey,
            saveIcon: Icons.save,
            zebraStripe: true,
            stripeColor2: Colors.grey,
            showSaveIcon: true,
            saveIconSize: 40,
            borderColor: Colors.blueGrey,
            columns: [
              {"title":'Nombre', 'widthFactor': 0.2, 'key':'name'},
              {"title":'Operaciones', 'widthFactor': 0.2, 'key':'operacion'},
            ],
            rows: [
              {'name':'ASOJDOASD','operacion':['ASJDOSAJD','SDASD']}
            ],
          ),
        )
      ),
    );
  }
}
