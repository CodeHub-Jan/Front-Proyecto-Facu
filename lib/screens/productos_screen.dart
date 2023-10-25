import 'package:centyneg_sys/commons/Globals.dart';
import 'package:centyneg_sys/providers/printing_provider.dart';
import 'package:centyneg_sys/providers/product_provider.dart';
import 'package:centyneg_sys/providers/sys_data_provider.dart';
import 'package:centyneg_sys/widgets/loading_widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';

import '../commons/app_color.dart';

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  late PlutoGridStateManager gridState;
bool isLoading=true;
  late ProductProvider provider;
loadDataFromApi() async{
  await provider.loadProducts();
  setState(() {
    isLoading=false;
  });
}
final dio= Dio(BaseOptions(baseUrl: Globals.apiUrl));
@override
  void initState() {
  provider= Provider.of<ProductProvider>(context, listen: false);
  loadDataFromApi();
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    var size = MediaQuery
        .of(context)
        .size;
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColor.white),
        title: Text(
          'Mantenimiento de Productos',
          style: TextStyle(color: AppColor.white),),
        backgroundColor: AppColor.darkBlue,),
      body: isLoading? LoadingWidget(): SingleChildScrollView(

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
                        context.go('/registrar_producto/0/0');
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
                        await provider.loadProducts();
                        gridState.refRows.clear();
                        gridState.insertRows(0,provider.products.map((e) =>
                            PlutoRow(cells: {
                              'id': PlutoCell(value: e['id']),
                              'code': PlutoCell(value: e['codigoBarra']),
                              'name': PlutoCell(value: e['nombre']),
                              'marca': PlutoCell(value: e['marca']),
                              'medida': PlutoCell(value: e['medida']),
                              'familia': PlutoCell(value: e['familia']),
                              'stock': PlutoCell(value: e['stock']),
                              'precio': PlutoCell(value: e['precio1']),
                              'ope':PlutoCell(value:'')
                            })).toList() );
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
                    cellTextStyle: TextStyle(fontSize: 14, color: Colors.blueAccent),
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
                  PlutoColumn(title: 'CODIGO BARRA.',
                      field: 'code',
                      type: PlutoColumnType.text(),
                      width: 200,readOnly: true),
                  PlutoColumn(title: 'NOMBRE.',
                      field: 'name',
                      type: PlutoColumnType.text(),
                      width: 500,readOnly: true),
                  PlutoColumn(title: 'MARCA.',
                      field: 'marca',
                      type: PlutoColumnType.text(),
                      width: 200,readOnly: true),
                  PlutoColumn(title: 'UNIDAD DE MEDIDA.',
                      field: 'medida',
                      type: PlutoColumnType.text(),
                      width: 200,readOnly: true),
                  PlutoColumn(title: 'FAMILIA.',
                      field: 'familia',
                      type: PlutoColumnType.text(),
                      width: 200,readOnly: true),
                  PlutoColumn(title: 'STOCK.',
                      field: 'stock',
                      type: PlutoColumnType.text(),
                      width: 200,readOnly: true),
                  PlutoColumn(title: 'PRECIO.',
                      field: 'precio',
                      type: PlutoColumnType.currency(symbol: '₲'),
                      width: 200,readOnly: true),
                  PlutoColumn(title: 'OPE.',
                      field: 'ope',
                      type: PlutoColumnType.text(),
                      width: 150,readOnly: true,
                    renderer: (rendererContext) {
                      return Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.book_outlined,
                            ),
                            onPressed: () async {
                              EasyLoading.show(status: 'Generando Reporte');
var id= rendererContext.row.cells['id']?.value;
var result= await dio.get('/api/reportes/generar-informe-stock',queryParameters: {
  'id':id
});
var base64=result.data;
var printing= Provider.of<PrintingProvider>(context, listen: false);
EasyLoading.dismiss(animation: true);
printing.printPdfByBase64(base64);
                            },
                            iconSize: 18,
                            color: Colors.green,
                            padding: const EdgeInsets.all(0),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.control_point_duplicate,
                            ),
                            onPressed: () async {

var id=rendererContext.row.cells['id']?.value;
context.go('/registrar_producto/$id/0');
                            },
                            iconSize: 18,
                            color: Colors.blue,
                            padding: const EdgeInsets.all(0),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                            ),
                            onPressed: () async {

                              var id=rendererContext.row.cells['id']?.value;
                              context.go('/registrar_producto/$id/1');
                            },
                            iconSize: 18,
                            color: Colors.blue,
                            padding: const EdgeInsets.all(0),
                          ),
                        ],
                      );
                    },
                  ),
                ], rows: provider.products.map((e) =>
                  PlutoRow(cells: {
                    'id': PlutoCell(value: e['id']),
                    'code': PlutoCell(value: e['codigoBarra']),
                    'name': PlutoCell(value: e['nombre']),
                    'marca': PlutoCell(value: e['marca']),
                    'medida': PlutoCell(value: e['medida']),
                    'familia': PlutoCell(value: e['familia']),
                    'stock': PlutoCell(value: e['stock']),
                    'precio': PlutoCell(value: e['precio1']),
                    'ope': PlutoCell(value: ''),
                  })).toList()
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
}
