import 'dart:convert';
import 'dart:html';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import '../commons/Globals.dart';
import '../commons/http_override.dart';
import '../commons/local_storage_keys.dart';
import '../models/items_models.dart';

class ProductProvider extends ChangeNotifier {
  final Storage _localStorage = window.localStorage;
  List<ItemModel> accounts = [];
  List<dynamic> products=[];
  Map<String, List<ItemModel>> values= {};
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

  loadAllAccounts() async {
    var me= await getMe();
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/accounts/get-imputables', {
      'clientId' : me['clientId'].toString()
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body) as List<dynamic>;
      accounts = data.map((e) => ItemModel(e['id'], e['name'])).toList();
    }
  }
  loadValues() async {
    var me= await getMe();
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/productos/get-tabla-valores', {
      'clientId':me['clientId'].toString()
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body) as Map<String,dynamic>;
      data.forEach((key, dynamicList) {
        if (dynamicList is List) {
          values[key.toLowerCase()] = dynamicList.map((item) {
            return ItemModel(item['id'],item['title']);
          }).toList();
        }
      });
      print(values);
    }
  }
  Future<bool> registrarProducto(Map body) async{
    var me= await getMe();
    body['clientId']=me['clientId'];
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/productos/registrar', {
    });
    var response = await http.post(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
      body: jsonEncode(body)
    );
    if(response.statusCode==200){
      return true;
    }
    else {
      return false;
    }
  }
   loadProducts() async{
    var me= await getMe();
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/productos/get-products', {
      'clientId':me['clientId'].toString()
    });
    var response = await http.get(url,
        headers: {
          "Access-Control-Allow-Origin": "*",
          'Content-Type': 'application/json'
        },
    );
    if(response.statusCode==200){
     products= jsonDecode(response.body) as List<dynamic>;
    }
  }
  Future<Map> getProduct(int id) async{
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/productos/get-product', {
      'id':id.toString()
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    if(response.statusCode==200){
      return jsonDecode(response.body) as Map;
    }
    return {};
  }
}