import 'package:flutter/material.dart';
import 'package:nursery_app/nursery/nurser_batch.dart';
import 'package:nursery_app/nursery/nursery.dart';

class CropDetailPage extends StatelessWidget {
  final CropData crop;

  const CropDetailPage({super.key, required this.crop});

  @override
  Widget build(BuildContext context) {
    final deficit = crop.seedsRequired - crop.achieved;

    return Scaffold(
      appBar: AppBar(
        title: Text("${crop.crop} Details"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(Colors.black87),
            headingTextStyle: const TextStyle(color: Colors.white),
            columns: const [
              DataColumn(label: Text("Batch ID")),
              DataColumn(label: Text("Partitions")),
              DataColumn(label: Text("Crop")),
              DataColumn(label: Text("Sowing Date")),
              DataColumn(label: Text("Planting Date")),
              DataColumn(label: Text("Seeds Req.")),
              DataColumn(label: Text("Achieved")),
              DataColumn(label: Text("Deficit")),
              DataColumn(label: Text("Status")),
              DataColumn(label: Text("#")), // 🔹 new column
            ],
            rows: [
              DataRow(
                cells: [
                  const DataCell(Text("0")), // Example Batch ID
                  DataCell(Text(crop.partitions)),
                  DataCell(
                    Chip(
                      label: Text(crop.crop),
                      backgroundColor: Colors.green,
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                  ),
                  DataCell(Text(crop.sowingDate)),
                  DataCell(Text(crop.plantingDate)),
                  DataCell(Text(crop.seedsRequired.toString())),
                  DataCell(Text(crop.achieved.toString())),
                  DataCell(Text(deficit.toString())),
                  DataCell(
                    Chip(
                      label: Text(crop.status),
                      backgroundColor:
                          crop.status == "Completed"
                              ? Colors.green
                              : (crop.status == "Pending"
                                  ? Colors.orange
                                  : Colors.blue),
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                  ),
                  // 🔹 Action button inside #
                  DataCell(
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder:
                              (context) => Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  height:
                                      MediaQuery.of(context).size.height * 0.7,
                                  child: NurseryBatchDialog(crop: crop),
                                ),
                              ),
                        );
                      },
                      child: const Text("Open"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 🔹 Dialog Content Widget (Nursery Crop Batch Page inside a dialog)
