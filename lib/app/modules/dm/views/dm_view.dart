import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:travel_app2/app/constants/app_color.dart';
import 'package:travel_app2/app/modules/chat/controllers/chat_controller.dart';
import 'package:travel_app2/app/modules/chat/views/chat_view.dart';
import 'package:travel_app2/app/modules/expert/views/expert_view.dart';

class UserModel {
  final String id;
  final String name;
  final String role;
  final String image; // network url

  UserModel({
    required this.id,
    required this.name,
    required this.role,
    required this.image,
  });
}

class DmView extends StatelessWidget {
  const DmView({Key? key, this.initialIndex = 0}) : super(key: key);

  final int initialIndex;

  // 🔹 Dummy current userId
  static const String currentUserId = "100";

  // 🔹 Dummy static users list
  static final List<UserModel> users = [
    UserModel(
      id: "201",
      name: "Dr. Smith",
      role: "expert",
      image: "https://i.pravatar.cc/150?img=3",
    ),
    UserModel(
      id: "202",
      name: "Chef Oliver",
      role: "expert",
      image: "https://i.pravatar.cc/150?img=4",
    ),
    UserModel(
      id: "301",
      name: "Alice Johnson",
      role: "user",
      image: "https://i.pravatar.cc/150?img=5",
    ),
    UserModel(
      id: "302",
      name: "Michael Brown",
      role: "user",
      image: "https://i.pravatar.cc/150?img=6",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final expertsList = users.where((u) => u.role == "expert").toList();
    final travellersList = users.where((u) => u.role == "user").toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.mainBg,
        appBar: AppBar(
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: GestureDetector(
                onTap: () {
                  Get.to(ExpertView()); // Navigate to Experts tab
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.buttonBg, // button background
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    "Experts",
                    style: GoogleFonts.openSans(
                      color: Colors.white, // text color
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
          backgroundColor: AppColors.mainBg,
          elevation: 0,
          title: Text(
            "Messages",
            style: GoogleFonts.openSans(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: AppColors.buttonBg,
            labelColor: AppColors.buttonBg,
            unselectedLabelColor: Colors.white70,
            labelStyle: GoogleFonts.openSans(fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: "Travellers"), // 🔹 Now on the left
              Tab(text: "Talk to Experts"), // 🔹 Now on the right
            ],
          ),
        ),
        body: Column(
          children: [
            // 🔍 Search bar
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF252525),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Search conversations...',
                  hintStyle: GoogleFonts.inter(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  icon: const Icon(Icons.search, color: AppColors.buttonBg),
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildUserList(travellersList, "No Travellers Found"),
                  _buildUserList(expertsList, "No Experts Found"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Common User List
  Widget _buildUserList(List<UserModel> userList, String emptyMsg) {
    if (userList.isEmpty) {
      return Center(
        child: Text(
          emptyMsg,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.grey.shade500,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: userList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final user = userList[index];
        return GestureDetector(
          onTap: () {
            // Get.put(ChatController()); // register controller
            // final chatId = "chat_${currentUserId}_${user.id}";
            // Get.to(() => ChatView(
            //       currentUser: currentUserId,
            //       otherUser: user.name,
            //       chatId: chatId,
            //     ));
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1F1F1F),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildAvatar(user.image),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: GoogleFonts.openSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Tap to chat",
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

  /// 🔹 Avatar with shimmer & fallback
  Widget _buildAvatar(String? imageUrl) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[600]!,
      child: CircleAvatar(
        radius: 24,
        child: ClipOval(
          child: (imageUrl != null && imageUrl.isNotEmpty)
              ? FadeInImage.assetNetwork(
                  placeholder: 'assets/images/default_user.png',
                  image: imageUrl,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  imageErrorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/default_user.png',
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    );
                  },
                )
              : Image.asset(
                  'assets/images/default_user.png',
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
        ),
      ),
    );
  }
}
