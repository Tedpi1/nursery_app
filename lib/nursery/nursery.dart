import 'package:flutter/material.dart';
import 'package:nursery_app/nursery/crop_detail.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class NurseryDashboard extends StatelessWidget {
  const NurseryDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "🌱 Nursery Crop Batches & Summary (Wk 39)",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          _dashboardSection(context),
          SizedBox(height: 20.0,),
          _dashboardTable(context)
        ],
        
      ),

    );
  }
}
Widget _dashboardSection(BuildContext context) {
  final double screenWidth = MediaQuery.of(context).size.width;

  // Allow wider width on desktop but keep constrained on mobile
  final double maxWidth = screenWidth > 1000 ? 1000 : screenWidth;
  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: ConstrainedBox(
        constraints:  BoxConstraints(maxWidth: maxWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // 🔹 Safe animated wrapper
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 0),
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              child: SizedBox(
                key: ValueKey(_crops), // forces re-animation when data changes
                height: 300,
                child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  legend: const Legend(isVisible: true),
                  enableAxisAnimation: false, // disable Syncfusion’s internal axis animation

                  series: <CartesianSeries>[
                    ColumnSeries<CropData, String>(
                      name: 'Seeds Required',
                      dataSource: _crops,
                      xValueMapper: (CropData data, _) => data.crop,
                      yValueMapper: (CropData data, _) => data.seedsRequired,
                      animationDuration: 0, // disable chart internal animation
                      color: Colors.blue,
                      onPointTap: (ChartPointDetails details) async {
                        final CropData selectedCrop =
                        _crops[details.pointIndex!];

                        // 🔹 tiny delay so chart finishes painting
                        await Future.delayed(const Duration(milliseconds: 200));

                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CropDetailPage(crop: selectedCrop),
                            ),
                          );
                        }
                      },
                    ),
                    ColumnSeries<CropData, String>(
                      name: 'Seeds Achieved',
                      dataSource: _crops,
                      xValueMapper: (CropData data, _) => data.crop,
                      yValueMapper: (CropData data, _) => data.achieved,
                      animationDuration: 0,
                      color: Colors.lightBlue,
                      onPointTap: (ChartPointDetails details) async {
                        final CropData selectedCrop =
                        _crops[details.pointIndex!];

                        await Future.delayed(const Duration(milliseconds: 200));

                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CropDetailPage(crop: selectedCrop),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _dashboardTable(BuildContext context) {
  // 👇 Responsive font sizes
  final screenWidth = MediaQuery.of(context).size.width;
  final double headingFontSize = screenWidth < 1000 ? 10 : 12;
  final double dataFontSize = screenWidth < 600 ? 8 : 10;

  return LayoutBuilder(
    builder: (context, constraints) {
      final double colWidth = constraints.maxWidth / 7; // 7 columns in your case

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
            fontSize: headingFontSize,
            fontWeight: FontWeight.bold,
          ),

          // 👇 Data row style
          dataTextStyle: TextStyle(
            fontSize: dataFontSize,
            color: Colors.black87,
          ),

          columns: [
            DataColumn(label: SizedBox(width: colWidth, child: Text("Crop"))),
            DataColumn(label: SizedBox(width: colWidth, child: Text("Seeds Req."))),
            DataColumn(label: SizedBox(width: colWidth, child: Text("Achieved"))),
            DataColumn(label: SizedBox(width: colWidth, child: Text("Partition"))),
            DataColumn(label: SizedBox(width: colWidth, child: Text("Sowing Date"))),
            DataColumn(label: SizedBox(width: colWidth, child: Text("Planting Date"))),
            DataColumn(label: SizedBox(width: colWidth, child: Text("Status"))),
          ],

          rows: _crops.map((crop) {
            return DataRow(
              cells: [
                DataCell(SizedBox(width: colWidth, child: Text(crop.crop))),
                DataCell(SizedBox(width: colWidth, child: Text(crop.seedsRequired.toString()))),
                DataCell(SizedBox(width: colWidth, child: Text(crop.achieved.toString()))),
                DataCell(SizedBox(width: colWidth, child: Text(crop.partitions))),
                DataCell(SizedBox(width: colWidth, child: Text(crop.sowingDate))),
                DataCell(SizedBox(width: colWidth, child: Text(crop.plantingDate))),
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
              ],
            );
          }).toList(),
        ),
      );
    },
  );
}




// 🔹 Example crops dataset (keep it outside the widget function)
final List<CropData> _crops = [
  CropData("BASIL", 2640, 0, "AREA A BLOCK H1", "27 Sep 2025", "27 Oct 2025", "Pending"),
  CropData("TOMATO", 1200, 600, "AREA B BLOCK T2", "20 Sep 2025", "20 Oct 2025", "Ongoing"),
  CropData("LETTUCE", 800, 500, "AREA C BLOCK L3", "15 Sep 2025", "15 Oct 2025", "Completed"),
];

// 🔹 Data class
class CropData {
  final String crop;
  final int seedsRequired;
  final int achieved;
  final String partitions;
  final String sowingDate;
  final String plantingDate;
  final String status;

  CropData(
    this.crop,
    this.seedsRequired,
    this.achieved,
    this.partitions,
    this.sowingDate,
    this.plantingDate,
    this.status,
  );
}
