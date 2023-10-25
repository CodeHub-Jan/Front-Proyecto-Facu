import 'dart:convert';
import 'dart:html';
import 'dart:io';
import 'package:centyneg_sys/commons/local_storage_keys.dart';
import 'package:flutter/material.dart';
import '../commons/Globals.dart';
import '../commons/http_override.dart';
import 'package:http/http.dart' as http;

class EditDataProvider extends ChangeNotifier {
  final Storage _localStorage = window.localStorage;

  EditDataProvider() {
  }
  Future<Map> loadAsientoToEdit(int id) async{
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/edits/get-asiento-edit', {
      'id': id.toString(),
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    return response.statusCode==200 ? jsonDecode(response.body)  as Map: {};
  }
  Future<List> getCuentas() async{
    var me= await getMe();
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/edits/get-cuentas', {
      'clientId': me['clientId'].toString(),
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    return response.statusCode==200 ? jsonDecode(response.body) as List : [];
  }
  Future<List> getEntidades() async{
    var me= await getMe();
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/entidades/get-all-gestion', {
      'clientId': me['clientId'].toString(),
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    return response.statusCode==200 ? jsonDecode(response.body) as List : [];
  }
  Future<bool> registrarCambios(Map body) async{
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/edits/edit-asiento', {
    });
    var response = await http.post(url,
      body: jsonEncode(body),
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    print(response.body);
    return response.statusCode==200 ;
  }
  Future<List> getAsientos() async{
    var me= await getMe();
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/edits/get-asientos', {
      'clientId': me['clientId'].toString(),
      'periodo': Globals.periodo.toString(),
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    return response.statusCode==200 ? jsonDecode(response.body) as List : [];
  }
  Future<Map<String, dynamic>> getMe() async {
    HttpOverrides.global = MyHttpOverrides();
    var userId = _localStorage[LocalStorageKeys.userId];
    var url = Globals.getUrl('/api/users/me', {
      'id': userId ?? '',
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body) as Map<String, dynamic>;
      return data;
    }
    return {};
  }

}