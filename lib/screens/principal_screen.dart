import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:centyneg_sys/commons/Globals.dart';
import 'package:centyneg_sys/commons/app_color.dart';
import 'package:centyneg_sys/providers/graphics_provider.dart';
import 'package:centyneg_sys/widgets/drawer_widget.dart';
import 'package:centyneg_sys/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graphic/graphic.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';


class PrincipalScreen extends StatefulWidget {
  const PrincipalScreen({super.key});

  @override
  State<PrincipalScreen> createState() => _PrincipalScreenState();
}

class _PrincipalScreenState extends State<PrincipalScreen> {

var isLoading=true;
late GraphicsProvider provider;
@override
  void initState() {
    // TODO: implement initState
  provider= Provider.of<GraphicsProvider>(context,listen: false);
  loadDataFromApi();
    super.initState();
  }
List<GraphicData> ingresos=[];
List<GraphicData> egresos=[];
List<GraphicData> diferencia=[];
var me={};
loadDataFromApi() async{
me= await Globals.getMe();
  var resultIngreso= await provider.getGraphicsData('INGRESOS');
var resultEgreso= await provider.getGraphicsData('EGRESOS');
var resultDiferencia= await provider.getGraphicsDifference();
  ingresos=resultIngreso.map((e) => GraphicData(e['month'], e['data'])).toList();
egresos=resultEgreso.map((e) => GraphicData(e['month'], e['data'])).toList();
diferencia=resultDiferencia.map((e) => GraphicData(e['name'], e['value'])).toList();
setState(() {
isLoading=false;
});
}
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery
        .of(context)
        .size;
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColor.white),
        title: Text(
          'SISTEMA DE GESTION', style: TextStyle(color: AppColor.white),),
        backgroundColor: AppColor.darkBlue,),
      backgroundColor: Colors.grey.withOpacity(0.2),
      body: isLoading ? const LoadingWidget() :  SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10,),
            const Text('ACCESOS DIRECTOS', style: TextStyle(fontSize: 40),),
            Container(
              width: size.width,
              height: size.height * 0.20,
              padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
              child: Column(
                children: [ Row(children: [
                  SizedBox(
                  width: 150,
                  height: 150,
                  child: AnimatedButton(pressEvent: (){
                    context.go('/ingresos');
                  },text: 'INGRESOS',
                    buttonTextStyle: const TextStyle(fontSize: 30,color: Colors.white),
                    color: Colors.blue,)),
                  const SizedBox(width: 10,),
                  SizedBox(
                  width: 150,
                  height: 150,
                  child: AnimatedButton(pressEvent: (){
                    context.go('/egresos');
                  },text: 'EGRESOS',
                    buttonTextStyle: const TextStyle(fontSize: 30,color: Colors.white),
                    color: Colors.red,)),
                  const SizedBox(width: 10,),
                  SizedBox(
                  width: 150,
                  height: 150,
                  child: AnimatedButton(pressEvent: (){
                    context.go('/centros_costos');
                  },text: 'CENTRO\nDE COSTO',
                    buttonTextStyle: const TextStyle(fontSize: 30,color: Colors.white),
                    color: Colors.redAccent,)),
                  const SizedBox(width: 10,),
                  SizedBox(
                  width: 150,
                  height: 150,
                  child: AnimatedButton(pressEvent: (){
                    context.go('/facturas');
                  },text: 'FACTURACION',
                    buttonTextStyle: const TextStyle(fontSize: 30,color: Colors.white),
                    color: Colors.blue,)),
                  const SizedBox(width: 10,)
                ],),]
              ),
            ),
            const SizedBox(height: 10,),
            Text('RESUMENES POR MES PARA EL PERIODO ${Globals.periodo}', style: const TextStyle(fontSize: 40),),
            Container(
              width: size.width,
              height: size.height * 0.50,
              child:Row(
                children: [
                  SizedBox(
                      width: size.width * 0.30,
                      height: size.height * 0.50,
                      child:SfCircularChart(
                        legend: Legend(overflowMode: LegendItemOverflowMode.wrap),
                        tooltipBehavior: TooltipBehavior(enable: true),
                        title: ChartTitle(text: 'Comparativo de Ingreso y Egreso'),
                        palette: [
                          Colors.green,
                          Colors.orange,
                          Colors.blue,

                        ],
                        series: <PieSeries<GraphicData, String>>[
                          PieSeries<GraphicData, String>(
                              explode: true,
                              explodeIndex: 0,
                              explodeOffset: '10%',
                              dataSource: <GraphicData>[
                                GraphicData(diferencia[1].month, diferencia[1].value),
                                GraphicData(diferencia[0].month, diferencia[0].value),
                                GraphicData('Diferencia',diferencia[1].value- diferencia[0].value),
                              ],
                              xValueMapper: (GraphicData data, _) => data.month as String,
                              yValueMapper: (GraphicData data, _) => data.value,
                              dataLabelMapper: (GraphicData data, _) => '${data.month} ${Globals.formatNumberToLocate(data.value)}',
                              startAngle: 100,
                              endAngle: 100,

                              dataLabelSettings: const DataLabelSettings(isVisible: true,textStyle: TextStyle(fontSize: 15, color: Colors.white))),
                        ],
                      )
                  ),
                  SizedBox(
                    width: size.width * 0.70,
                    height: size.height * 0.50,
                    child: SfCartesianChart(

                        primaryXAxis: CategoryAxis(title: AxisTitle(text: 'LINEAS AZULES INGRESOS - LINEAS ROJAS EGRESO',textStyle: const TextStyle(fontSize: 25))),

                        series: <LineSeries<GraphicData, String>>[
                          LineSeries<GraphicData, String>(
                              dataLabelSettings: DataLabelSettings(isVisible: true,
                                  builder: (a,b,c,d,e)=> Text('${Globals.symbol} ${Globals.formatNumberToLocate(a.value)}',style: const TextStyle(fontSize: 20,color:Colors.blue, fontWeight: FontWeight.bold),)
                              ),
                              dataSource:  ingresos,
                              xValueMapper: (GraphicData sales, _) => sales.month,
                              yValueMapper: (GraphicData sales, _) => sales.value
                          ),
                          LineSeries<GraphicData, String>(
                              dataLabelSettings: DataLabelSettings(isVisible: true,
                                  builder: (a,b,c,d,e)=> Text('${Globals.symbol} ${Globals.formatNumberToLocate(a.value)}',style: const TextStyle(fontSize: 20,color:Colors.red, fontWeight: FontWeight.bold),)
                              ),
                              dataSource: egresos,
                              xValueMapper: (GraphicData sales, _) => sales.month,
                              yValueMapper: (GraphicData sales, _) => sales.value
                          )
                        ]
                    ),
                  ),
                ],

              )
            )
          ],
        ),
      ),
    );
  }

}
class GraphicData {
  GraphicData(this.month, this.value);
  final String month;
  final double value;
}