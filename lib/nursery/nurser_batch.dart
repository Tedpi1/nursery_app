import 'package:flutter/material.dart';
import 'package:nursery_app/nursery/nursery.dart'; // adjust path

// Dummy Nursery Activity Model
class NurseryActivity {
  final String date;
  final String activity;
  final int workers;
  final int totalHours;

  NurseryActivity({
    required this.date,
    required this.activity,
    required this.workers,
    required this.totalHours,
  });
}

class NurseryBatchDialog extends StatefulWidget {
  final CropData crop;

  const NurseryBatchDialog({super.key, required this.crop});

  @override
  State<NurseryBatchDialog> createState() => _NurseryBatchDialogState();
}

class _NurseryBatchDialogState extends State<NurseryBatchDialog> {
  // Controllers
  final TextEditingController seedsPerPlugController =
  TextEditingController(text: '4');
  final TextEditingController trayCapacityController =
  TextEditingController(text: '210');
  final TextEditingController noOfTraysController =
  TextEditingController(text: '0');
  final TextEditingController nurseryBlockController = TextEditingController();

  DateTime? sowingDate;

  final TextEditingController activityController = TextEditingController();
  final TextEditingController workerController = TextEditingController();
  double totalHours = 0;

  final List<NurseryActivity> activities = [
    NurseryActivity(
      date: "2025-09-20",
      activity: "Weeding",
      workers: 4,
      totalHours: 16,
    ),
    NurseryActivity(
      date: "2025-09-21",
      activity: "Watering",
      workers: 2,
      totalHours: 4,
    ),
  ];

  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    sowingDate = DateTime.now();
  }

  //activty dialoge
  void _showActivityDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final screenSize = MediaQuery.of(context).size;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: SizedBox(
            width: screenSize.width * 0.8,
            height: screenSize.height * 0.6,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          "Nursery Activity Form",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Date
                    const Text("Date*", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (pickedDate != null) {
                          setState(() => selectedDate = pickedDate);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text("${selectedDate.toLocal()}".split(' ')[0]),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Activity
                    const Text("Activity*", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: activityController,
                      decoration: InputDecoration(
                        hintText: "Type activity...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Worker
                    const Text("Worker", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: workerController,
                      decoration: InputDecoration(
                        hintText: "Enter worker count",
                        suffixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Total Hours
                    const Text("Total Hrs", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              if (totalHours > 0) totalHours -= 1;
                            });
                          },
                          icon: const Icon(Icons.remove, color: Colors.red),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              totalHours.toStringAsFixed(2),
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              totalHours += 1;
                            });
                          },
                          icon: const Icon(Icons.add, color: Colors.green),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              activities.add(NurseryActivity(
                                date: "${selectedDate.toLocal()}".split(' ')[0],
                                activity: activityController.text,
                                workers: int.tryParse(workerController.text) ?? 0,
                                totalHours: totalHours.toInt(),
                              ));
                            });
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.save),
                          label: const Text("Save"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
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
          // Call your mini-widgets
          CropInfoTable(crop, deficit),
          const SizedBox(height: 16),
          NurseryBlockForm(),
          const SizedBox(height: 24),
          PropagulesTabs(),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Saved/Updated")),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text("Save/Update"),
          ),
          const SizedBox(height: 32),
          ActivitiesSection(),
        ],
      ),
    );
  }

  //subwigets

  Widget CropInfoTable(CropData crop, int deficit) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.green.shade100),
          columns: const [
            DataColumn(label: Text("Scheduled N. Week")),
            DataColumn(label: Text("Crop")),
            DataColumn(label: Text("Target P. Block")),
            DataColumn(label: Text("Planting Date")),
            DataColumn(label: Text("Seeds Required (+10%)")),
            DataColumn(label: Text("Achieved")),
            DataColumn(label: Text("Deficit")),
            DataColumn(label: Text("Status")),
          ],
          rows: [
            DataRow(
              cells: [
                const DataCell(Text("Wk 39-2025")),
                DataCell(
                  Chip(
                    label: Text(crop.crop),
                    backgroundColor: Colors.green,
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
                ),
                DataCell(Text(crop.partitions)),
                DataCell(Text(crop.plantingDate)),
                DataCell(Text(crop.seedsRequired.toString())),
                DataCell(Text(crop.achieved.toString())),
                DataCell(Text(deficit.toString())),
                DataCell(
                  Text(
                    crop.status,
                    style: TextStyle(
                      color: crop.status == "Pending"
                          ? Colors.blue
                          : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget NurseryBlockForm() {
    return Column(
      children: [
        TextField(
          controller: nurseryBlockController,
          decoration: const InputDecoration(
            labelText: "Nursery Block Partition",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          readOnly: true,
          decoration: InputDecoration(
            labelText: "Sowing Date",
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.calendar_today),
            hintText: sowingDate != null
                ? "${sowingDate!.year}-${sowingDate!.month.toString().padLeft(2, '0')}-${sowingDate!.day.toString().padLeft(2, '0')}"
                : '',
          ),
          onTap: () async {
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: sowingDate ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
            );
            if (picked != null) setState(() => sowingDate = picked);
          },
        ),
      ],
    );
  }

  Widget PropagulesTabs() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const TabBar(
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              tabs: [
                Tab(text: 'SEEDS'),
                Tab(text: 'SEEDLINGS'),
                Tab(text: 'CUTTINGS'),
              ],
            ),
          ),
          Container(
            height: 160,
            padding: const EdgeInsets.all(16),
            child: TabBarView(
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: seedsPerPlugController,
                            decoration: const InputDecoration(
                              labelText: "Seeds (per plug)",
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: noOfTraysController,
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
    );
  }

  Widget ActivitiesSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Nursery Activities",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: _showActivityDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text("Add Activity"),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text("Date")),
              DataColumn(label: Text("Activity")),
              DataColumn(label: Text("Workers")),
              DataColumn(label: Text("Total Hrs")),
            ],
            rows: activities
                .map(
                  (a) => DataRow(
                cells: [
                  DataCell(Text(a.date)),
                  DataCell(Text(a.activity)),
                  DataCell(Text(a.workers.toString())),
                  DataCell(Text(a.totalHours.toString())),
                ],
              ),
            )
                .toList(),
          ),
        ),
      ],
    );
  }
}
