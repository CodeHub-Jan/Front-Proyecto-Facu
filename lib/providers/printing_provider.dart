import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:universal_html/html.dart' as html;

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

class PrintingProvider extends ChangeNotifier {
  Future printPdfByBase64(String base64) async {
    var pdfData = base64Decode(base64);
    await Printing.layoutPdf(onLayout: (_) => pdfData);
  }
  Future downloadExcelFromBase64(String base64Data) async {

    List<int> bytes = base64.decode(base64Data);

    String? mimeType = lookupMimeType('xlsx');

    final blob = html.Blob([Uint8List.fromList(bytes)], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..target = 'blank'
      ..download = 'libro.xlsx'
      ..click();

    html.Url.revokeObjectUrl(url);
  }

}