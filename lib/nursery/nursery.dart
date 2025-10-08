import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nursery_app/constant/color.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'crop_detail.dart';
import 'package:intl/intl.dart';

//db columns
class CropData {
  final String crop;
  final int seedsRequired;
  final int achieved;
  final String partitions;
  final String sowingDate;
  final String plantingDate;
  final String status;

  CropData({
    required this.crop,
    required this.seedsRequired,
    required this.achieved,
    required this.partitions,
    required this.sowingDate,
    required this.plantingDate,
    required this.status,
  });

  factory CropData.fromJson(Map<String, dynamic> json) {
    return CropData(
      crop: json['crop'],
      seedsRequired: json['seedsRequired'],
      achieved: json['achieved'],
      partitions: json['partitions'],
      sowingDate: json['sowingDate'],
      plantingDate: json['plantingDate'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() => {
    'crop': crop,
    'seedsRequired': seedsRequired,
    'achieved': achieved,
    'partitions': partitions,
    'sowingDate': sowingDate,
    'plantingDate': plantingDate,
    'status': status,
  };
}


class NurseryDashboard extends StatefulWidget {
  const NurseryDashboard({super.key});


  @override
  State<NurseryDashboard> createState() => _NurseryDashboardState();
}

class _NurseryDashboardState extends State<NurseryDashboard> {
  String searchQuery = "";
  List<CropData> _crops = [];
  // 🔹 Filters
  String? cropFilter;
  String? partitionFilter;
  String? statusFilter;

  DateTime? sowingFromDate;
  DateTime? sowingToDate;
  DateTime? plantingFromDate;
  DateTime? plantingToDate;

  final DateFormat formatter = DateFormat("dd MMM yyyy");

  DateTime? tryParseDate(String dateStr) {
    try {
      // First, try ISO 8601 format (like 2025-09-01)
      return DateFormat("yyyy-MM-dd").parse(dateStr);
    } catch (_) {
      try {
        // Then try the "dd MMM yyyy" fallback
        return DateFormat("dd MMM yyyy").parse(dateStr);
      } catch (e) {
        debugPrint("⚠️ Date parse error: $dateStr");
        return null;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    loadCropData();
  }
  Future<void> loadCropData() async {
    final String response = await rootBundle.loadString('assets/crop.json');
    final data = json.decode(response) as List;
    setState(() {
      _crops = data.map((json) => CropData.fromJson(json)).toList();
    });
  }
  Future<void> _showFilterDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Filter"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: cropFilter,
                  decoration: const InputDecoration(
                    labelText: "Crop",
                    border: OutlineInputBorder(),
                  ),
                  items: _crops
                      .map((c) => c.crop)
                      .toSet()
                      .map((crop) => DropdownMenuItem(
                    value: crop,
                    child: Text(crop),
                  ))
                      .toList(),
                  onChanged: (value) => setState(() => cropFilter = value),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: partitionFilter,
                  decoration: const InputDecoration(
                    labelText: "Partition",
                    border: OutlineInputBorder(),
                  ),
                  items: _crops
                      .map((c) => c.partitions)
                      .toSet()
                      .map((p) => DropdownMenuItem(
                    value: p,
                    child: Text(p),
                  ))
                      .toList(),
                  onChanged: (value) => setState(() => partitionFilter = value),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: statusFilter,
                  decoration: const InputDecoration(
                    labelText: "Status",
                    border: OutlineInputBorder(),
                  ),
                  items: _crops
                      .map((c) => c.status)
                      .toSet()
                      .map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(s),
                  ))
                      .toList(),
                  onChanged: (value) => setState(() => statusFilter = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                resetFilters();
                Navigator.pop(ctx);
              },
              child: const Text("Reset"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {});
                Navigator.pop(ctx);
              },
              child: const Text("Apply"),
            ),
          ],
        );
      },
    );
  }

  // 🔹 Get filtered crops
  List<CropData> get filteredCrops {
    return _crops.where((crop) {
      final matchesSearch =
      crop.crop.toLowerCase().contains(searchQuery.toLowerCase());

      final matchesCrop = cropFilter == null || crop.crop == cropFilter;
      final matchesPartition =
          partitionFilter == null || crop.partitions == partitionFilter;
      final matchesStatus =
          statusFilter == null || crop.status == statusFilter;

      // ✅ Safe date parsing
      final cropSowing = tryParseDate(crop.sowingDate);
      final cropPlanting = tryParseDate(crop.plantingDate);

      // Ignore this crop if we can’t parse the date
      if (cropSowing == null || cropPlanting == null) return false;

      final matchesSowing = (sowingFromDate == null && sowingToDate == null) ||
          (sowingFromDate != null &&
              sowingToDate != null &&
              cropSowing.isAfter(sowingFromDate!.subtract(const Duration(days: 1))) &&
              cropSowing.isBefore(sowingToDate!.add(const Duration(days: 1))));

      final matchesPlanting =
          (plantingFromDate == null && plantingToDate == null) ||
              (plantingFromDate != null &&
                  plantingToDate != null &&
                  cropPlanting.isAfter(plantingFromDate!.subtract(const Duration(days: 1))) &&
                  cropPlanting.isBefore(plantingToDate!.add(const Duration(days: 1))));

      return matchesSearch &&
          matchesCrop &&
          matchesPartition &&
          matchesStatus &&
          matchesSowing &&
          matchesPlanting;
    }).toList();
  }


  void resetFilters() {
    setState(() {
      cropFilter = null;
      partitionFilter = null;
      statusFilter = null;
      sowingFromDate = null;
      sowingToDate = null;
      plantingFromDate = null;
      plantingToDate = null;
    });
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
              onSelectionChanged: (args) {
                if (args.value is PickerDateRange) {
                  start = args.value.startDate;
                  end = args.value.endDate ?? args.value.startDate;
                }
              },
              onSubmit: (val) {
                Navigator.pop(
                  ctx,
                  (start != null && end != null)
                      ? DateTimeRange(start: start!, end: end!)
                      : null,
                );
              },
              onCancel: () => Navigator.pop(ctx, null),
            ),
          ),
        );
      },
    );
  }



  // 🔹 Reset filters


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        elevation: 0,
        title: const Text(
          "Nursery",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔹 Search + Filter Row
            buildSearchAndFilterBar(context),
            _dashboardSection(context, filteredCrops),
            const SizedBox(height: 20),
            _dashboardTable(context, filteredCrops),
          ],
        ),
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
                transitionDuration: const Duration(milliseconds: 300),
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
                                    value: cropFilter,
                                    decoration: const InputDecoration(
                                      labelText: "Crop",
                                      border: OutlineInputBorder(),
                                    ),
                                    items: _crops
                                        .map((c) => c.crop)
                                        .toSet()
                                        .map((crop) => DropdownMenuItem(
                                      value: crop,
                                      child: Text(crop),
                                    ))
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() => cropFilter = value);
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
                                    items: _crops
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
                                    items: _crops
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
                                  InkWell(
                                    onTap: () async {
                                      final picked =
                                      await showCustomDateRangeDialog(
                                          context);
                                      if (picked != null) {
                                        setState(() {
                                          sowingFromDate = picked.start;
                                          sowingToDate = picked.end;
                                        });
                                      }
                                    },
                                    child: InputDecorator(
                                      decoration: const InputDecoration(
                                        labelText: "Sowing Date Range",
                                        border: OutlineInputBorder(),
                                      ),
                                      child: Text(
                                        (sowingFromDate != null &&
                                            sowingToDate != null)
                                            ? "${DateFormat('dd/MM/yyyy').format(sowingFromDate!)} - ${DateFormat('dd/MM/yyyy').format(sowingToDate!)}"
                                            : "Select Date Range",
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 20),

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

  //filter box






// Chart
Widget _dashboardSection(BuildContext context, List<CropData> crops) {
  return SizedBox(
    height: 300,
    child: SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      legend: const Legend(isVisible: true, position: LegendPosition.bottom),
      series: <CartesianSeries>[
        ColumnSeries<CropData, String>(
          name: 'Seeds Required',
          dataSource: crops,
          xValueMapper: (CropData data, _) => data.crop,
          yValueMapper: (CropData data, _) => data.seedsRequired,
          onPointTap: (ChartPointDetails details) {
            if (details.pointIndex != null) {
              final CropData selectedCrop = crops[details.pointIndex!];

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CropDetailPage(cropName: selectedCrop.crop),
                ),
              );

            }
          },
        ),
        ColumnSeries<CropData, String>(
          name: 'Seeds Achieved',
          dataSource: crops,
          xValueMapper: (CropData data, _) => data.crop,
          yValueMapper: (CropData data, _) => data.achieved,
          onPointTap: (ChartPointDetails details) {
            if (details.pointIndex != null) {
              final CropData selectedCrop = crops[details.pointIndex!];

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CropDetailPage(cropName: selectedCrop.crop),
                ),
              );

            }
          },
        ),
      ],
    ),
  );
}

