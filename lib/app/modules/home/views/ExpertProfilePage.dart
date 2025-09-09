import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:travel_app2/app/constants/app_color.dart';
import 'package:travel_app2/app/modules/dm/views/dm_view.dart';
import 'package:travel_app2/app/modules/expert/views/expert_view.dart';
import 'package:travel_app2/app/modules/login/views/login_view.dart';
import 'package:travel_app2/app/routes/app_pages.dart';

import '../../dm/views/dm_view.dart';

class ExpertProfilePage extends StatelessWidget {
  final String expertImage;
  final String expertName;
  final String expertTitle;
  final String locationExpertise;
  final double rating;
  final int ratingsCount;
  final int totalTravelers;
  final String itinerary;
  final List<String> languages;

  const ExpertProfilePage({
    super.key,
    required this.expertImage,
    required this.expertName,
    required this.expertTitle,
    required this.locationExpertise,
    required this.rating,
    required this.ratingsCount,
    required this.totalTravelers,
    required this.itinerary,
    required this.languages,
  });

  @override
  Widget build(BuildContext context) {
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
      body: Column(
        children: [
          // Header image with name
          Container(
            height: 240,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(expertImage),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              alignment: Alignment.bottomLeft,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.7)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Text(
                expertName,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.3, curve: Curves.easeOut),

          const SizedBox(height: 20),

          // Profile Info Animated
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expertTitle,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.buttonBg,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 6),
                    Text('$rating',
                        style: GoogleFonts.poppins(color: Colors.white70)),
                    const SizedBox(width: 4),
                    Text('($ratingsCount reviews)',
                        style: GoogleFonts.poppins(
                            color: Colors.grey, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.place, color: Colors.redAccent, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(locationExpertise,
                          style: GoogleFonts.poppins(color: Colors.white70)),
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
                      child: Text(languages.join(', '),
                          style: GoogleFonts.poppins(color: Colors.white70)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: Colors.white24),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.map, color:AppColors.buttonBg, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(itinerary,
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
                    Text('Guided $totalTravelers+ travelers',
                        style: GoogleFonts.poppins(
                            color: Colors.white60, fontSize: 13)),
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
                  '${expertName.split(" ")[0]} is an experienced guide with deep knowledge of $locationExpertise. From planning day-wise itineraries to helping with local culture, food, and activities, ${expertName.split(" ")[0]} ensures every traveler gets a memorable experience.',
                  style: GoogleFonts.poppins(
                      color: Colors.white70, fontSize: 14),
                ),
              ],
            ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.3),
          ),
SizedBox(height: 80,),

          // Chat Button Animated
          SafeArea(
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
              child: ElevatedButton.icon(
                onPressed: () {
                  print("pavankkkkkkkkkkk");
                  // Get.toNamed(Routes.CHAT);
                  Get.to(LoginView());
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
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ).animate().fadeIn().slideX(begin: -0.2),
            ),
          ),
        ],
      ),
    );
  }
}
