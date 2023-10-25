import 'dart:convert';
import 'dart:html';
import 'dart:io';
import 'package:centyneg_sys/commons/local_storage_keys.dart';
import 'package:flutter/material.dart';
import '../commons/Globals.dart';
import '../commons/http_override.dart';
import 'package:http/http.dart' as http;

class GraphicsProvider extends ChangeNotifier {
  final Storage _localStorage = window.localStorage;

  GraphicsProvider() {

  }

Future<List> getGraphicsData(String cuenta) async{
    var me= await getMe();
  HttpOverrides.global = MyHttpOverrides();
  var url = Globals.getUrl('/api/graphics/get-evolution-by-account', {
    'clientId': me['clientId'].toString(),
    'account':cuenta,
    'periodo':Globals.periodo.toString()
  });
  var response = await http.get(url,
    headers: {
      "Access-Control-Allow-Origin": "*",
      'Content-Type': 'application/json'
    },
  );
  return response.statusCode == 200 ? jsonDecode(response.body) as List: [];
}
  Future<List> getGraphicsDifference() async{
    var me= await getMe();
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/graphics/get-difference-graphic', {
      'clientId': me['clientId'].toString(),
      'periodo':Globals.periodo.toString()
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    return response.statusCode == 200 ? jsonDecode(response.body) as List: [];
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