import 'dart:convert';
import 'dart:html';
import 'dart:io';
import 'package:centyneg_sys/commons/local_storage_keys.dart';
import 'package:centyneg_sys/models/Node.dart';
import 'package:centyneg_sys/models/items_models.dart';
import 'package:centyneg_sys/models/level_model.dart';
import 'package:flutter/material.dart';


import '../commons/Globals.dart';
import '../commons/http_override.dart';
import 'package:http/http.dart' as http;

import '../models/drop_item_model.dart';
import '../models/ingreso_model.dart';
class SysDataProvider extends ChangeNotifier {
  final Storage _localStorage = window.localStorage;

  SysDataProvider() {
    getCuentas();
  }

  List<TreeNode> accounts = [];
  List<ItemModel> operaciones = [];
  List<ItemModel> cuentasImputables = [];
  List<ItemModel> centroDeCostos = [];
  List<ItemModel> departamentos = [];
  List<ItemModel> tipoDePagos = [];
  List<ItemModel> bancos = [];
  List<ItemModel> tiposDocs = [];
  List<ItemModel> tiposDeCuentas = [];
  List<ItemsClientModel> clients = [];
  List<ItemModel> clients2 = [];
  List<ItemsClientModel> allAccounts = [];
  List<ItemModel> subCuentas = [];
  int number = 0;

  getCuentas() async {
    HttpOverrides.global = MyHttpOverrides();
    var me = await getMe();
    var url = Globals.getUrl('/api/accounts/get-cuentas', {
      'clientId': me['clientId'].toString()
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      var responseDeserialize = levelOneFromJson(response.body);
      accounts = responseDeserialize.map((e) =>
          TreeNode(title: e.name,
              children: e.list.map((e) =>
                  TreeNode(title: e.name,
                      children: e.list.map((e) =>
                          TreeNode(title: e.name,
                              children: e.list.map((e) =>
                                  TreeNode(title: e.name)).toList()

                          )).toList()
                  )).toList()
          )).toList();
      notifyListeners();
    }
  }

  List<LevelOne> levelOneFromJson(String str) =>
      List<LevelOne>.from(json.decode(str).map((x) => LevelOne.fromJson(x)));

  getTiposPagos(int tipo) async {
    var me = await getMe();
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/typeofpayments/get-all', {
      'tipoId': tipo.toString(),
      'clientId': me['clientId'].toString()
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body) as List<dynamic>;
      tipoDePagos = data.map((e) => ItemModel(e['id'], e['name'])).toList();
      notifyListeners();
    }
  }

  getCentroDeCostos() async {
    var me = await getMe();
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/modules/get-centro-de-costos', {
      'clientId': me['clientId'].toString()
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body) as List<dynamic>;
      centroDeCostos = data.map((e) => ItemModel(e['id'], '${e['name']}(${e['code']})')).toList();
      notifyListeners();
    }
  }
 Future<List> getAllCentros() async {
    var me = await getMe();
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/modules/get-centro-de-costos', {
      'clientId': me['clientId'].toString()
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    return response.statusCode == 200 ? jsonDecode(response.body) as List<dynamic>
        : [];
  }
  Future<List> getArqueos() async {
    var me = await getMe();
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/arqueos/listar-arqueos', {
      'clientId': me['clientId'].toString()
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    return response.statusCode == 200 ? jsonDecode(response.body) as List<dynamic>
        : [];
  }
  Future<bool> borrarCentroDeCosto(int id) async {
    var me = await getMe();
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/modules/borrar_centro-costo', {
      'id': id.toString()
    });
    var response = await http.delete(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    return response.statusCode==200;
  }
  Future<bool> borrarDepartamento(int id) async {
    var me = await getMe();
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/modules/borrar-departamento', {
      'id': id.toString()
    });
    var response = await http.delete(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    return response.statusCode==200;
  }
  getDepartamentos() async {
    var me = await getMe();
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/modules/get-departamentos', {
      'clientId': me['clientId'].toString()
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body) as List<dynamic>;
      departamentos = data.map((e) => ItemModel(e['id'], e['name'])).toList();
      notifyListeners();
    }
  }

  getTiposDoc() async {
    var me= await getMe();
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/modules/get-documentos', {
      'clientId':me['clientId'].toString()
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body) as List<dynamic>;
      tiposDocs = data.map((e) => ItemModel(e['id'], e['name'])).toList();
      notifyListeners();
    }
  }

  getClients() async {
    var me = await getMe();
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/entidades/get-all', {
      'clientId': me['clientId'].toString()
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body) as List<dynamic>;
      clients =
          data.map((e) => ItemsClientModel(e['id'], '${e['fullName']}(R.U.C ${e['ruc']})', e['ruc']))
              .toList();
      notifyListeners();
    }
  }

  getClients2() async {
    var me = await getMe();
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/entidades/get-all', {
      'clientId': me['clientId'].toString()
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body) as List<dynamic>;
      clients2 = data.map((e) => ItemModel(e['id'], e['fullName'])).toList();
      notifyListeners();
    }
  }

  getTiposDeCuentas(int operacionId) async {
    var me = await getMe();
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/accounts/get-tipos-de-cuentas', {
      'clientId': me['clientId'].toString(),
      'operacionId': operacionId.toString()
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body) as List<dynamic>;
      tiposDeCuentas = data.map((e) => ItemModel(e['id'], e['name'])).toList();
      notifyListeners();
    }
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

  Future<Map<String, dynamic>> getTipoDePago(int clientId, int id) async {
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/typeofpayments/get', {
      'id': id.toString(),
      'clientId': clientId.toString()
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
  Future<Map> getTypeOfPayment(int id) async {
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
   return response.statusCode==200 ? jsonDecode(response.body) as Map:{};
  }
Map loginData={};
  Future<Map> login(Map<String, dynamic> body) async {
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/users/login', {
    });
    var response = await http.post(url,
        headers: {
          "Access-Control-Allow-Origin": "*",
          'Content-Type': 'application/json'
        },
        body: jsonEncode(body)
    );
