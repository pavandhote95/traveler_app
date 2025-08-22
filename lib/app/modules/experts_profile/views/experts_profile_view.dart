import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:travel_app2/app/constants/app_color.dart';
import '../controllers/experts_profile_controller.dart';

class ExpertsProfileView extends StatelessWidget {
  final int expertId;
  const ExpertsProfileView({super.key, required this.expertId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ExpertsProfileController());

    // 🔥 Load expert detail
    controller.fetchExpertDetail(expertId);

    return Scaffold(
      backgroundColor: AppColors.mainBg,
      appBar: AppBar(
        backgroundColor: AppColors.mainBg,
        title: Text(
          'Expert Profile',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final expert = controller.expert;

        if (expert.isEmpty) {
          return const Center(child: Text("No data found", style: TextStyle(color: Colors.white)));
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header image with name
              Container(
                height: 240,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(expert['image']),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  alignment: Alignment.bottomLeft,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.7)
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    expert['title'] ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .slideX(begin: -0.3, curve: Curves.easeOut),

              const SizedBox(height: 20),

              // Profile Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expert['sub_title'] ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.buttonBg,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        const Icon(Icons.place,
                            color: Colors.redAccent, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(expert['location'] ?? '',
                              style: GoogleFonts.poppins(
                                  color: Colors.white70)),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.language,
                            color: Colors.white54, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            (expert['language'] as List)
                                .map((lang) => lang['value'])
                                .join(', '),
                            style: GoogleFonts.poppins(color: Colors.white70),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    Divider(color: Colors.white24),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        const Icon(Icons.map,
                            color: AppColors.buttonBg, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(expert['days'] ?? '',
                              style: GoogleFonts.openSans(
                                  color: Colors.white60, fontSize: 13)),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.people,
                            color: AppColors.buttonBg, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          expert['guided'] ?? '',
                          style: GoogleFonts.poppins(
                              color: Colors.white60, fontSize: 13),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    Divider(color: Colors.white24),
                    const SizedBox(height: 12),

                    Text('About the Expert',
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(
                      expert['about'] ?? '',
                      style: GoogleFonts.poppins(
                          color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.3),
              ),

              const SizedBox(height: 100),
            ],
          ),
        );
      }),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chat feature coming soon!')),
              );
            },
            icon: const Icon(Icons.chat),
            label: Text(
              'Chat with Expert',
              style: GoogleFonts.openSans(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonBg,
              foregroundColor: AppColors.appbar,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ).animate().fadeIn().slideX(begin: -0.2),
        ),
      ),
    );
  }
}
