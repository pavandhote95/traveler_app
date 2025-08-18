import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app2/app/constants/app_color.dart';
import 'package:travel_app2/app/modules/edit_profile/controllers/edit_profile_controller.dart';

class EditProfileView extends StatelessWidget {
  EditProfileView({super.key});

  final EditProfileController controller = Get.put(EditProfileController());

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBg,
      appBar: AppBar(
        elevation: 5,
        backgroundColor: AppColors.mainBg,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Edit Profile',
          style: GoogleFonts.openSans(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.centerleft, AppColors.centerright],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildProfileImage(),
                const SizedBox(height: 20),
                _buildTextField("Full Name", controller.nameController),
                const SizedBox(height: 16),
                _buildTextField("Bio", controller.bioController, maxLines: 3),
                const SizedBox(height: 16),
                _buildTextField("Email", controller.emailController,
                    keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),
                _buildTextField("Phone", controller.phoneController,
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      controller.updateProfile();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: Text(
                    'Save Changes',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Center(
      child: Stack(
        children: [
          Obx(() {
            final imageFile = controller.selectedImage.value;
            return CircleAvatar(
              radius: 50,
              backgroundImage: imageFile != null
                  ? FileImage(imageFile)
                  : const NetworkImage(
                'https://randomuser.me/api/portraits/men/11.jpg',
              ) as ImageProvider,
            );
          }),

          Positioned(
            bottom: 0,
            right: 4,
            child: GestureDetector(
              onTap: controller.pickImage,
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                padding: const EdgeInsets.all(6),
                child: const Icon(Icons.edit, size: 18, color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.poppins(color: Colors.white),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label can’t be empty';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
    );
  }
}
