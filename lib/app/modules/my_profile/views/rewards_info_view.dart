// rewards_info_view.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/app_color.dart';

class RewardsInfoView extends StatelessWidget {
  const RewardsInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBg,
      appBar: AppBar(
        backgroundColor: AppColors.appbar,
        elevation: 0,
        title: Text(
          "Rewards & Verification",
          style: GoogleFonts.poppins(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _infoCard(
              icon: "⭐",
              title: "How Points Work",
              items: [
                "Post a question or travel tip → +15 points",
                "Reply to a question → no points",
                "If someone likes your reply → +10 points",
              ],
            ),
            const SizedBox(height: 16),
            _infoCard(
              icon: "🎖",
              title: "Benefits of a Verified Account",
              items: [
                "Blue Tick Badge – stand out as a trusted traveler",
                "Priority Replies – your answers show higher",
                "Profile Boost – highlighted profile for more followers",
                "Exclusive Perks – early access to features & events",
                "Credibility – answers trusted more (great for influencers)",
                "Monetization Gateway (future) – earn by creating itineraries",
              ],
              numbered: true,
            ),
            const SizedBox(height: 16),
            _infoCard(
              icon: "🏅",
              title: "Get Verified",
              items: [
                "Collect 1000 points",
                "Apply for a Verified Account (valid 1 year)",
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
              ),
              child: Text(
                "👉 Ask more, help more, get liked, and become Verified!",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({
    required String icon,
    required String title,
    required List<String> items,
    bool numbered = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.centerright, AppColors.centerleft],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final text = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    numbered ? "$index) " : "• ",
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  Expanded(
                    child: Text(
                      text,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
