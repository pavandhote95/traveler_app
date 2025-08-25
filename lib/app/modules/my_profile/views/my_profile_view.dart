// my_profile_view.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app2/app/constants/constants.dart';
import 'package:travel_app2/app/constants/app_color.dart';
import 'package:travel_app2/app/constants/custom_button.dart';
import '../controllers/my_profile_controller.dart';
import '../../edit_profile/views/edit_profile_view.dart';

class MyProfileView extends GetView<MyProfileController> {
  MyProfileView({super.key});
  final MyProfileController controller = Get.put(MyProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBg,
      drawer: _buildDrawer(),
      appBar: AppBar(
        backgroundColor: AppColors.appbar,
        elevation: 0,
        title: Text(
          "My Profile",
          style: GoogleFonts.openSans(color: AppColors.titleText, fontSize: 20),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTopHeader(),
              _buildPromoCard(),
              const SizedBox(height: 12),
              _buildUserPosts(),
              _buildLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }
    Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppColors.mainBg,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: AppColors.appbar),
            child: Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Obx(() => CircleAvatar(
  radius: 35,
  backgroundImage: controller.profileImage.value != ''
      ? NetworkImage(controller.profileImage.value)
      : const NetworkImage('https://randomuser.me/api/portraits/men/11.jpg'),
)),
                    const SizedBox(height: 10),
                    Text(
                      controller.username.value != ''
                          ? controller.username.value
                          : "Guest",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      controller.role.value != ''
                          ? controller.role.value
                          : "Traveler",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                )),
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.white),
            title: Text("Settings", style: GoogleFonts.poppins(color: Colors.white)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.verified_user, color: Colors.white),
            title: Text("My Badges", style: GoogleFonts.poppins(color: Colors.white)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.help_outline, color: Colors.white),
            title: Text("Help & Support", style: GoogleFonts.poppins(color: Colors.white)),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildTopHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Obx(() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
          Obx(() => CircleAvatar(
  radius: 35,
  backgroundImage: controller.profileImage.value != ''
      ? NetworkImage(controller.profileImage.value)
      : const NetworkImage('https://randomuser.me/api/portraits/men/11.jpg'),
)),
              const SizedBox(width: 24),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatColumn("Posts", controller.totalPosts.value),
                    _buildStatColumn(
                      "Points",
                      (controller.totalPosts.value * 50) + (controller.totalAnswers.value * 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            controller.username.value != '' ? controller.username.value : "Guest",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            controller.role.value != '' ? controller.role.value : "Traveler",
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
          onPressed: () async {
    await Get.to(() =>EditProfileView());
    // 🔹 ProfileView se wapas aane ke baad refresh karega
    controller.fetchProfile();
  },
              icon: const Icon(Icons.edit, size: 18, color: Colors.white),
              label: Text(
                "Edit Profile",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                backgroundColor: Colors.white.withOpacity(0.08),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          )
        ],
      )),
    );
  }

  Widget _buildUserPosts() {
    return Obx(() {
      if (controller.userPosts.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "No posts yet.",
            style: GoogleFonts.poppins(color: Colors.grey.shade400),
          ),
        );
      }

      return ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: controller.userPosts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final post = controller.userPosts[index];
          String? mainImage = post['image'];
          List imagesList = post['images'] ?? [];

          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post['title'] ?? "Untitled",
                    style: GoogleFonts.poppins(
                        color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 6),
                Text(post['description'] ?? "",
                    style: GoogleFonts.poppins(color: Colors.grey.shade300, fontSize: 13)),
                const SizedBox(height: 8),
                if (mainImage != null && mainImage.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: baseUrl + mainImage,
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                const SizedBox(height: 8),
                if (imagesList.isNotEmpty)
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: imagesList.length,
                      itemBuilder: (context, i) {
                        final img = imagesList[i]['image'];
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: CachedNetworkImage(
                            imageUrl: baseUrl + img,
                            placeholder: (context, url) => const CircularProgressIndicator(),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildStatColumn(String label, int value) => SizedBox(
        width: 80,
        height: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("$value",
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400)),
          ],
        ),
      );

  Widget _buildPromoCard() => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.card_giftcard_rounded, color: Colors.redAccent),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Get rewards by completing your travel profile.",
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
              ),
            ),
          ],
        ),
      );

  Widget _buildLogoutButton() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: SizedBox(
          width: double.infinity,
          child: CustomButton(
            isLoading: controller.isLoading,
            onPressed: controller.logoutUser,
            text: 'Logout',
            textColor: Colors.white,
          ),
        ),
      );
}
