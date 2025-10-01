import 'package:flutter/material.dart';

import '../landprep/landprep.dart';
import '../nursery/nursery.dart';
class navigationDrawer extends StatelessWidget {
  const navigationDrawer({super.key});

  @override
  Widget build(BuildContext context) => Drawer(
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildHeader(context),
          buildMenuItems(context),
        ],
      ),
    ),
  );

  Widget buildHeader(BuildContext context) => Container(
    padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),

    height: MediaQuery.of(context).size.height * 0.15
    , // 25% of screen height
    color: Colors.green, // just for visibility
    alignment: Alignment.center,
    child: const Text(
      "Farming",
      style: TextStyle(fontSize: 20, color: Colors.white),
    ),
  );

  Widget buildMenuItems(BuildContext context)=> Wrap(
    runSpacing: 16,
    children: [
      ListTile(
        leading: const Icon(Icons.ac_unit_rounded),
        title: const Text("Nursery"),
        onTap: (){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  NurseryDashboard(),
            ),
          );
        },
      ),
      ListTile(
        leading: const Icon(Icons.home_filled),
        title: const Text("LandPreparation"),
        onTap: (){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  LandPrepPage(),
            ),
          );
        },
      )
    ],
  );
}
