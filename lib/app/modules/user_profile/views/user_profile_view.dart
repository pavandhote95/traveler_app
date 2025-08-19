import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../constants/app_color.dart';
import '../controllers/user_profile_controller.dart';

class UserProfileView extends StatelessWidget {
  const UserProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔹 Get arguments from navigation
    final args = Get.arguments as Map<String, dynamic>;

    final String name = args['name'] ?? "N/A";
    final String profileImage =
        args['profileImage'] ?? "https://via.placeholder.com/150";
    final String location = args['location'] ?? "Unknown";
    final String joinedDate = args['joinedDate'] ?? "Unknown";
    final String bio = args['bio'] ?? "No bio available.";

    // 🔹 Updated stats
    final int posts = args['posts'] ?? 0;
    final int answers = args['answers'] ?? 0;
    final int points = args['points'] ?? 0;

    return Scaffold(
      backgroundColor: AppColors.mainBg,
      appBar: AppBar(
        backgroundColor: AppColors.appbar,
        title: Text(name, style: GoogleFonts.openSans(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: CachedNetworkImageProvider(profileImage),
              backgroundColor: Colors.grey.shade800,
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: GoogleFonts.openSans(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(location,
                style: GoogleFonts.inter(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 8),
            Text("Joined: $joinedDate",
                style: GoogleFonts.inter(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 20),

            // 🔹 Updated Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStat("Posts", posts),
                _buildStat("Answers", answers),
                _buildStat("Points", points),
              ],
            ),

            const Divider(color: Colors.grey, height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "About $name",
                style: GoogleFonts.openSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              bio,
              style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Helper widget
  Widget _buildStat(String label, int value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: GoogleFonts.openSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }
}
