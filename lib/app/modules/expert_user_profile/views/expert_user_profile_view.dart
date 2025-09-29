import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/expert_user_profile_controller.dart';

class ExpertUserProfileView extends GetView<ExpertUserProfileController> {
  ExpertUserProfileView({super.key});
  final ExpertUserProfileController controller =
      Get.put(ExpertUserProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1B1B), // Dark background similar to ExpertsProfileView
      appBar: AppBar(
        title: Text(
          "Expert Profile",
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1B1B1B),
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }

        if (controller.profileData.isEmpty) {
          return const Center(
              child: Text(
            "No profile data found",
            style: TextStyle(color: Colors.white),
          ));
        }

        final data = controller.profileData;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Image with shadow & animation
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.1),
                      blurRadius: 12,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: CircleAvatar(
                  radius: 65,
                  backgroundColor: Colors.grey.shade800,
                  backgroundImage: NetworkImage(data["image_url"] ?? ""),
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .scale(duration: 600.ms),
              const SizedBox(height: 16),

              // Name
              Text(
                data["name"] ?? "",
                style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ).animate().fadeIn(duration: 700.ms).slideY(begin: 0.3, end: 0),
              const SizedBox(height: 8),

              // Email & Phone
              Text(
                data["email"] ?? "",
                style: GoogleFonts.poppins(
                    fontSize: 16, color: Colors.grey[300]),
              ).animate().fadeIn(duration: 800.ms),
              Text(
                data["phone_number"] ?? "",
                style: GoogleFonts.poppins(
                    fontSize: 16, color: Colors.grey[300]),
              ).animate().fadeIn(duration: 850.ms),
              const SizedBox(height: 12),

              // Bio
              Text(
                data["bio"] ?? "No bio available",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey[400]),
              )
                  .animate()
                  .fadeIn(duration: 900.ms)
                  .slideX(begin: -0.3, end: 0),
              const SizedBox(height: 16),

              // Points Chip
              Chip(
                label: Text(
                  "Points: ${data["user_points"] ?? 0}",
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500, color: Colors.white),
                ),
                backgroundColor: Colors.redAccent.withOpacity(0.2),
              ).animate().scale(duration: 700.ms).fadeIn(),
              const SizedBox(height: 24),

              // Ratings & Reviews
              if (data["ratings"] != null && data["ratings"].isNotEmpty) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Reviews",
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ).animate().fadeIn(duration: 800.ms),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: data["ratings"].length,
                  itemBuilder: (context, index) {
                    final rating = data["ratings"][index];
                    return Card(
                      color: const Color(0xFF2C2C2C),
                      elevation: 3,
                      shadowColor: Colors.redAccent.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.redAccent.withOpacity(0.2),
                          child: Text(
                            rating["reviewer_name"][0].toUpperCase(),
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent),
                          ),
                        ),
                        title: Text(
                          rating["reviewer_name"],
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                        subtitle: Text(
                          rating["review"],
                          style: GoogleFonts.poppins(
                              fontSize: 14, color: Colors.grey[300]),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            rating["rating"],
                            (i) => const Icon(Icons.star,
                                color: Colors.amber, size: 20),
                          ),
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 500.ms, delay: (index * 200).ms)
                        .slideX(begin: 0.3, end: 0);
                  },
                ),
              ],
            ],
          ),
        );
      }),
    );
  }
}
