import 'package:flutter/material.dart';
import 'package:nursery_app/nursery/nurser_batch.dart';
import 'package:nursery_app/nursery/nursery.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CropDetailPage extends StatelessWidget {
  final CropData crop;

  const CropDetailPage({super.key, required this.crop});

  @override
  Widget build(BuildContext context) {
    final deficit = crop.seedsRequired - crop.achieved;

    // 🔹 Pie chart dataset
    final List<PieData> chartData = [
      PieData('Achieved', crop.achieved.toDouble(), Colors.green),
      PieData('Deficit', deficit.toDouble(), Colors.red),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("${crop.crop} DETAILS"),
        backgroundColor: Colors.green,
      ),
    body: _cropDetail(context, crop, deficit, chartData),
    );
  }
}
Widget _cropDetail(
    BuildContext context,
    CropData crop,
    int deficit,
    List<PieData> chartData,
    ) {
  final bool isSmallScreen = MediaQuery.of(context).size.width < 700;

  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),

      child: Column(
        children: [
          /// 🔹 Scrollable Table

          LayoutBuilder(
            builder: (context, constraints) {
              final double colWidth = constraints.maxWidth / 10; // 10 columns here

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 8,
                  dataRowMinHeight: 56,
                  dataRowMaxHeight: 64,

                  // 👇 Header row style
                  headingRowColor: MaterialStateProperty.all(Colors.black87),
                  headingTextStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 7, // 👈 column titles font size
                    fontWeight: FontWeight.bold,
                  ),

                  // 👇 Data row style
                  dataTextStyle: const TextStyle(
                    fontSize: 6, // 👈 values font size
                    color: Colors.black87,
                  ),

                  columns: [
                    DataColumn(label: SizedBox(width: colWidth, child: Text("BatchID"))),
                    DataColumn(label: SizedBox(width: colWidth, child: Text("Partitions"))),
                    DataColumn(label: SizedBox(width: colWidth, child: Text("SowingDate"))),
                    DataColumn(label: SizedBox(width: colWidth, child: Text("PlantingDate"))),
                    DataColumn(label: SizedBox(width: colWidth, child: Text("SeedsReq."))),
                    DataColumn(label: SizedBox(width: colWidth, child: Text("Achieved"))),
                    DataColumn(label: SizedBox(width: colWidth, child: Text("Deficit"))),
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
                        DataCell(SizedBox(width: colWidth, child: Text(deficit.toString()))),
                        DataCell(
                          SizedBox(
                            width: colWidth,
                            child: Text(
                              crop.status,
                              style: TextStyle(
                                fontSize: 6,
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
                                    width: screenSize.width * 0.2,
                                    height: screenSize.height * 0.2,
                                    child: NurseryBatchDialog(crop: crop),
                                  ),
                                ),
                              );
                            },
                            child: const Text("Open", style: TextStyle(fontSize: 9)), // 👈 button text small
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
                  animationDuration: 0, // 👈 FIX: prevent disposed animation bug
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

/// 🔹 Helper Data Model for Pie Chart
class PieData {
  final String category;
  final double value;
  final Color color;

  PieData(this.category, this.value, this.color);
}
