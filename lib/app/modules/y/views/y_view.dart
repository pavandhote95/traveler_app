import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/y_controller.dart';

class YView extends GetView<YController> {
  const YView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'YView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
