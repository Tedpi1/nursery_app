import 'package:flutter/material.dart';
import 'package:nursery_app/nursery/nursery.dart'; // or correct file

class cropName {
  final String crop;
  final String partitions;
  final String plantingDate;
  final int seedsRequired;
  final int achieved;
  final String status;

  cropName({
    required this.crop,
    required this.partitions,
    required this.plantingDate,
    required this.seedsRequired,
    required this.achieved,
    required this.status,
  });
}

class NurseryBatchDialog extends StatefulWidget {
  final CropData crop;

  const NurseryBatchDialog({super.key, required this.crop});

  @override
  State<NurseryBatchDialog> createState() => _NurseryBatchDialogState();
}

class _NurseryBatchDialogState extends State<NurseryBatchDialog> {
  final TextEditingController seedsPerPlugController = TextEditingController(
    text: '4',
  );
  final TextEditingController trayCapacityController = TextEditingController(
    text: '210',
  );
  final TextEditingController noOfTraysController = TextEditingController(
    text: '0',
  );
  final TextEditingController nurseryBlockController = TextEditingController();

  DateTime? sowingDate;

  @override
  void initState() {
    super.initState();
    sowingDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final crop = widget.crop;
    final deficit = crop.seedsRequired - crop.achieved;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Nursery Crop Batch"),
        backgroundColor: Colors.green.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Top Info Section
          Card(
            child: Table(
              columnWidths: const {
                0: IntrinsicColumnWidth(),
                1: FlexColumnWidth(),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                _tableRow("Scheduled N. Week", "Wk 39-2025"),
                _tableRow("Crop", crop.crop, isChip: true),
                _tableRow("Target P. Block", crop.partitions),
                _tableRow("Planting Date", crop.plantingDate),
                _tableRow(
                  "Seeds Required (+10%)",
                  crop.seedsRequired.toString(),
                ),
                _tableRow("Achieved", crop.achieved.toString()),
                _tableRow("Deficit", deficit.toString()),
                _tableRow("Status", crop.status, statusStyle: true),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Nursery Block Partition
          TextField(
            controller: nurseryBlockController,
            decoration: const InputDecoration(
              labelText: "Nursery Block Partition",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          // Sowing Date Picker
          TextField(
            readOnly: true,
            decoration: InputDecoration(
              labelText: "Sowing Date",
              border: const OutlineInputBorder(),
              suffixIcon: const Icon(Icons.calendar_today),
              hintText:
                  sowingDate != null
                      ? sowingDate!.toIso8601String().split('T')[0]
                      : '',
            ),
            onTap: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: sowingDate ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setState(() {
                  sowingDate = picked;
                });
              }
            },
          ),
          const SizedBox(height: 24),

          // Propagules Tabs
          DefaultTabController(
            length: 3,
            child: Column(
              children: [
                const TabBar(
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black,
                  indicator: BoxDecoration(color: Colors.green),
                  tabs: [
                    Tab(text: 'SEEDS'),
                    Tab(text: 'SEEDLINGS'),
                    Tab(text: 'CUTTINGS'),
                  ],
                ),
                Container(
                  height: 160,
                  padding: const EdgeInsets.all(16),
                  child: TabBarView(
                    children: [
                      // SEEDS
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: seedsPerPlugController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: "Seeds (per plug)",
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextField(
                                  controller: noOfTraysController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: "No of Trays",
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: trayCapacityController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Tray plug capacity",
                            ),
                          ),
                        ],
                      ),
                      const Center(child: Text("Seedlings input")),
                      const Center(child: Text("Cuttings input")),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Save Button
          ElevatedButton(
            onPressed: () {
              // Add your save logic here
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("Saved/Updated")));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text("Save/Update"),
          ),
          const SizedBox(height: 32),

          // Nursery Activities Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Nursery Activities",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Add activity logic
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                child: const Text("Add Nursery Activity"),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Data Table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text("Date")),
                DataColumn(label: Text("Activity")),
                DataColumn(label: Text("Workers")),
                DataColumn(label: Text("Total Hrs worked")),
                DataColumn(label: Text("#")),
              ],
              rows: const [
                // Example row (empty)
              ],
            ),
          ),
        ],
      ),
    );
  }

  TableRow _tableRow(
    String label,
    String value, {
    bool isChip = false,
    bool statusStyle = false,
  }) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child:
              isChip
                  ? Chip(
                    label: Text(value),
                    backgroundColor: Colors.green,
                    labelStyle: const TextStyle(color: Colors.white),
                  )
                  : Text(
                    value,
                    style:
                        statusStyle
                            ? TextStyle(
                              color:
                                  value == "Pending"
                                      ? Colors.blue
                                      : Colors.green,
                              fontWeight: FontWeight.bold,
                            )
                            : null,
                  ),
        ),
      ],
    );
  }
}
