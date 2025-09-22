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
      body: const DashboardSummary(),
    );
  }
}

class DashboardSummary extends StatelessWidget {
  const DashboardSummary({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔹 Crops dataset
    final List<CropData> crops = [
      CropData(
        "BASIL",
        2640,
        0,
        "AREA A BLOCK H1",
        "27 Sep 2025",
        "27 Oct 2025",
        "Pending",
      ),
      CropData(
        "TOMATO",
        1200,
        600,
        "AREA B BLOCK T2",
        "20 Sep 2025",
        "20 Oct 2025",
        "Ongoing",
      ),
      CropData(
        "LETTUCE",
        800,
        500,
        "AREA C BLOCK L3",
        "15 Sep 2025",
        "15 Oct 2025",
        "Completed",
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 🔹 Bar Chart
          SizedBox(
            height: 300,
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              legend: const Legend(isVisible: true),
              series: <CartesianSeries>[
                ColumnSeries<CropData, String>(
                  name: 'Seeds Required',
                  dataSource: crops,
                  xValueMapper: (CropData data, _) => data.crop,
                  yValueMapper: (CropData data, _) => data.seedsRequired,
                  color: Colors.blue,
                  onPointTap: (ChartPointDetails details) {
                    final CropData selectedCrop = crops[details.pointIndex!];
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => CropDetailPage(crop: selectedCrop),
                      ),
                    );
                  },
                ),
                ColumnSeries<CropData, String>(
                  name: 'Seeds Achieved',
                  dataSource: crops,
                  xValueMapper: (CropData data, _) => data.crop,
                  yValueMapper: (CropData data, _) => data.achieved,
                  color: Colors.lightBlue,
                  onPointTap: (ChartPointDetails details) {
                    final CropData selectedCrop = crops[details.pointIndex!];
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => CropDetailPage(crop: selectedCrop),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