print(response.body);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body) as Map<String, dynamic>;
      _localStorage[LocalStorageKeys.userId] = data['id'].toString();
      return data;
    }
    return {};
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

  Future<(String, List<IngresoModel>, dynamic)> generarIngreso(
      Map<String, dynamic> body) async {
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/asientos/generar-asiento-ingresos2', {
    });
    var response = await http.post(url,
        headers: {
          "Access-Control-Allow-Origin": "*",
          'Content-Type': 'application/json'
        },
        body: jsonEncode(body)
    );
    List<IngresoModel> list = [];
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body) as Map<String, dynamic>;
      list = (data['list'] as List<dynamic>).map((e) =>
          IngresoModel(
              e['cuenta'],
              e['estado'],
              e['comentario'],
              e['comprobante'],
              e['moneda'],
              e['cuotas'],
              e['cambio'].toString(),
              e['montoOrigen'],
              e['debe'],
              e['haber'],
              e['vencimiento'])).toList();
      return (data['message'].toString(), list, data['id']);
    }
    return ('', list,0);
  }

  Future<(String, List<IngresoModel>, dynamic)> generarEgreso(
      Map<String, dynamic> body) async {
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/asientos/generar-asiento-egreso', {
    });
    var response = await http.post(url,
        headers: {
          "Access-Control-Allow-Origin": "*",
          'Content-Type': 'application/json'
        },
        body: jsonEncode(body)
    );
    List<IngresoModel> list = [];
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body) as Map<String, dynamic>;
      list = (data['list'] as List<dynamic>).map((e) =>
          IngresoModel(
              e['cuenta'],
              e['estado'],
              e['comentario'],
              e['comprobante'],
              e['moneda'],
              e['cuotas'],
              e['cambio'].toString(),
              e['montoOrigen'],
              e['debe'],
              e['haber'],
              e['vencimiento'])).toList();
      return (data['message'].toString(), list, data['id']);
    }
    return ('', list,0);
  }

  Future<String> generarOp(Map<String, dynamic> body) async {
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/asientos/generar-asiento-op', {
    });
    var response = await http.post(url,
        headers: {
          "Access-Control-Allow-Origin": "*",
          'Content-Type': 'application/json'
        },
        body: jsonEncode(body)
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body) as Map<String, dynamic>;
      return (data['message'].toString());
    }
    return '';
  }

  Future<String> generarCentro(Map<String, dynamic> body) async {
    var me = await getMe();
    HttpOverrides.global = MyHttpOverrides();
    body['clientId'] = me['clientId'];
    body['userId'] = me['id'];
    var url = Globals.getUrl('/api/asientos/generar-asiento-centro', {
    });
    var response = await http.post(url,
        headers: {
          "Access-Control-Allow-Origin": "*",
          'Content-Type': 'application/json'
        },
        body: jsonEncode(body)
    );
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body) as Map<String, dynamic>;
      return (data['message'].toString());
    }
    return '';
  }

  Future<String> generarCobranza(Map<String, dynamic> body) async {
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/asientos/generar-asiento-cobranza', {
    });
    var response = await http.post(url,
        headers: {
          "Access-Control-Allow-Origin": "*",
          'Content-Type': 'application/json'
        },
        body: jsonEncode(body)
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body) as Map<String, dynamic>;
      return (data['message'].toString());
    }
    return '';
  }

  Future getNumber(int operation) async {
    var me = await getMe();
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/asientos/get-value', {
      'clientId': me['clientId'].toString(),
      'operation': operation.toString(),
      'periodo': '2023'
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body) as Map<String, dynamic>;
      print(data['value']);
      number = data['value'];
    }
  }

  Future<String> generarLibroDiario(Map<String, dynamic> body) async {
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/asientos/generate-libro-diario', {
    });
    var response = await http.post(url,
        headers: {
          "Access-Control-Allow-Origin": "*",
          'Content-Type': 'application/json'
        },
        body: jsonEncode(body)
    );
    if (response.statusCode == 200) {
      var data = response.body;
      return data;
    }
    return '';
  }

  loadAllAccounts(Map<String, String> queryParams) async {
    HttpOverrides.global = MyHttpOverrides();
    var me = await getMe();
    queryParams['clientId'] = me['clientId'].toString();
    var url = Globals.getUrl('/api/accounts/get-imputables', queryParams);
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body) as List<dynamic>;
      allAccounts =
          data.map((e) => ItemsClientModel(e['id'], e['name'], e['code']))
              .toList();
      notifyListeners();
    }
  }

  Future<String> generarLibroMayor(Map<String, dynamic> body) async {
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/asientos/generate-libro-mayor', {
    });
    var response = await http.post(url,
        headers: {
          "Access-Control-Allow-Origin": "*",
          'Content-Type': 'application/json'
        },
        body: jsonEncode(body)
    );
    if (response.statusCode == 200) {
      var data = response.body;
      return data;
    }
    return '';
  }

  Future<String> generarLibro(Map<String, dynamic> body) async {
    HttpOverrides.global = MyHttpOverrides();
    var me = await getMe();
    body['clientId'] = me['clientId'];
    var url = Globals.getUrl('/api/reportes/generate-libro', {
    });
    var response = await http.post(url,
        headers: {
          "Access-Control-Allow-Origin": "*",
          'Content-Type': 'application/json'
        },
        body: jsonEncode(body)
    );
    if (response.statusCode == 200) {
      var data = response.body;
      return data;
    }
    return '';
  }

  Future<String> generarBalance(Map<String, dynamic> body) async {
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/asientos/generate-balance-general', {
    });
    var response = await http.post(url,
        headers: {
          "Access-Control-Allow-Origin": "*",
          'Content-Type': 'application/json'
        },
        body: jsonEncode(body)
    );
    if (response.statusCode == 200) {
      var data = response.body;
      return data;
    }
    return '';
  }

  Future loadOperaciones() async {
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/modules/get-operaciones', {
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body) as List<dynamic>;
      operaciones = data.map((e) => ItemModel(e['id'], e['name'])).toList();
    }
  }
  Future<List> getOperaciones() async {
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/modules/get-operaciones', {
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    return response.statusCode == 200 ? jsonDecode(response.body) as List: [];
  }
  Future<List> getTipoPagoArqueo() async {
    var me= await getMe();
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/arqueos/listar-pagos', {
      'clientId':me['clientId'].toString()
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    return response.statusCode == 200 ? jsonDecode(response.body) as List: [];
  }
  Future<List> getTiposDeCuentasList() async {
    var me= await getMe();
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/accounts/get-tipos-de-cuentas-gestion', {
      'clientId':me['clientId'].toString()
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    return response.statusCode == 200 ? jsonDecode(response.body) as List: [];
  }
  Future<List> getBouchers() async {
    var me= await getMe();
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/arqueos/listar-bouchers', {
      'clientId':me['clientId'].toString()
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    return response.statusCode == 200 ? jsonDecode(response.body) as List: [];
  }
  Future<List> getUsuarios() async {
    var me= await getMe();
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/users/listar-usuarios', {
      'clientId':me['clientId'].toString()
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    return response.statusCode == 200 ? jsonDecode(response.body) as List: [];
  }
  Future<List> getListarImputables(String filter) async {
    var me= await getMe();
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/accounts/listar-imputables', {
      'clientId':me['clientId'].toString()
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    return response.statusCode == 200 ? jsonDecode(response.body) as List: [];
  }
  Future loadCuentasImputables() async {
    HttpOverrides.global = MyHttpOverrides();
    var me = await getMe();
    var url = Globals.getUrl('/api/accounts/get-cuentas-imputables', {
      'clientId': me['clientId'].toString()
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body) as List<dynamic>;
      print(data);
      cuentasImputables =
          data.map((e) => ItemModel(e['id'], e['name'], moneda: e['moneda'], arqueo: e['arqueo']))
              .toList();
    }
  }

  Future getBancos() async {
    var me = await getMe();
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/modules/get-bancos', {
      'clientId': me['clientId'].toString()
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body) as List<dynamic>;
      bancos = data.map((e) => ItemModel(e['id'], e['name'])).toList();
    }
  }

  Future<List<dynamic>> getPendientes(int entidadId,
      int tipoOperacionId) async {
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/asientos/get-pendientes', {
      'entidadId': entidadId.toString(),
      'cuentaId': tipoOperacionId.toString()
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body) as List<dynamic>;
      return data;
    }
    return [];
  }

  Future<List<dynamic>> getPendientesCobranza(int entidadId,
      int cuentaId) async {
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/asientos/get-pendientes-cobranza', {
      'entidadId': entidadId.toString(),
      'cuentaId': cuentaId.toString()
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body) as List<dynamic>;
      return data;
    }
    return [];
  }

  Future loadImputablesOp() async {
    HttpOverrides.global = MyHttpOverrides();
    var me = await getMe();
    var url = Globals.getUrl('/api/accounts/get-cuentas-imputables-op', {
      'clientId': me['clientId'].toString()
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body) as List<dynamic>;
      cuentasImputables =
          data.map((e) => ItemModel(e['id'], e['name'], moneda: e['moneda']))
              .toList();
    }
  }

  Future loadImputablesCobranza() async {
    HttpOverrides.global = MyHttpOverrides();
    var me = await getMe();
    var url = Globals.getUrl('/api/accounts/get-cuentas-imputables-cobranza', {
      'clientId': me['clientId'].toString()
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body) as List<dynamic>;
      cuentasImputables =
          data.map((e) => ItemModel(e['id'], e['name'], moneda: e['moneda']))
              .toList();
    }
  }

  Future loadImputablesCentroCosto() async {
    HttpOverrides.global = MyHttpOverrides();
    var me = await getMe();
    var url = Globals.getUrl('/api/accounts/get-cuentas-imputables-by-centro', {
      'clientId': me['clientId'].toString()
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {

      var data = jsonDecode(response.body) as List<dynamic>;
      print(data);
      cuentasImputables =
          data.map((e) => ItemModel(e['id'], e['name'], moneda: e['moneda']['name']))
              .toList();
    }
  }

  Future<String> generaAsientoManual(Map<String, dynamic> body) async {
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/asientos/generar-asiento-manual', {
    });
    var response = await http.post(url,
        headers: {
          "Access-Control-Allow-Origin": "*",
          'Content-Type': 'application/json'
        },
        body: jsonEncode(body)
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['message'];
    }
    return '';
  }

  registerTipoPago(Map body) async {
    var me = await getMe();
    body['clientId'] = me['clientId'];
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/typeofpayments/create', {
    });
    var response = await http.post(url,
        headers: {
          "Access-Control-Allow-Origin": "*",
          'Content-Type': 'application/json'
        },
        body: jsonEncode(body)
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['id'];
    }
    return 0;
  }

  List<dynamic> allPagos = [];

  Future loadAllPagos() async {
    var me = await getMe();
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/typeofpayments/get-all-gestion', {
      'clientId': me['clientId'].toString()
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body) as List<dynamic>;
      allPagos = data;
    }
  }

  List<ItemModel> tipoOperaciones = [];

  Future loadAllOperaciones() async {
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/typeofpayments/get-operaciones', {
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body) as List<dynamic>;
      tipoOperaciones =
          data.map((e) => ItemModel(e['id'], e['name'])).toList();
    }
  }

  Future<bool> borrarTipoPago(int id) async {
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/typeofpayments/borrar', {
      'id': id.toString()
    });
    var response = await http.delete(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  List<ItemModel> sucursales = [];

  Future loadSucursales() async {
    var me = await getMe();
    HttpOverrides.global = MyHttpOverrides();
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
      var data = jsonDecode(response.body) as List<dynamic>;
      sucursales = data.map((e) => ItemModel(e['id'], e['name'])).toList();
    }
  }

  List<dynamic> cajasGestion = [];

  Future loadCajasGestion() async {
    var me = await getMe();
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/cajas/get-cajas-gestion', {
      'clientId': me['clientId'].toString()
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body) as List<dynamic>;
      cajasGestion = data;
    }
  }

  Future<int> registrarCaja(Map<String, dynamic> body) async {
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/cajas/crear-caja', {
    });
    var response = await http.post(url,
        headers: {
          "Access-Control-Allow-Origin": "*",
          'Content-Type': 'application/json'
        },
        body: jsonEncode(body)
    );
    print(response.body);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body) as Map;
      return data['id'];
    }
    return 0;
  }

  borrarCaja(int id) async {
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/cajas/borrar-caja', {
      'id': id.toString()
    });
    var response = await http.delete(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<bool> registrarCliente(Map body) async {
    var me = await getMe();
    body['clientId'] = me['clientId'];
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/entidades/registrar-cliente', {
    });
    var response = await http.post(url,
        headers: {
          "Access-Control-Allow-Origin": "*",
          'Content-Type': 'application/json'
        },
        body: jsonEncode(body)
    );
    return response.statusCode == 200;
  }
  Future<bool> registrarUsuario(Map body) async {
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/users/create', {
    });
    var response = await http.post(url,
        headers: {
          "Access-Control-Allow-Origin": "*",
          'Content-Type': 'application/json'
        },
        body: jsonEncode(body)
    );
    print(response.statusCode);
    return response.statusCode == 200;
  }
  Future<bool> registrarEmpresa(Map body) async {
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/clients/create-client', {
    });
    var response = await http.post(url,
        headers: {
          "Access-Control-Allow-Origin": "*",
          'Content-Type': 'application/json'
        },
        body: jsonEncode(body)
    );
    print(response.body);
    return response.statusCode == 200;
  }
  Future<List> getAllClientes() async {
    HttpOverrides.global = MyHttpOverrides();
    var me = await getMe();
    var url = Globals.getUrl('/api/entidades/get-all-gestion', {
      'clientId': me['clientId'].toString()
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List);
    }
    return [];
  }
 Map gridData= {};
