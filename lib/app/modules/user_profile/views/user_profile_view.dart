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
    final String email = args['email'] ?? "No email provided";
    final String phone = args['phone'] ?? "No phone provided";
    final String travelInterest = args['travelInterest'] ?? "Not specified";
    final String visitedPlaces = args['visitedPlaces'] ?? "Not specified";
    final String dreamDestination = args['dreamDestination'] ?? "Not specified";
    final String language = args['language'] ?? "Not specified";
    final String travelType = args['travelType'] ?? "Not specified";
    final String travelMode = args['travelMode'] ?? "Not specified";

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Profile Image and Basic Info
            Center(
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
                  Text(
                    location,
                    style: GoogleFonts.inter(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Joined: $joinedDate",
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 🔹 Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStat("Posts", posts),
                _buildStat("Answers", answers),
                _buildStat("Points", points),
              ],
            ),
            const Divider(color: Colors.grey, height: 32),

            // 🔹 Personal Information Card
            _buildCard(
              title: "Personal Information",
              children: [
                _buildInfoRow("Bio", bio),
                _buildInfoRow("Email", email),
                _buildInfoRow("Phone", phone),
              ],
            ),
            const SizedBox(height: 20),

            // 🔹 Travel Details Card
            _buildCard(
              title: "Travel Details",
              children: [
                _buildInfoRow("Location", location),
                _buildInfoRow("Travel Interest", travelInterest),
                _buildInfoRow("Visited Places", visitedPlaces),
                _buildInfoRow("Dream Destination", dreamDestination),
                _buildInfoRow("Language", language),
              ],
            ),
            const SizedBox(height: 20),

            // 🔹 Travel Preferences Card
            _buildCard(
              title: "Travel Preferences",
              children: [
                _buildInfoRow("Travel Type", travelType),
                _buildInfoRow("Travel Mode", travelMode),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Helper widget for stat display
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

  // 🔹 Helper widget for card section
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
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  // 🔹 Helper widget for info row
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}