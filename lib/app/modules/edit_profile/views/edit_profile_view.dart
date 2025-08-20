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

                // 🟢 Personal Info Card
                _buildCard(
                  title: "Personal Information",
                  children: [
                    _buildTextField("First Name", controller.firstNameController),
                    const SizedBox(height: 12),
                    _buildTextField("Last Name", controller.lastNameController),
                    const SizedBox(height: 12),
                    _buildTextField("Bio", controller.bioController, maxLines: 3),
                    const SizedBox(height: 12),
                    _buildTextField("Email", controller.emailController,
                        keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 12),
                    _buildTextField("Phone", controller.phoneController,
                        keyboardType: TextInputType.phone),
                  ],
                ),
                const SizedBox(height: 20),

                // 🟢 Travel Info Card
                _buildCard(
                  title: "Travel Details",
                  children: [
                    _buildTextField("Location", controller.locationController),
                    const SizedBox(height: 12),
                    _buildTextField("Travel Interest", controller.travelInterestController, maxLines: 2),
                    const SizedBox(height: 12),
                    _buildTextField("Visited Places", controller.visitedPlacesController, maxLines: 2),
                    const SizedBox(height: 12),
                    _buildTextField("Dream Destination", controller.dreamDestinationController),
                    const SizedBox(height: 12),
                    _buildTextField("Language", controller.languageController),
                  ],
                ),
                const SizedBox(height: 20),

                // 🟢 Travel Type Card
                _buildCard(
                  title: "Travel Type",
                  children: [
                    Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          children: [
                            Radio<String>(
                              value: "Solo",
                              groupValue: controller.travelType.value,
                              onChanged: (value) => controller.travelType.value = value!,
                            ),
                            const Text("Solo", style: TextStyle(color: Colors.white)),
                          ],
                        ),
                        Row(
                          children: [
                            Radio<String>(
                              value: "Group",
                              groupValue: controller.travelType.value,
                              onChanged: (value) => controller.travelType.value = value!,
                            ),
                            const Text("Group", style: TextStyle(color: Colors.white)),
                          ],
                        ),
                        Row(
                          children: [
                            Radio<String>(
                              value: "Slow",
                              groupValue: controller.travelType.value,
                              onChanged: (value) => controller.travelType.value = value!,
                            ),
                            const Text("Slow", style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ],
                    )),
                  ],
                ),
                const SizedBox(height: 20),

                // 🟢 Travel Mode Card
                _buildCard(
                  title: "Travel Mode",
                  children: [
                    Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          children: [
                            Radio<String>(
                              value: "Normal",
                              groupValue: controller.travelMode.value,
                              onChanged: (value) => controller.travelMode.value = value!,
                            ),
                            const Text("Normal", style: TextStyle(color: Colors.white)),
                          ],
                        ),
                        Row(
                          children: [
                            Radio<String>(
                              value: "Digital",
                              groupValue: controller.travelMode.value,
                              onChanged: (value) => controller.travelMode.value = value!,
                            ),
                            const Text("Digital", style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ],
                    )),
                  ],
                ),

                const SizedBox(height: 30),

                // 🟢 Save Button
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      controller.updateProfile();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                    elevation: 6,
                  ),
                  child: Text(
                    'Save Changes',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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

  // 🟢 Profile Image Widget
  Widget _buildProfileImage() {
    return Center(
      child: Stack(
        children: [
          Obx(() {
            final imageFile = controller.selectedImage.value;
            return CircleAvatar(
              radius: 55,
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
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                ),
                padding: const EdgeInsets.all(6),
                child: const Icon(Icons.edit, size: 20, color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🟢 Card Section
  Widget _buildCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.poppins(
                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  // 🟢 Reusable TextField
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
        labelStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.white.withOpacity(0.07),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
    );
  }
}