import 'dart:convert';
import 'dart:html';
import 'dart:io';

import 'package:centyneg_sys/commons/http_override.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../commons/Globals.dart';
import '../commons/local_storage_keys.dart';
import '../models/items_models.dart';
class FacturacionProvider extends ChangeNotifier {
  Map caja={};
  List<ItemModel> cajas = [];
  final Storage _localStorage = window.localStorage;

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

  Future<Map<String, dynamic>> getClient(int clientId) async {
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/entidades/get', {
      'id': clientId.toString(),
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
  Future<Map<String, dynamic>> getTipoPago(int id) async {
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/typeofpayments/get', {
      'id': id.toString(),
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
  Future<Map<String, dynamic>> getCaja(int id) async {
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/cajas/get-caja', {
      'id': id.toString(),
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

  loadCajas() async {
    HttpOverrides.global = MyHttpOverrides();
    var me = await getMe();
    var url = Globals.getUrl('/api/cajas/get-cajas', {
      'clientId': me['clientId'].toString(),
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body) as List<dynamic>;
      cajas = data.map((e) => ItemModel(e['id'], e['name'])).toList();
    }
  }
  Future<String> registrarFactura(Map  body) async {
    HttpOverrides.global = MyHttpOverrides();
    var me = await getMe();
    body['clientId']=me['clientId'];
    body['userId']=me['id'];
    var url = Globals.getUrl('/api/facturacion/crear-factura', {
    });
    var response = await http.post(url,
      body: jsonEncode(body),
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      var data= response.body;
      return data;
    }
     return '';
  }
  Future<Map> registrarSucursal(Map  body) async {
    HttpOverrides.global = MyHttpOverrides();
    var me = await getMe();
    body['clientId']=me['clientId'];
    var url = Globals.getUrl('/api/cajas/crear-sucursal', {
    });
    var response = await http.post(url,
      body: jsonEncode(body),
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      var data= jsonDecode(response.body) as Map;
      return data;
    }
    return {};
  }
  Future<bool> registrarCompra(Map  body) async {
    HttpOverrides.global = MyHttpOverrides();
    var me = await getMe();
    body['clientId']=me['clientId'];
    body['userId']=me['id'];
    var url = Globals.getUrl('/api/facturacion/crear-compra', {
    });
    var response = await http.post(url,
      body: jsonEncode(body),
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    print(response.body);
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }
  Future<List<dynamic>> getFacturas() async {
    HttpOverrides.global = MyHttpOverrides();
    var me = await getMe();
    var url = Globals.getUrl('/api/facturacion/get-facturas', {
      'clientId': me['clientId'].toString()
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List<dynamic>);
    }
    return [];
  }
  Future<List<dynamic>> getSucursales() async {
    HttpOverrides.global = MyHttpOverrides();
    var me = await getMe();
    var url = Globals.getUrl('/api/cajas/get-sucursales', {
      'clientId': me['clientId'].toString()
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List<dynamic>);
    }
    return [];
  }
  Future<String> reprintFactura(int id, String type) async {
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/facturacion/reprint-factura', {
      'id':id.toString()
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    print(response.body);
    if (response.statusCode == 200) {
      var data= response.body;
      return data;
    }
    return '';
  }
  Future<bool> anularFactura(int id) async {
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/facturacion/anular-factura', {
      'id':id.toString(),
    });
    var response = await http.delete(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    return response.statusCode == 200;
  }
}