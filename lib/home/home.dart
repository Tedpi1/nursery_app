import 'package:flutter/material.dart';

import '../drawer/drawer.dart';

class homepage extends StatefulWidget {
  const homepage({super.key});

  @override
  State<homepage> createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drawer'),
      ),
      drawer:navigationDrawer() ,
      body: SingleChildScrollView(
        child: Padding(padding: const EdgeInsets.all(10),
        child: Row(
          children: [

          ],
        ),
        ),
      ),
    );
  }
}
