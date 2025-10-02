import 'package:flutter/material.dart';
import 'package:nursery_app/constant/color.dart';
import 'package:nursery_app/nursery/crop_detail.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'landQeustionaire.dart';

class LandPrepPage extends StatelessWidget {
  const LandPrepPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.warning,
        elevation: 0,
        title: const Text(
          "Land Preparations",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [

          SizedBox(height: 20.0,),
          _dashboardTable(context)
        ],

      ),

    );
  }
}


Widget _dashboardTable(BuildContext context) {
  // 👇 Responsive font sizes
  final screenWidth = MediaQuery.of(context).size.width;
  final double headingFontSize = screenWidth < 1000 ? 10 : 12;
  final double dataFontSize = screenWidth < 600 ? 8 : 10;

  return LayoutBuilder(
    builder: (context, constraints) {
      final double colWidth = constraints.maxWidth / 7; // 7 columns in your case
      final double actionColWidth = colWidth * 2;
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
            DataColumn(label: SizedBox(width: colWidth, child: Text("Partitions	"))),
            DataColumn(label: SizedBox(width: colWidth, child: Text("Crop"))),
            DataColumn(label: SizedBox(width: colWidth, child: Text("	PlantingDate"))),
            DataColumn(label: SizedBox(width: colWidth, child: Text("PlantingWk-Year"))),

            DataColumn(label: SizedBox(width: colWidth, child: Text("Status"))),
            DataColumn(label: SizedBox(width: actionColWidth, child: Text("#"))),
          ],

          rows: _land.map((land) {
            return DataRow(
              cells: [
                DataCell(SizedBox(width: colWidth, child: Text(land.partitions))),
                DataCell(SizedBox(width: colWidth, child: Text(land.crop))),
                DataCell(SizedBox(width: colWidth, child: Text(land.plantingDate))),
                DataCell(SizedBox(width: colWidth, child: Text(land.plantingweek.toString()))),

                DataCell(SizedBox(width: colWidth, child: Text(land.status))),

                DataCell(
                  SizedBox(
                    width: actionColWidth,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                            builder: (context) =>
                                LandPreparationPage(),
                        ),
                        );
                      },
                      child: const Text("Open"),
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
final List<Landprep> _land = [
  Landprep("Blcok A Valve 6", 'Maize', "27 Oct 2025", 14, "Pending"),
];

// 🔹 Data class
class Landprep {
  final String partitions;
  final String crop;
  final String plantingDate;
  final int plantingweek;
  final String status;

  Landprep(
      this.partitions,
      this.crop,
      this.plantingDate,
      this.plantingweek,
      this.status,
      );
}
