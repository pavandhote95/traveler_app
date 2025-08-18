import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/expertsprofile_controller.dart';

class ExpertsprofileView extends GetView<ExpertsprofileController> {
  const ExpertsprofileView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ExpertsprofileView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'ExpertsprofileView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
