import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app2/app/modules/travellers/controllers/travellers_controller.dart';
import 'package:travel_app2/app/modules/travellers/views/all_expert_chat_model.dart';

class TravellersView extends StatelessWidget {
  TravellersView({Key? key}) : super(key: key);

  final TravellersController controller = Get.put(TravellersController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      return _buildTravellerList(controller.travellers);
    });
  }

  Widget _buildTravellerList(List<UserModel2> travellers) {
    if (travellers.isEmpty) {
      return Center(
        child: Text(
          "No Travellers Found",
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.grey.shade500,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: travellers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final traveller = travellers[index];

        return GestureDetector(
          onTap: () {
            print("Tapped on ${traveller.name}");
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1F1F1F),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildAvatar(traveller.profile, traveller.name), // <-- use imageUrl
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        traveller.name,
                        style: GoogleFonts.openSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        traveller.lastMessage ?? "Tap to chat",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.grey),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatar(String? imageUrl, String name) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.network(
          imageUrl,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _initialsAvatar(name); // fallback if image fails
          },
        ),
      );
    } else {
      return _initialsAvatar(name);
    }
  }

  Widget _initialsAvatar(String name) {
    final initials = (name.isNotEmpty ? name[0] : "?").toUpperCase();
    final bgColors = [
      Colors.redAccent,
      Colors.blueAccent,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];
    final colorIndex = name.hashCode % bgColors.length;

    return CircleAvatar(
      radius: 24,
      backgroundColor: bgColors[colorIndex],
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}
