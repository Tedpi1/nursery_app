import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:syncfusion_flutter_charts/charts.dart';


import '../model/crop_model.dart';
import 'nurser_batch.dart';

class CropDetailPage extends StatefulWidget {
  final String cropName;

  const CropDetailPage({super.key, required this.cropName});

  @override
  State<CropDetailPage> createState() => _CropDetailPageState();
}

class _CropDetailPageState extends State<CropDetailPage> {
  cropDetails? crop;

  @override
  void initState() {
    super.initState();
    loadcropDetails();
  }

  Future<void> loadcropDetails() async {
    final String response =
    await rootBundle.loadString('assets/crop.json');
    final data = json.decode(response) as List;
    final crops = data.map((json) => cropDetails.fromJson(json)).toList();

    setState(() {
      crop = crops.firstWhere(
            (c) => c.crop.toLowerCase() == widget.cropName.toLowerCase(),
        orElse: () => crops.first,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (crop == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text("${widget.cropName} DETAILS"),
          backgroundColor: Colors.green,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // 🔹 Summarize for chart
    final totalSeeds = crop!.batches.fold<int>(
        0, (sum, b) => sum + b.seedsRequired);
    final totalAchieved =
    crop!.batches.fold<int>(0, (sum, b) => sum + b.achieved);
    final totalDeficit = totalSeeds - totalAchieved;

    final List<PieData> chartData = [
      PieData('Achieved', totalAchieved.toDouble(), Colors.green),
      PieData('Deficit', totalDeficit.toDouble(), Colors.red),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("${crop!.crop} DETAILS"),
        backgroundColor: Colors.green,
      ),
      body: _cropDetail(context, crop!, chartData),

    );
  }
}

Widget _cropDetail(
    BuildContext context,
    cropDetails crop,
    List<PieData> chartData,
    ) {
  final double screenWidth = MediaQuery.of(context).size.width;

  // 🔹 scale font size dynamically
  double headingFontSize;
  double dataFontSize;
  if (screenWidth < 400) {
    headingFontSize = 10;
    dataFontSize = 11;
  } else if (screenWidth < 700) {
    headingFontSize = 12;
    dataFontSize = 13;
  } else {
    headingFontSize = 14;
    dataFontSize = 15;
  }

  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          /// 🔹 Scrollable Table
          LayoutBuilder(
            builder: (context, constraints) {
              final double colWidth = constraints.maxWidth / 10;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 8,
                  dataRowMinHeight: 48,
                  dataRowMaxHeight: 64,

                  // 👇 Header row style
                  headingRowColor: MaterialStateProperty.all(Colors.black87),
                  headingTextStyle: TextStyle(
                    color: Colors.white,
                    fontSize: headingFontSize, // responsive header
                    fontWeight: FontWeight.bold,
                  ),

                  // 👇 Data row style
                  dataTextStyle: TextStyle(
                    fontSize: dataFontSize, // responsive values
                    color: Colors.black87,
                  ),

                  columns: [
                    DataColumn(label: SizedBox(width: colWidth, child: Text("BatchID"))),
                    DataColumn(label: SizedBox(width: colWidth, child: Text("Partitions"))),
                    DataColumn(label: SizedBox(width: colWidth, child: Text("SowingDate"))),
                    DataColumn(label: SizedBox(width: colWidth, child: Text("PlantingDate"))),
                    DataColumn(label: SizedBox(width: colWidth, child: Text("SeedsReq."))),
                    DataColumn(label: SizedBox(width: colWidth, child: Text("Achieved"))),
                    DataColumn(label: SizedBox(width: colWidth, child: Text("Status"))),
                    DataColumn(label: SizedBox(width: colWidth, child: Text("#"))),
                  ],

                  rows: [
                    DataRow(
                      cells: [
                        DataCell(SizedBox(width: colWidth, child: Text("0"))),
                        DataCell(SizedBox(width: colWidth, child: Text(crop.partitions))),
                        DataCell(SizedBox(width: colWidth, child: Text(crop.sowingDate))),
                        DataCell(SizedBox(width: colWidth, child: Text(crop.plantingDate))),
                        DataCell(SizedBox(width: colWidth, child: Text(crop.seedsRequired.toString()))),
                        DataCell(SizedBox(width: colWidth, child: Text(crop.achieved.toString()))),

                        DataCell(
                          SizedBox(
                            width: colWidth,
                            child: Text(
                              crop.status,
                              style: TextStyle(
                                fontSize: dataFontSize,
                                fontWeight: FontWeight.w600,
                                color: crop.status == "Completed"
                                    ? Colors.green
                                    : (crop.status == "Pending"
                                    ? Colors.orange
                                    : Colors.blue),
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          ElevatedButton(
                            onPressed: () {
                              final screenSize = MediaQuery.of(context).size;
                              showDialog(
                                context: context,
                                builder: (BuildContext dialogContext) => Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: SizedBox(
                                    width: screenSize.width * 0.8,
                                    height: screenSize.height * 0.8,
                                    child: NurseryBatchDialog(crop: crop),
                                  ),
                                ),
                              );
                            },
                            child: Text("Open", style: TextStyle(fontSize: dataFontSize)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          /// 🔹 Progress Pie Chart
          SizedBox(
            height: 300,
            child: SfCircularChart(
              title: ChartTitle(text: "Progress Overview"),
              legend: const Legend(isVisible: true),
              series: <CircularSeries>[
                PieSeries<PieData, String>(
                  dataSource: chartData,
                  animationDuration: 0,
                  xValueMapper: (PieData data, _) => data.category,
                  yValueMapper: (PieData data, _) => data.value,
                  pointColorMapper: (PieData data, _) => data.color,
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
class PieData {
  final String category;
  final double value;
  final Color color;

  PieData(this.category, this.value, this.color);
}
