import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:travel_app2/app/constants/app_color.dart';
import 'package:travel_app2/app/modules/experts_profile/views/experts_profile_view.dart';
import '../controllers/expert_controller.dart';

// ignore: must_be_immutable
class ExpertView extends GetView<ExpertController> {
 ExpertController controller = Get.put(ExpertController());

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount = screenWidth < 600 ? 2 : 3;
    final double childAspectRatio = screenWidth < 600 ? 0.65 : 0.75;

    return Scaffold(
      backgroundColor: AppColors.mainBg,
      appBar: AppBar(
        title: const Text('Experts'),
        backgroundColor: AppColors.appbar,
        foregroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.experts.isEmpty) {
          return const Center(
            child: Text("No Experts Found", style: TextStyle(color: Colors.white)),
          );
        }

        return GridView.builder(
          padding: EdgeInsets.all(screenWidth * 0.04),
          itemCount: controller.experts.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: screenWidth * 0.04,
            crossAxisSpacing: screenWidth * 0.04,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (context, index) {
            final expert = controller.experts[index];
            return ExpertCard(
              expert: expert,
              screenWidth: screenWidth,
            );
          },
        );
      }),
    );
  }
}

class ExpertCard extends StatelessWidget {
  final Map<String, dynamic> expert;
  final double screenWidth;

  const ExpertCard({
    super.key,
    required this.expert,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => ExpertsProfileView(
              expertId: expert['id'], // ✅ Pass ID so profile fetches full details
            
            ));
      },
      child: Card(
        color: AppColors.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.buttonBg, width: 0.1),
        ),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.03),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: screenWidth * 0.08,
                backgroundImage: NetworkImage(expert['image'] ?? ""),
              ),
              SizedBox(height: screenWidth * 0.03),
              Text(
                expert['title'] ?? "",
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: screenWidth * 0.035,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                expert['sub_title'] ?? "",
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: screenWidth * 0.03,
                  color: Colors.white70,
                ),
              ),
              Text(
                expert['location'] ?? "",
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: screenWidth * 0.028,
                  color: Colors.white54,
                ),
              ),
              SizedBox(height: screenWidth * 0.01),
              Text(
                (expert['language'] as List? ?? [])
                    .map((lang) => lang['value'].toString())
                    .join(', '),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: screenWidth * 0.028,
                  color: Colors.white54,
                ),
              ),
              SizedBox(height: screenWidth * 0.015),
              Text(
                "₹${expert['price']}/day",
                style: GoogleFonts.poppins(
                  fontSize: screenWidth * 0.032,
                  fontWeight: FontWeight.bold,
                  color: Colors.tealAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
