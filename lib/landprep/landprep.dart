import 'package:flutter/material.dart';
import 'package:nursery_app/constant/color.dart';
import 'package:nursery_app/nursery/crop_detail.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';

import 'landQeustionaire.dart';

class LandPrepPage extends StatefulWidget {
  const LandPrepPage({super.key});

  @override
  State<LandPrepPage> createState() => _LandPrepPageState();
}

class _LandPrepPageState extends State<LandPrepPage> {
  String searchQuery="";
  String? landfilter;


  String? partitionFilter;
  String? statusFilter;
  int? plantingWeekFilter; // optional filter for week

  DateTime? plantingFromDate;
  DateTime? plantingToDate;

  final DateFormat formatter = DateFormat("dd/MM/yyyy");

  List<Landprep> get filteredCrops {
    return _land.where((crop) {
      // 🔎 Search by crop name
      final matchesSearch =
      crop.crop.toLowerCase().contains(searchQuery.toLowerCase());

      // 🎯 Exact matches for dropdown filters
      final matchesCrop = landfilter == null || crop.crop == landfilter;
      final matchesPartition =
          partitionFilter == null || crop.partitions == partitionFilter;
      final matchesStatus =
          statusFilter == null || crop.status == statusFilter;

      // 📅 Planting date filter (if you want date range filter)
      DateTime cropPlanting = DateFormat("dd/MM/yyyy").parse(crop.plantingDate);

      final matchesPlanting = (plantingFromDate == null && plantingToDate == null) ||
          (plantingFromDate != null &&
              plantingToDate != null &&
              cropPlanting.isAfter(plantingFromDate!.subtract(const Duration(days: 1))) &&
              cropPlanting.isBefore(plantingToDate!.add(const Duration(days: 1))));

      // 📅 Planting week filter
      final matchesWeek = plantingWeekFilter == null ||
          crop.plantingweek == plantingWeekFilter;

      return matchesSearch &&
          matchesCrop &&
          matchesPartition &&
          matchesStatus &&
          matchesPlanting &&
          matchesWeek;
    }).toList();
  }
  Future<DateTimeRange?> showCustomDateRangeDialog(BuildContext context) {
    DateTime? start;
    DateTime? end;

    return showDialog<DateTimeRange>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Select Date Range"),
          content: SizedBox(
            width: 400,
            height: 400,
            child: SfDateRangePicker(
              selectionMode: DateRangePickerSelectionMode.range,
              showActionButtons: true,

              // Capture selection
              onSelectionChanged: (args) {
                if (args.value is PickerDateRange) {
                  final range = args.value as PickerDateRange;
                  start = range.startDate;
                  end = range.endDate ?? range.startDate;
                }
              },

              // Submit (only if both dates selected)
              onSubmit: (val) {
                if (start != null && end != null) {
                  Navigator.pop(ctx, DateTimeRange(start: start!, end: end!));
                } else {
                  Navigator.pop(ctx, null);
                }
              },

              // Cancel
              onCancel: () => Navigator.pop(ctx, null),
            ),
          ),
        );
      },
    );
  }


  void resetFilters() {
    setState(() {
      landfilter = null;
      partitionFilter = null;
      statusFilter = null;
      plantingFromDate = null;
      plantingToDate = null;
    });
  }

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
          buildSearchAndFilterBar(context),
          SizedBox(height: 20.0,),
          _dashboardTable(context)
        ],

      ),

    );
  }
  Widget buildSearchAndFilterBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search crop...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {

                setState(() => searchQuery = value);
              },
            ),
          ),
          const SizedBox(width: 12),

          // ⛳ Filter button
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black54),
            onPressed: () {
              showGeneralDialog(
                context: context,
                barrierDismissible: true,
                barrierLabel: 'Filter',
                transitionDuration: const Duration(milliseconds: 1000),
                pageBuilder: (context, anim1, anim2) {
                  final screenWidth = MediaQuery.of(context).size.width;

                  // 🔹 Adaptive width: Sidebar on desktop/tablet, full width on phone
                  double dialogWidth =
                  screenWidth > 800 ? screenWidth * 0.4 : screenWidth * 0.9;

                  return Align(
                    alignment: Alignment.centerRight,
                    child: Material(
                      color: Colors.white,
                      elevation: 8,
                      child: SafeArea(
                        child: SizedBox(
                          width: dialogWidth,
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth < 400 ? 10 : 20,
                              vertical: 10,
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header row
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "Filter",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close,
                                            color: Colors.red),
                                        onPressed: () =>
                                            Navigator.pop(context),
                                      ),
                                    ],
                                  ),
                                  const Divider(),
                                  const SizedBox(height: 10),

                                  // 🔹 Crop filter
                                  DropdownButtonFormField<String>(
                                    value: landfilter,
                                    decoration: const InputDecoration(
                                      labelText: "Crop",
                                      border: OutlineInputBorder(),
                                    ),
                                    items: _land
                                        .map((c) => c.crop)
                                        .toSet()
                                        .map((crop) => DropdownMenuItem(
                                      value: crop,
                                      child: Text(crop),
                                    ))
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() => landfilter = value);
                                    },
                                  ),
                                  const SizedBox(height: 20),

                                  // 🔹 Partition filter
                                  DropdownButtonFormField<String>(
                                    value: partitionFilter,
                                    decoration: const InputDecoration(
                                      labelText: "Partition",
                                      border: OutlineInputBorder(),
                                    ),
                                    items: _land
                                        .map((c) => c.partitions)
                                        .toSet()
                                        .map((p) => DropdownMenuItem(
                                      value: p,
                                      child: Text(p),
                                    ))
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() => partitionFilter = value);
                                    },
                                  ),
                                  const SizedBox(height: 20),

                                  // 🔹 Status filter
                                  DropdownButtonFormField<String>(
                                    value: statusFilter,
                                    decoration: const InputDecoration(
                                      labelText: "Status",
                                      border: OutlineInputBorder(),
                                    ),
                                    items: _land
                                        .map((c) => c.status)
                                        .toSet()
                                        .map((s) => DropdownMenuItem(
                                      value: s,
                                      child: Text(s),
                                    ))
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() => statusFilter = value);
                                    },
                                  ),
                                  const SizedBox(height: 20),

                                  // 🔹 Sowing date range picker

                                  // 🔹 Planting date range picker
                                  InkWell(
                                    onTap: () async {
                                      final picked =
                                      await showCustomDateRangeDialog(
                                          context);
                                      if (picked != null) {
                                        setState(() {
                                          plantingFromDate = picked.start;
                                          plantingToDate = picked.end;
                                        });
                                      }
                                    },
                                    child: InputDecorator(
                                      decoration: const InputDecoration(
                                        labelText: "Planting Date Range",
                                        border: OutlineInputBorder(),
                                      ),
                                      child: Text(
                                        (plantingFromDate != null &&
                                            plantingToDate != null)
                                            ? "${DateFormat('dd/MM/yyyy').format(plantingFromDate!)} - ${DateFormat('dd/MM/yyyy').format(plantingToDate!)}"
                                            : "Select Date Range",
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 30),

                                  // 🔹 Responsive Buttons
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      if (constraints.maxWidth < 300) {
                                        // Small screen → vertical buttons
                                        return Column(
                                          children: [
                                            OutlinedButton(
                                              onPressed: resetFilters,
                                              child: const Text("Reset"),
                                            ),
                                            const SizedBox(height: 10),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                setState(() {});
                                              },
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                  Colors.green),
                                              child: const Text("Apply"),
                                            ),
                                          ],
                                        );
                                      } else {
                                        // Normal → side by side
                                        return Row(
                                          children: [
                                            Expanded(
                                              child: OutlinedButton(
                                                onPressed: resetFilters,
                                                child: const Text("Reset"),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  setState(() {});
                                                },
                                                style: ElevatedButton
                                                    .styleFrom(
                                                    backgroundColor:
                                                    Colors.green),
                                                child: const Text("Apply"),
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                    },
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                transitionBuilder: (context, anim1, anim2, child) {
                  return SlideTransition(
                    position: Tween(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: anim1,
                      curve: Curves.easeOut,
                    )),
                    child: child,
                  );
                },
              );
            },
          )
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
