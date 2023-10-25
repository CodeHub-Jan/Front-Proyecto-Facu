import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:centyneg_sys/commons/Globals.dart';
import 'package:centyneg_sys/models/items_models.dart';
import 'package:centyneg_sys/providers/printing_provider.dart';
import 'package:centyneg_sys/providers/sys_data_provider.dart';
import 'package:centyneg_sys/widgets/custom_container.dart';
import 'package:centyneg_sys/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../commons/app_color.dart';

class BalanceGeneralScreen extends StatefulWidget {
  const BalanceGeneralScreen({super.key});

  @override
  State<BalanceGeneralScreen> createState() => _State();
}

class _State extends State<BalanceGeneralScreen> {
  var fechaDesdeController= TextEditingController();
  var fechaHastaController= TextEditingController();
  DateTime? desde;
  DateTime? hasta;
  ItemsClientModel? account;
  bool isLoading=false;
  bool allMovements=false;
  @override
  Widget build(BuildContext context) {
    var provider= Provider.of<SysDataProvider>(context);
    return  Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColor.white),
        title: Text(
          'Generar Balance General', style: TextStyle(color: AppColor.white),),
        backgroundColor: AppColor.darkBlue,),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40,),
            Center(child: CustomContainer(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              containerWith: 400,
              containerHeight: 350,
              child: Column(
                children: [
                  const Text('Generar BALANCE GENERAL por Rango de Fecha'),
                  const SizedBox(height: 20,),
              Row(
              children: [

                Flexible(child: SizedBox(
                  width: 300,
                  height: 30,
                  child: TextField(
                    readOnly: true,
                    controller: fechaDesdeController,
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Fecha Desde',
                      labelStyle: TextStyle(fontSize: 12),

                    ),
                  ),
                ),),
                const SizedBox(width: 20,),
                Flexible(child: SizedBox(
                  width: 150,
                  child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white38
                      ),
                      onPressed: () async {
                        var results = await showCalendarDatePicker2Dialog(
                          context: context,
                          config: CalendarDatePicker2WithActionButtonsConfig(),
                          dialogSize: const Size(325, 400),
                          value: [DateTime.now()],
                          borderRadius: BorderRadius.circular(
                              15),
                        );
                        desde = results?.first;
                        if (desde != null) {
                          fechaDesdeController.text =
                              DateFormat('dd/MM/yyyy').format(
                                  desde!);
                          setState(() {

                          });
                        }
                      },
                      icon: const Icon(Icons.calendar_month),
                      label: const Text('Seleccionar')),
                )
                )
  ]),
                  const SizedBox(height: 20,),
                  Row(
                      children: [
                        Flexible(child: SizedBox(
                          width: 300,
                          height: 30,
                          child: TextField(
                            readOnly: true,
                            controller: fechaHastaController,
                            style: const TextStyle(fontSize: 14),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Fecha Hasta',
                              labelStyle: TextStyle(fontSize: 12),

                            ),
                          ),
                        ),),
                        const SizedBox(width: 20,),
                        Flexible(child: SizedBox(
                          width: 150,
                          child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white38
                              ),
                              onPressed: () async {
                                var results = await showCalendarDatePicker2Dialog(
                                  context: context,
                                  config: CalendarDatePicker2WithActionButtonsConfig(),
                                  dialogSize: const Size(325, 400),
                                  value: [DateTime.now()],
                                  borderRadius: BorderRadius.circular(
                                      15),
                                );
                                hasta = results?.first;
                                if (hasta != null) {
                                  fechaHastaController.text =
                                      DateFormat('dd/MM/yyyy').format(
                                          hasta!);
                                  setState(() {

                                  });
                                }
                              },
                              icon: const Icon(Icons.calendar_month),
                              label: const Text('Seleccionar')),
                        )
                        )
                      ]),
                  CheckboxListTile(
                    title: Text('Todas las cuentas'),
                    value: allMovements,
                    onChanged: (newValue) {
                      setState(() {
                        allMovements=newValue ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
                  ),
                  const SizedBox(height: 20,),
                  SizedBox(
                    width: 250,
                    child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white
                        ),
                        onPressed: () async {

                          fechaDesdeController.text='01/01/${Globals.periodo}';
                          fechaHastaController.text='31/12/${Globals.periodo}';
                          desde=DateFormat('dd/MM/yyyy').parse(fechaDesdeController.text);
                          hasta=DateFormat('dd/MM/yyyy').parse(fechaHastaController.text);
                        },
                        icon: const Icon(Icons.calendar_month),
                        label: const Text('Mostrar Periodo')),
                  ),

                  const SizedBox(height: 10,),
                  ElevatedButton.icon(onPressed: () async{
                    var printService= Provider.of<PrintingProvider>(context,listen:false);
                    EasyLoading.show(status: 'Generando Reporte');


                    var me= await provider.getMe();
                    var base64= await provider.generarBalance({
                      'desde': desde?.toIso8601String(),
                      'hasta':hasta?.toIso8601String(),
                      'clientId':  me['clientId'],
                      'allMovement':allMovements,
                      'periodo': Globals.periodo,
                      'tipo':1
                    });
                    setState(() {
                      isLoading=false;
                    });
                    printService.printPdfByBase64(base64);
                    EasyLoading.dismiss(animation: true);
                  }, icon: const Icon(Icons.print), label: const Text('Generar Balance General')),
                  const SizedBox(height: 10,),
                  ElevatedButton.icon(onPressed: () async{
                    var printService= Provider.of<PrintingProvider>(context,listen:false);
                    EasyLoading.show(status: 'Descargando Reporte');
                    var me= await provider.getMe();
                    var base64= await provider.generarBalance({
                      'desde': desde?.toIso8601String(),
                      'hasta':hasta?.toIso8601String(),
                      'clientId':  me['clientId'],
                      'allMovement':allMovements,
                      'periodo': Globals.periodo,
                      'tipo':2
                    });
                    setState(() {
                      isLoading=false;
                    });
                    printService.downloadExcelFromBase64(base64);
                    EasyLoading.dismiss(animation: true);
                  }, icon: const FaIcon(FontAwesomeIcons.fileExcel), label: const Text('Descargar Balance General')),
                ],
              ),
            ),)
          ],
        ),
      ),
    );
  }
}
