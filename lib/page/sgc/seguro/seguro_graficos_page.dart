import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../model/model.dart';
import '../../../provider/provider.dart';
import '../../../res/res.dart';

class SeguroGraficosPage extends StatefulWidget {
  const SeguroGraficosPage({super.key});

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<SeguroGraficosPage> {

  final List<SaudeGrafico> _dados = [];

  Future? _future;

  double getRatio(int i) {
    switch(i) {
      case 1: return 2.2;
      case 2: return 0.5;
      case 3: return 1.0;
      default: return 1;
    }
  }

  @override
  void initState() {
    super.initState();
    _future = _init();
  }

  @override
  Widget build(BuildContext context) {
    final membrosCount = MembrosProvider.i.list.length;

    return Scaffold(
      appBar: SgcAppBar(
        title: const Text('Graficos'),
      ),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          int chart = 0;

          return SingleChildScrollView(
            child: Column(
              children: [
                /*SfCircularChart(
                  annotations: [
                    CircularChartAnnotation(
                      height: '100%',
                      width: '100%',
                      widget: PhysicalModel(
                        shape: BoxShape.circle,
                        elevation: 10,
                        color: const Color.fromRGBO(230, 230, 230, 1),
                        child: Container(),
                      ),
                    ),
                    const CircularChartAnnotation(
                      widget: Text('62%',
                        style: TextStyle(
                          color: Color.fromRGBO(0, 0, 0, 0.5),
                          fontSize: 25,
                        ),
                      ),
                    ),
                  ],
                  series: [
                    DoughnutSeries<ChartSampleData, String>(
                      xValueMapper: (data, int index) => data.label,
                      yValueMapper: (data, int index) => data.value,
                      pointColorMapper: (data, int index) => data.color,
                      dataSource: [
                        ChartSampleData(
                          label: 'A',
                          value: 62,
                          color: const Color.fromRGBO(0, 220, 252, 1),
                        ),
                        ChartSampleData(
                          label: 'B',
                          value: 38,
                          color: Colors.transparent,
                        ),
                      ],
                    ),
                  ],
                  title: const ChartTitle(
                    text: 'Cartão SUS informados',
                  ),
                ),*/

                for(var graf in _dados)
                  Builder(builder: (context) {
                    chart++;
                    final keys = graf.values.keys.toList();
                    keys.sort((a, b) {
                      final aValue = graf.values[a]!;
                      final bValue = graf.values[b]!;

                      return aValue.compareTo(bValue);
                    });

                    return AspectRatio(
                      aspectRatio: getRatio(chart),
                      child: SfCartesianChart(
                        title: ChartTitle(text: graf.title),
                        plotAreaBorderWidth: 0,
                        onDataLabelRender: (DataLabelRenderArgs args) {
                          double percent = (args.dataPoints[args.pointIndex].y / membrosCount) * 100;
                          args.text = '${percent.toStringAsFixed(2)} %';
                        },
                        onTooltipRender: (TooltipArgs args) {
                          final index = args.pointIndex!.toInt();
                          double percent = (args.dataPoints![index].y / membrosCount) * 100;
                          args.text = '${args.dataPoints![index].x} : ${percent.toStringAsFixed(2)} %';
                        },
                        tooltipBehavior: TooltipBehavior(
                          enable: true,
                          canShowMarker: false,
                          header: '',
                        ),
                        primaryXAxis: const CategoryAxis(
                          maximumLabelWidth: 100,
                          rangePadding: ChartRangePadding.round,
                          majorGridLines: MajorGridLines(width: 0),
                        ),
                        primaryYAxis: NumericAxis(
                          minimum: 0,
                          maximum: membrosCount.toDouble(),
                          majorTickLines: const MajorTickLines(size: 0),
                        ),
                        series: [
                          BarSeries<ChartSampleData, String>(
                            dataSource: [
                              for(var key in keys)
                                ChartSampleData(
                                  label: key,
                                  value: graf.values[key]!.toDouble(),
                                ),
                            ],
                            xValueMapper: (data, int index) => data.label,
                            yValueMapper: (data, int index) => data.value,
                            pointColorMapper: (data, int index) => data.color,
                            dataLabelSettings: const DataLabelSettings(
                              // isVisible: true,
                              margin: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _init() async {
    _dados.clear();
    _dados.addAll(await SgcProvider.i.getSaudeChart());
    setState(() {});
  }
}

class ChartSampleData {
  String label;
  double value;
  Color color;

  ChartSampleData({
    required this.label,
    required this.value,
    this.color = const Color.fromRGBO(0, 220, 252, 1),
  });
}