// Table
Widget _dashboardTable(BuildContext context, List<CropData> crops) {
  final screenWidth = MediaQuery.of(context).size.width;

  return LayoutBuilder(
    builder: (context, constraints) {
      final double colWidth = constraints.maxWidth / 7;
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

      Color getRowColor(String status) {
        switch (status) {
          case "Completed":
            return Colors.green.shade100;
          case "Pending":
            return Colors.orange.shade100;
          case "Ongoing":
            return Colors.blue.shade100;
          default:
            return Colors.grey.shade100;
        }
      }

      Color getTextColor(String status) {
        switch (status) {
          case "Completed":
            return Colors.green.shade700;
          case "Pending":
            return Colors.orange.shade700;
          case "Ongoing":
            return Colors.blue.shade700;
          default:
            return Colors.black87;
        }
      }

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 8,
          dataRowMinHeight: 48,
          dataRowMaxHeight: 64,
          headingRowColor: MaterialStateProperty.all(Colors.black87),
          headingTextStyle: TextStyle(
            color: Colors.white,
            fontSize: headingFontSize,
            fontWeight: FontWeight.bold,
          ),
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
          rows: crops.map((crop) {
            return DataRow(
              color: MaterialStateProperty.all(getRowColor(crop.status)),
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
                        color: getTextColor(crop.status),
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



// Example dataset

