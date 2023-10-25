import 'package:centyneg_sys/commons/Globals.dart';
import 'package:centyneg_sys/providers/sys_data_provider.dart';
import 'package:centyneg_sys/widgets/loading_widget.dart';
import 'package:dio/dio.dart';
import 'package:empty_widget/empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../providers/printing_provider.dart';

class ListadoComprasScreen extends StatefulWidget {
  const ListadoComprasScreen({super.key});

  @override
  State<ListadoComprasScreen> createState() => _ListadoComprasScreenState();
}

class _ListadoComprasScreenState extends State<ListadoComprasScreen> {
  var isLoading=true;
  List<PlutoRow> rows= [];
  final dio= Dio(BaseOptions(baseUrl:Globals.apiUrl));
  var me={};
late PlutoGridStateManager manager;
  @override
  void initState() {
    // TODO: implement initState
    loadDataFromApi();
    super.initState();
  }
  loadDataFromApi() async{
    setState(() {
      isLoading=true;
    });
    me= await Globals.getMe();
    var itemsResult= await dio.get('/api/asientos/get-items',queryParameters: {
      'operacion':5,
      'clientId':me['clientId']
    });
    rows= (itemsResult.data as List).map((e) => PlutoRow(cells: {
      'id':PlutoCell(value: e['id']),
      'asiento':PlutoCell(value: e['asiento']),
      'periodo':PlutoCell(value: e['periodo']),
      'fecha':PlutoCell(value: e['fecha']),
      'operacion':PlutoCell(value: e['operacion']),
      'comprobante':PlutoCell(value: e['comprobante']),
      'comentario':PlutoCell(value: e['comentario']),
      'doc':PlutoCell(value: e['doc']),
      'entidad':PlutoCell(value: e['entidad']),
      'total':PlutoCell(value: e['total']),
      'interno': PlutoCell(value:e['identificacion']),
      'opciones':PlutoCell(value:''),
    })).toList();
    setState(() {
      isLoading=false;
    });
  }
  @override
  Widget build(BuildContext context) {
    var provider= Provider.of<SysDataProvider>(context,listen:false);
    var size= MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        children: [
          FloatingActionButton.small(
            heroTag: null,
            child: const Icon(Icons.refresh),
            onPressed: () async {
await loadDataFromApi();
            },
          ),
          FloatingActionButton.small(
            heroTag: null,
            child: const Icon(Icons.add),
            onPressed: () async {

              context.go('/cobranza');
            },
          ),
          FloatingActionButton.small(
            heroTag: null,
            child: const Icon(Icons.search),
            onPressed: () {
              showTopSnackBar(
                Overlay.of(context),
                const CustomSnackBar.info(
                  message:
                 'Utilice los filtros que provee la grilla en sus respectivas cabeceras !',
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading ? const LoadingWidget() : SingleChildScrollView(
        child: Container(
          width: size.width,
          height: size.height,
          child: PlutoGrid(
            noRowsWidget:
            SizedBox(
              width: size.width,
              height: size.height * 0.60,
              child: EmptyWidget(
                image: null,
                packageImage: PackageImage.Image_3,
                title: 'Todavia no tenemos ninguna cobranza registrada',
                subTitle: 'Puede comenzar a realizar las operaciones !',
                titleTextStyle: const TextStyle(
                  fontSize: 30,
                  color: Color(0xff9da9c7),
                  fontWeight: FontWeight.w500,
                ),
                subtitleTextStyle: const TextStyle(
                  fontSize: 14,
                  color: Color(0xffabb8d6),
                ),
                hideBackgroundAnimation: false,
              ),
            ),
            onLoaded: (a) {
              manager=a.stateManager;
              manager.setShowColumnFilter(true,notify: true);
            },
            configuration:  const PlutoGridConfiguration(
              columnFilter: PlutoGridColumnFilterConfig(filters: [
                ...FilterHelper.defaultFilters,
              ]),
              style: PlutoGridStyleConfig(
                columnTextStyle: TextStyle(
                  fontSize: 13, color: Colors.blue
                ),
                columnHeight: 23,
                  cellTextStyle: TextStyle(
                      fontSize: 13, color: Colors.blue
                  ),
                  rowHeight: 25
              )
            ),
            columns: [
              PlutoColumn(title: 'ID', field: 'id', type: PlutoColumnType.number(),width: 0, readOnly: true),
              PlutoColumn(title: 'PERIODO', field: 'periodo', type: PlutoColumnType.text(),width: 100, readOnly: true),
              PlutoColumn(title: 'N° INTERNO.', field: 'interno', type: PlutoColumnType.text(),width: 120, readOnly: true),
              PlutoColumn(title: 'N° ASI.', field: 'asiento', type: PlutoColumnType.text(),width: 100, readOnly: true),
              PlutoColumn(title: 'OPERACION.', field: 'operacion', type: PlutoColumnType.text(),width: 120, readOnly: true),
              PlutoColumn(title: 'DOC.', field: 'doc', type: PlutoColumnType.text(),width: 150, readOnly: true),
              PlutoColumn(title: 'COMPROBANTE.', field: 'comprobante', type: PlutoColumnType.text(),width: 150, readOnly: true),
              PlutoColumn(title: 'ENTIDAD.', field: 'entidad', type: PlutoColumnType.text(),width: 300, readOnly: true),
              PlutoColumn(title: 'COMENTARIO.', field: 'comentario', type: PlutoColumnType.text(),width: 300, readOnly: true),
              PlutoColumn(title: 'TOTAL.', field: 'total', type: PlutoColumnType.currency(decimalDigits: 0,symbol: ''),width: 120, readOnly: true),
              PlutoColumn(title: 'OPCIONES.', field: 'opciones', type: PlutoColumnType.text(),width: 250, readOnly: true,
              renderer: (render){
                return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                        width: 90,
                        height: 20,
                        child: ElevatedButton.icon(onPressed: () async{
                          var result= await dio.get('/api/reportes/get-doc',queryParameters: {'id':render.row.cells['id']?.value});
                          var printService= Provider.of<PrintingProvider>(context,listen:false);
                          printService.printPdfByBase64(result.data);
                        },
                            style: ButtonStyle(
                             backgroundColor: MaterialStateColor.resolveWith((states) => Colors.green)
                            ),
                            icon: const FaIcon(FontAwesomeIcons.print, size: 15, color: Colors.white,),
                            label: const Text('Impr.', style:TextStyle(fontSize: 12, color: Colors.white) ,))),
                    const SizedBox(width: 3,),
                    SizedBox(
                        width: 120,
                        height: 20,
                        child: ElevatedButton.icon(onPressed: () async{
                          await screenLock(
                            title: const Text('Ingrese el Pin para anular la operación'),
                              context: context,
                              correctString: Globals.pin,
                              maxRetries: 2,
                              onMaxRetries: (a){
                                showTopSnackBar(
                                  Overlay.of(context),
                                  CustomSnackBar.error(
                                    message:'Demasiados intentos fallidos!',
                                  ),
                                );
                              },
                              onUnlocked: () async{
                                var result= await dio.delete('/api/admin/anular-asiento',queryParameters: {
                                  'id': render.row.cells['id']?.value
                                });
                                if(result.statusCode == 200){
                                  showTopSnackBar(
                                    Overlay.of(context),
                                     CustomSnackBar.success(
                                      message: result?.data ?? '',
                                    ),
                                  );
                                  await loadDataFromApi();
                                }
                              }
                          );
                        },
                            style: ButtonStyle(
                                backgroundColor: MaterialStateColor.resolveWith((states) => Colors.red)
                            ),
                            icon: const FaIcon(FontAwesomeIcons.deleteLeft, size: 15, color: Colors.white,),
                            label: const Text('Canc. Op.', style:TextStyle(fontSize: 12, color: Colors.white) ,))),
                  ],
                );
              }
              ),
            ],
            rows: rows,
          ),
        ),
      ),
    );
  }
}