import 'dart:html';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'dart:ui' as ui;
import '../widgets/alert_widget.dart';
import 'local_storage_keys.dart';

class Globals {
  static void setSucursal(int sucursalId){
    if(sucursalId == 0) return;
    var storage= LocalStorage(Globals.dataFileKeyName);
    storage.setItem('sucursal', sucursalId);
  }
  static int periodo = 2023;
  static int userId = 0;
  static String symbol = '₲';
  static bool isProduction = false;
  static String dataFileKeyName = 'cloudnet-data';
  static String prod = 'service.cloudnetpy.com:5119';
  static String local = '192.168.100.2:5119';
  static String pin = '1111';
  static int webMobile=0;
  static String apiUrl = isProduction ? 'https://$prod' : 'http://$local';
  static Uri getUrl(String resource, Map<String, String> queryParams) {
    return isProduction
        ? Uri.https(prod, resource, queryParams)
        : Uri.http(local, resource, queryParams);
  }
  static showMessage(String message, BuildContext context) async {
    await showDialog(
        context: context,
        builder: (_) => AlertWidget(
            title: 'Sistema Contable - CloudNet', message: message));
  }

  static Future<Map> getMe() async {
    Storage _localStorage = window.localStorage;
    var userId = _localStorage[LocalStorageKeys.userId];
    var fecth = await Dio(BaseOptions(baseUrl: apiUrl))
        .get('/api/users/me', queryParameters: {'id': userId});
    return fecth.data as Map;
  }

  static showQuestionDialog(String title, String content, BuildContext context,
      ui.VoidCallback continueAction, ui.VoidCallback cancelAction) {
    Widget cancelButton = TextButton(
      onPressed: cancelAction,
      child: const Text("Cancelar"),
    );
    Widget continueButton = TextButton(
      onPressed: continueAction,
      child: const Text("Continuar"),
    );

    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(
        content,
        style: TextStyle(fontSize: 20),
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static String formatNumberToLocate(double value) =>
      NumberFormat.decimalPatternDigits(decimalDigits: 0, locale: 'es-PY')
          .format(value);
}