Future<Map> loadAsientoManualGridData() async{
    var clients= await getAllClientes();
    var cuentas= await getCuentasImputables();
    return {
      'clientes': clients,
      'cuentas': cuentas
    };
}
  Future<List> loadEmpresas() async {
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/clients/get-all-clients', {
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List);
    }
    return [];
  }
  Future<List> loadUsers(int clientId) async {
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/clients/get-all-users', {
      'clientId': clientId.toString()
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List);
    }
    return [];
  }
  Future<bool> updateClient(Map body) async {
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/clients/update-client', {
    });
    var response = await http.put(url,
      body: jsonEncode(body),
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    return response.statusCode == 200;
  }
  Future<List> entitiesBackSearch(String math) async {
    var me= await getMe();
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/entidades/sugerir-cliente', {
      'clientId': me['clientId'].toString(),
      'math':math
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    if(response.body.isEmpty)
      return [];
    return (jsonDecode(response.body) as List);
  }
  Future<ItemsClientModel?> getEntidad(int id) async {
    var me= await getMe();
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/entidades/get', {
      'id': id.toString()
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    if(response.statusCode == 200){
      var data= jsonDecode(response.body) as Map;
      return ItemsClientModel(data['id'], data['fullName'],data['ruc']);
    }
    return null;
  }
  var monedas= [];
 loadMonedas() async {
    var me= await getMe();
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/monedas/get-monedas', {
      'clientId': me['clientId'].toString()
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    if(response.statusCode == 200){
      var data= jsonDecode(response.body) as List;
      monedas = data;
    }else{
      monedas=[];
    }
  }
  getMoneda(int id) async {
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/monedas/get-monedas', {
      'id':id.toString()
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    if(response.statusCode == 200){
      var data= jsonDecode(response.body) as Map;
      return data;
    }else{
    return {};
    }
  }
  getMonedaByTipoPago(int id) async {
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/monedas/get-moneda-by-tipo-pago', {
      'id':id.toString()
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    if(response.statusCode == 200){
      var data= jsonDecode(response.body) as Map;
      return data;
    }else{
      return {};
    }
  }
 Future<bool> updateMonedas(Map body) async {
    HttpOverrides.global = MyHttpOverrides();
    var me= await getMe();
    var url = Globals.getUrl('/api/monedas/actualizar-cotizaciones', {
      'clientId':me['clientId'].toString()
    });
    var response = await http.post(url,
      body: jsonEncode(body),
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
   return response.statusCode==200;
  }
  Future<List> loadCuentasContables() async {
    var me= await getMe();
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/accounts/get-cuentas2', {
      'clientId': me['clientId'].toString()
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    if(response.statusCode == 200){
      var data= jsonDecode(response.body) as List;
      return data;
    }else{
      return [];
    }
  }
  Future<List<DropItemModel>> getLeveOne() async {
    var me= await getMe();
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/accounts/get-level-one', {
      'clientId': '21'
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    if(response.statusCode == 200){
      var data= jsonDecode(response.body) as List;
      return data.map((e) => DropItemModel(e['id'],e['name'])).toList();
    }else{
      return [];
    }
  }
  Future<List<DropItemModel>> getLeveTwo(int id) async {
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/accounts/get-level-two', {
      'id': id.toString()
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    if(response.statusCode == 200){
      var data= jsonDecode(response.body) as List;
      return data.map((e) => DropItemModel(e['id'],e['name'])).toList();
    }else{
      return [];
    }
  }
  Future<List<DropItemModel>> getLevelThree(int id) async {
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/accounts/get-level-three', {
      'id': id.toString()
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    if(response.statusCode == 200){
      var data= jsonDecode(response.body) as List;
      return data.map((e) => DropItemModel(e['id'],e['name'])).toList();
    }else{
      return [];
    }
  }
  Future<List<DropItemModel>> getMonedas() async {
    HttpOverrides.global = MyHttpOverrides();
    var me= await getMe();
    var url = Globals.getUrl('/api/accounts/get-moedas', {
      'clientId': me['clientId'].toString()
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    return response.statusCode == 200 ? (jsonDecode(response.body) as List).map((e) => DropItemModel(e['id'],e['name'])).toList()  : [];
  }
  List<ItemModel> cuentasAsientoManual=[];
  Future<List> getCuentasImputables() async {
   var me= await getMe();
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/accounts/get-imputables', {
      'clientId': me['clientId'].toString()
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    print(response.statusCode);
    if(response.statusCode == 200){
      var data= jsonDecode(response.body) as List;
      return data;
    }else{
      return [];
    }
  }
 Future<Map> registrarCentroCosto(Map body) async {
    var me= await getMe();
    HttpOverrides.global = MyHttpOverrides();
    body['clientId']= me['clientId'];
    var url = Globals.getUrl('/api/modules/create-centro-costo', {
    });
    var response = await http.post(url,
      body: json.encode(body),
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
   return response.statusCode == 200 ? json.decode(response.body) as Map : {};
  }

  Future<Map> registrarBoucher(Map body) async {
    var me= await getMe();
    HttpOverrides.global = MyHttpOverrides();
    body['clientId']= me['clientId'];
    var url = Globals.getUrl('/api/arqueos/registrar-boucher', {
    });
    var response = await http.post(url,
      body: json.encode(body),
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    return response.statusCode == 200 ? json.decode(response.body) as Map : {};
  }
  Future<Map> registrarArqueo(Map body) async {
    var me= await getMe();
    HttpOverrides.global = MyHttpOverrides();
    body['clientId']= me['clientId'];
    var url = Globals.getUrl('/api/arqueos/registrar-arqueo', {
    });
    var response = await http.post(url,
      body: json.encode(body),
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    return response.statusCode == 200 ? json.decode(response.body) as Map : {};
  }
  Future<Map> registrarTipoDeCuenta(Map body) async {
    var me= await getMe();
    HttpOverrides.global = MyHttpOverrides();
    body['clientId']= me['clientId'];
    var url = Globals.getUrl('/api/accounts/registrar-tipo-cuenta', {
    });
    var response = await http.post(url,
      body: json.encode(body),
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    return response.statusCode == 200 ? json.decode(response.body) as Map : {};
  }
  Future<Map> registrarDepartamento(Map body) async {
    var me= await getMe();
    HttpOverrides.global = MyHttpOverrides();
    body['clientId']= me['clientId'];
    var url = Globals.getUrl('/api/modules/create-departamento', {
    });
    var response = await http.post(url,
      body: json.encode(body),
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    return response.statusCode == 200 ? json.decode(response.body) as Map : {};
  }
  Future<List> getAllDepartamentos() async {
    var me= await getMe();
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/modules/get-departamentos', {
      'clientId': me['clientId'].toString()
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    return response.statusCode==200 ? jsonDecode(response.body) as List : [];
  }
  Future<Map> getLevelFour(int id) async {
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/accounts/get-leveo-four', {
      'id':id.toString()
    });
    var response = await http.get(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    return response.statusCode==200 ? jsonDecode(response.body) as Map : {};
  }
  Future<bool> registrarCuentaContable(Map body) async {
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/accounts/registrar-cuenta', {
    });
    var response = await http.post(url,
      body: jsonEncode(body),
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    return response.statusCode==200 ? true  : false;
  }
  Future<bool> borrarCliente(int id) async {
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/clients/borrar-cliente', {
      'id':id.toString()
    });
    var response = await http.delete(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    return response.statusCode==200 ? true  : false;
  }
  Future<bool> borrarTipoDeCuenta(int id) async {
    HttpOverrides.global = MyHttpOverrides();
    var url = Globals.getUrl('/api/accounts/borrar-tipo-de-cuenta', {
      'id':id.toString()
    });
    var response = await http.delete(url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json'
      },
    );
    return response.statusCode==200 ? true  : false;
  }
}