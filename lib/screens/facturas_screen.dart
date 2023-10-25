import 'package:centyneg_sys/commons/Globals.dart';
import 'package:centyneg_sys/providers/facturacion_provider.dart';
import 'package:centyneg_sys/providers/printing_provider.dart';
import 'package:centyneg_sys/providers/product_provider.dart';
import 'package:centyneg_sys/providers/sys_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';

import '../commons/app_color.dart';

class FacturasScreen extends StatefulWidget {
  const FacturasScreen({super.key});

  @override
  State<FacturasScreen> createState() => _FacturasScreenState();
}

class _FacturasScreenState extends State<FacturasScreen> {
  late PlutoGridStateManager gridState;
  var facturas=[];
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<ProductProvider>(context);
    var dataProvider = Provider.of<SysDataProvider>(context);
    var factProvider = Provider.of<FacturacionProvider>(context);
    factProvider.getFacturas()
        .then((value) =>
    {
      facturas = value,
      gridState.refRows.clear(),
      gridState.insertRows(0, facturas.map((e) =>
          PlutoRow(cells: {
            'id': PlutoCell(value: e['id']),
            'doc': PlutoCell(value: e['tipoDoc']),
            'cliente': PlutoCell(value: e['cliente']),
            'condicion': PlutoCell(value: e['condicion']),
            'docNumber': PlutoCell(value: e['docNumber']),
            'fecha': PlutoCell(value: e['fecha']),
            'opciones': PlutoCell(value: ''),
          })).toList())
    });

    var size = MediaQuery
        .of(context)
        .size;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColor.white),
        title: Text(
          'Facturacion',
          style: TextStyle(color: AppColor.white),),
        backgroundColor: AppColor.darkBlue,),
      body: SingleChildScrollView(

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10,),
            Row(
              children: [
                SizedBox(
                  width: 90,
                  height: 70,
                  child: FittedBox(
                    child: FloatingActionButton(
                      backgroundColor: AppColor.darkBlue,
                      onPressed: () async {
                        await provider.loadAllAccounts();
                        await provider.loadValues();
                        await provider.loadProducts();
                        await dataProvider.getClients2();
                        await factProvider.loadCajas();
                        await dataProvider.getTiposPagos(7);
                        context.go('/select_caja_screen');
                      },
                      child: const Icon(
                        Icons.add,
                        size: 35,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 90,
                  height: 70,
                  child: FittedBox(
                    child: FloatingActionButton(
                      backgroundColor: AppColor.darkBlue,
                      onPressed: () async {
                        await loadFacturas(factProvider);
                      },
                      child: const Icon(
                        Icons.refresh,
                        size: 35,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20,),
            SizedBox(
              width: size.width,
              height: size.height * 0.90,
              child: PlutoGrid(
                configuration: const PlutoGridConfiguration(
                  columnFilter: PlutoGridColumnFilterConfig(
                    debounceMilliseconds: 0,
                  ),
                  style: PlutoGridStyleConfig(
                    cellTextStyle: TextStyle(fontSize: 13,
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold),
                    columnTextStyle: TextStyle(fontSize: 15),
                    rowHeight: 25,
                    columnHeight: 30,
                  ),
                  scrollbar: PlutoGridScrollbarConfig(
                    isAlwaysShown: true,
                    draggableScrollbar: true,
                  ),
                  enableMoveDownAfterSelecting: false,
                  columnSize: PlutoGridColumnSizeConfig(
                      restoreAutoSizeAfterInsertColumn: true),
                  enterKeyAction: PlutoGridEnterKeyAction.toggleEditing,

                ),
                columns: [
                  PlutoColumn(title: 'ID.',
                      field: 'id',
                      type: PlutoColumnType.text(),
                      width: 100,
                      readOnly: true),
                  PlutoColumn(title: 'TIPO DE DOCUMENTO.',
                      field: 'doc',
                      type: PlutoColumnType.text(),
                      width: 200,
                      readOnly: true),
                  PlutoColumn(title: 'CLIENTE.',
                      field: 'cliente',
                      type: PlutoColumnType.text(),
                      width: 500,
                      readOnly: true),
                  PlutoColumn(title: 'CONDICION.',
                      field: 'condicion',
                      type: PlutoColumnType.text(),
                      width: 130,
                      readOnly: true),
                  PlutoColumn(title: 'Nº DOCUMENTO.',
                      field: 'docNumber',
                      type: PlutoColumnType.text(),
                      width: 170,
                      readOnly: true),
                  PlutoColumn(title: 'FECHA',
                      field: 'fecha',
                      type: PlutoColumnType.text(),
                      width: 170,
                      readOnly: true),
                  PlutoColumn(title: 'OPCIONES',
                    field: 'opciones',
                    type: PlutoColumnType.text(),
                    width: 100,
                    readOnly: true,
                    renderer: (rendererContext) {
                      return Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.cancel_outlined,
                            ),
                            onPressed: () {
                              var nroFactura = rendererContext.row
                                  .cells['docNumber']?.value;
                              var fecha = rendererContext.row.cells['fecha']
                                  ?.value;
                              Globals.showQuestionDialog('Atención Usuario',
                                  '¿Desea anular la factura Nº $nroFactura de fecha $fecha?',
                                  context, () async {
                                    var id = rendererContext.row.cells['id']
                                        ?.value ?? 0;
                                    var result = await factProvider
                                        .anularFactura(id);
                                    if (result) {
                                      Navigator.of(context, rootNavigator: true)
                                          .pop();
                                      await loadFacturas(factProvider);
                                    }
                                  }, () {
                                    Navigator.of(context, rootNavigator: true)
                                        .pop();
                                  });
                            },
                            iconSize: 25,
                            color: Colors.red,
                            padding: const EdgeInsets.all(0),
                          ),
                          IconButton(
                            icon: const FaIcon(
                             FontAwesomeIcons.print,
                            ),
                            onPressed: () async {

                                    var id = rendererContext.row.cells['id']
                                        ?.value ?? 0;
                                    var result = await factProvider
                                        .reprintFactura(id,rendererContext.row.cells['doc']?.value ?? '');
                                    var printProvider = Provider.of<PrintingProvider>(context,listen: false);
                                    await printProvider.printPdfByBase64(result);
                            },
                            iconSize: 25,
                            color: Colors.green,
                            padding: const EdgeInsets.all(0),
                          ),
                        ],
                      );
                    },
                  ),
                ], rows: []
                , onLoaded: (a) {
                gridState = a.stateManager;
                a.stateManager.setShowColumnFilter(true);
              },
              ),
            )
          ],
        ),
      ),
    );
  }
  loadFacturas(FacturacionProvider provider) async{
    facturas = await provider.getFacturas();
    gridState.refRows.clear();
    gridState.insertRows(0,facturas.map((e) => PlutoRow(cells: {
      'id':PlutoCell(value: e['id']),
      'doc':PlutoCell(value: e['tipoDoc']),
      'cliente':PlutoCell(value: e['cliente']),
      'condicion':PlutoCell(value: e['condicion']),
      'docNumber':PlutoCell(value: e['docNumber']),
      'fecha':PlutoCell(value: e['fecha']),
      'opciones':PlutoCell(value: ''),
    })).toList());
  }
}
