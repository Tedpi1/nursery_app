import 'package:flutter/material.dart';
import 'package:nursery_app/constant/color.dart';

class LandPreparationPage extends StatefulWidget {
  const LandPreparationPage({super.key});

  @override
  State<LandPreparationPage> createState() => _LandPreparationPageState();
}

class _LandPreparationPageState extends State<LandPreparationPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _bedMakingDateController =
  TextEditingController(text: "2025/09/18");
  final TextEditingController _lengthController = TextEditingController(text: "45");
  final TextEditingController _widthController = TextEditingController(text: "1");
  final TextEditingController _heightController = TextEditingController(text: "0");
  final TextEditingController _bedsController = TextEditingController(text: "15");
  DateTime selectedDate = DateTime.now();
  final TextEditingController activityController = TextEditingController();
  final TextEditingController workerController = TextEditingController();
  double totalHours = 0;
  String? _selectedOption; // "Yes" or "No"


  // Toggles
  bool plasticCoverUsed = false;
  bool plantingHoles = false;
  bool daniHolesMachine = false;
  bool rollerUsed = false;

  String? plasticCoverColor; // Black Down / White Up
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
            // 👇 Take 80% of screen width on large devices, 95% on small
            width: screenSize.width * 0.8,
            // 👇 Optional: give it a max height so it scrolls if too tall
            height: screenSize.height * 0.6,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          "LandPrep Activity Form",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Date Picker
                    Text(
                      "Date*",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
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
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text("${selectedDate.toLocal()}".split(' ')[0]),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Activity Input
                    Text(
                      "Activity*",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: activityController,
                      decoration: InputDecoration(
                        hintText: "Search or type activity...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Worker Input
                    Text(
                      "Worker",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: workerController,
                      decoration: InputDecoration(
                        hintText: "Enter worker name",
                        suffixIcon: Icon(Icons.add),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Total Hours
                    Text(
                      "Total Hrs",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              if (totalHours > 0) totalHours -= 1;
                            });
                          },
                          icon: Icon(Icons.remove, color: Colors.red),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              totalHours.toStringAsFixed(2),
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              totalHours += 1;
                            });
                          },
                          icon: Icon(Icons.add, color: Colors.green),
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
                          child: Text("Cancel"),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Handle Save
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                          ),
                          icon: Icon(Icons.save),
                          label: Text("Save"),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text("Land Preparation for Block 3A"),
        backgroundColor: AppColors.warning,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: _landPreppage(),
      ),
    );
  }

  Widget _landPreppage(){
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section: Bedmaking Entry
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Bedmaking Entry",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),

                    // Bed Making Date
                    TextFormField(
                      controller: _bedMakingDateController,
                      decoration: const InputDecoration(
                        labelText: "Bed Making Date",
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none, // removes all borders initially
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.zero,
                          gapPadding: 0,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blue,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.zero,
                          gapPadding: 0,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _bedsController,
                      decoration: const InputDecoration(
                        labelText: "Number of Beds",
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none, // removes all borders initially
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.zero,
                          gapPadding: 0,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blue,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.zero,
                          gapPadding: 0,
                        ),
                      ),
                    ),

                    // Number of Beds


                    const SizedBox(height: 12),

                    // Bed Dimensions
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _lengthController,
                            decoration: const InputDecoration(
                              labelText: "Length (m)",
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _widthController,
                            decoration: const InputDecoration(
                              labelText: "Width (m)",
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _heightController,
                            decoration: const InputDecoration(
                              labelText: "Height (cm)",
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Plastic Cover Used


                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Save logic
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.brown,
                        backgroundColor: Colors.white,
                      ),
                      child: const Text("Save/Update Bedmaking Information"),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Section: Planting Ready Confirmation
            Card(
              elevation: 2,
              color: _selectedOption == "Yes"
                  ? Colors.green.shade800 // ✅ Deep green for Yes
                  : _selectedOption == "No"
                  ? Colors.red // ✅ Red for No
                  : null, // default if not selected
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      "Is the Block ready?",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _selectedOption == null
                            ? Colors.black
                            : Colors.white, // ✅ White text when Yes/No chosen
                      ),
                    ),

                    const Divider(),

                    // ✅ Yes/No options
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            activeColor: Colors.white, // ✅ radio button circle color
                            title: Text(
                              "Yes",
                              style: TextStyle(
                                color: _selectedOption == "Yes"
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            value: "Yes",
                            groupValue: _selectedOption,
                            onChanged: (value) {
                              setState(() => _selectedOption = value);
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            activeColor: Colors.white, // ✅ radio button circle color
                            title: Text(
                              "No",
                              style: TextStyle(
                                color: _selectedOption == "No"
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            value: "No",
                            groupValue: _selectedOption,
                            onChanged: (value) {
                              setState(() => _selectedOption = value);
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    if (_selectedOption != null)
                      Text(
                        "Selected: $_selectedOption",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // ✅ Always white on colored card
                        ),
                      ),
                  ],
                ),
              ),
            ),



            const SizedBox(height: 20),

            // Section: More Activities
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text("📝 Land Preparation More Activities",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: const [
                        Expanded(child: Text("Date")),
                        Expanded(child: Text("Activity")),
                        Expanded(child: Text("Workers")),
                        Expanded(child: Text("Total Hrs Worked")),
                      ],
                    ),
                    const Divider(),
                    ElevatedButton(
                      onPressed: () {
                        _showActivityDialog();
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.purple,
                        backgroundColor: Colors.white,
                      ),
                      child: const Text("Add New Activity"),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
