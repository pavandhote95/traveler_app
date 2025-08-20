import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:travel_app2/app/constants/app_color.dart';
import 'package:travel_app2/app/modules/post_quesions/views/bottom_sheet_questions.dart';
import 'package:travel_app2/app/routes/app_pages.dart';
import '../../../../models/post_model.dart';
import '../../controllers/community_controller.dart';






class CommunityTab extends StatefulWidget {
  const CommunityTab({super.key});

  @override
  State<CommunityTab> createState() => _CommunityTabState();
}

class _CommunityTabState extends State<CommunityTab> with WidgetsBindingObserver {
  final controller = Get.put(CommunityController());
  bool isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    final newValue = bottomInset > 0.0;
    if (newValue != isKeyboardVisible) {
      setState(() {
        isKeyboardVisible = newValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBg,
      body: SafeArea(
        child: Obx(() {
          if (controller.filteredPosts.isEmpty) {
            return  Center(
              child:Lottie.asset(
                  'assets/animations/loading.json',

                   height:250,
                 width: 500,
                  // fit: BoxFit.contain, // Optional: how it scales
               )
            );
          }

          return Stack(
            children: [
              SwipeCards(
                matchEngine: controller.matchEngine,
                itemBuilder: (context, index) {
                  if (controller.filteredPosts.isEmpty) return const SizedBox();
                  final postIndex = index % controller.filteredPosts.length;
                  return _buildPostCard(controller.filteredPosts[postIndex], postIndex);
                },
                onStackFinished: () {
                  controller.reset();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'No more posts to show!',
                        style: GoogleFonts.inter(color: Colors.white),
                      ),
                      backgroundColor: AppColors.buttonBg,
                    ),
                  );
                },
                upSwipeAllowed: false,
                fillSpace: true,
              ),
              if (!isKeyboardVisible)
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: FloatingActionButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        builder: (context) => BottomSheetQuestionsView(),
                      );
                    },
                    backgroundColor: AppColors.buttonBg,
                    elevation: 4,
                    child: const Icon(Icons.add, color: Colors.black, size: 28),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }


Widget _buildPostCard(ApiPostModel post, int index) {
  final isExpanded = controller.isExpanded[index] ?? false;
  final textStyle = GoogleFonts.openSans(
    fontSize: 16,
    color: Colors.white,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
  const maxLines = 3;

  // Calculate if the text exceeds maxLines
  final textPainter = TextPainter(
    text: TextSpan(text: post.question, style: textStyle),
    maxLines: maxLines,
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: MediaQuery.of(context).size.width - 64);

  final exceedsMaxLines = textPainter.didExceedMaxLines;


  return SizedBox(
    height: MediaQuery.of(context).size.height * 0.75,
    child: Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      color: AppColors.centerright,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(
                        Routes.USER_PROFILE,
                        arguments: {
                          "name": "Kunal Patel",
                          "profileImage":
                              "https://randomuser.me/api/portraits/men/10.jpg",
                          "location": "Mumbai, India",
                          "joinedDate": "2021-06-12",
                          "bio": "Traveler | Explorer | Content Creator",
                          "followers": 1500,
                          "following": 300,
                          "posts": 120,
                        },
                      );
                    },
                    child: CircleAvatar(
                      radius: 24,
                      backgroundImage: const CachedNetworkImageProvider(
                        'https://randomuser.me/api/portraits/men/10.jpg',
                      ),
                      backgroundColor: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Get.toNamed(
                          Routes.USER_PROFILE,
                          arguments: {
                            "name": "Kunal Patel",
                            "profileImage":
                                "https://randomuser.me/api/portraits/men/10.jpg",
                            "location": post.location,
                            "joinedDate": post.createdAt.substring(0, 10),
                          },
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Kunal Patel',
                                style: GoogleFonts.openSans(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.verified,
                                size: 20,
                                color: AppColors.buttonBg,
                              ),
                            ],
                          ),
                          Text(
                            '${post.location} · ${post.createdAt.substring(0, 10)}',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.more_horiz,
                        color: Colors.white70, size: 24),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 🔹 Question
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.question,
                    maxLines: isExpanded ? null : maxLines,
                    overflow: isExpanded
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                    style: textStyle,
                  ),
                  if (exceedsMaxLines)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          controller.toggleExpanded(index);
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          isExpanded ? 'Show Less' : 'Show More',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.buttonBg,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // 🔹 Image
              GestureDetector(
                onDoubleTap: () {
                  if (post.images.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            FullScreenImageGallery(images: post.images),
                      ),
                    );
                  }
                },
                child: post.images.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: post.images[0],
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: double.infinity,
                            height: 200,
                            color: Colors.grey.shade800,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.buttonBg,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: double.infinity,
                            height: 200,
                            color: Colors.grey.shade800,
                            child:
                                const Icon(Icons.error, color: Colors.redAccent),
                          ),
                        ),
                      )
                    : Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade800,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            'No Images',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ),
                      ),
              ),

              const SizedBox(height: 16),

GestureDetector(
  onTap: () => controller.likePost(post.id.toString()),
  child: Row(
    children: [
      Icon(
        post.userReaction == 'like' 
            ? Icons.favorite   // 🔴 Filled heart if liked
            : Icons.favorite_border, // 🤍 Outline heart if not liked
        color: post.userReaction == 'like'
            ? Colors.red   // Red for liked
            : Colors.white70, // Greyish white for not liked
      ),
      const SizedBox(width: 8),
      Text(
        '${post.likes} Likes',
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
  
        ),
      ),
    ],
  ),
)
,
              const SizedBox(height: 16),

              // 🔹 Comments Section
              Column(
                children: [
                  _buildComment(
                    name: "Tanya Dutta",
                    text: "It's my dream to visit there someday!",
                    profileImage:
                        "https://randomuser.me/api/portraits/women/12.jpg",
                    likes: 14,
                    replies: [
                      {
                        "name": "Rohit Sharma",
                        "text": "Same here Tanya! Let's plan together 🚀",
                        "profileImage":
                            "https://randomuser.me/api/portraits/men/15.jpg",
                        "likes": 5,
                        "replies": [],
                      },
                    ],
                  ),
                  _buildComment(
                    name: "Aman Verma",
                    text: "Beautiful place 😍",
                    profileImage:
                        "https://randomuser.me/api/portraits/men/20.jpg",
                    likes: 7,
                    replies: [],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 🔹 Add Comment Field
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: const NetworkImage(
                        "https://randomuser.me/api/portraits/men/1.jpg"),
                    backgroundColor: Colors.grey.shade800,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF252525),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Add a comment...',
                          hintStyle: GoogleFonts.inter(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send,
                        color: AppColors.buttonBg, size: 24),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Comment sent')),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
Widget _buildComment({
  required String name,
  required String text,
  required String profileImage,
  required int likes,
  required List<dynamic> replies,
  String timeAgo = "2h", // default agar na ho
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔹 Profile Image
        CircleAvatar(
          radius: 18,
          backgroundImage: NetworkImage(profileImage),
          backgroundColor: Colors.grey.shade800,
        ),
        const SizedBox(width: 10),

        // 🔹 Comment body
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name + Comment
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "$name ",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    TextSpan(
                      text: text,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              // 🔹 Action Row: Like · Reply · Time · Likes count
              Row(
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      "Like",
                      style: GoogleFonts.inter(
                        color: Colors.grey.shade400,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      "Reply",
                      style: GoogleFonts.inter(
                        color: Colors.grey.shade400,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    timeAgo,
                    style: GoogleFonts.inter(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                  if (likes > 0) ...[
                    const SizedBox(width: 16),
                    Text(
                      "$likes Likes",
                      style: GoogleFonts.inter(
                        color: Colors.grey.shade400,
                        fontSize: 13,
                      ),
                    ),
                  ]
                ],
              ),

              // 🔹 Nested replies (indent)
              if (replies.isNotEmpty) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(left: 36),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: replies.map((reply) {
                      final r = reply as Map<String, dynamic>;
                      return _buildComment(
                        name: r["name"] ?? "",
                        text: r["text"] ?? "",
                        profileImage: r["profileImage"] ?? "",
                        likes: r["likes"] ?? 0,
                        replies: r["replies"] ?? [],
                        timeAgo: r["timeAgo"] ?? "1h",
                      );
                    }).toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}


}

// Full Screen Image Gallery Widget
class FullScreenImageGallery extends StatefulWidget {
  final List<String> images;

  const FullScreenImageGallery({super.key, required this.images});

  @override
  State<FullScreenImageGallery> createState() => _FullScreenImageGalleryState();
}

class _FullScreenImageGalleryState extends State<FullScreenImageGallery> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${_currentPage + 1}/${widget.images.length}',
          style: GoogleFonts.inter(color: Colors.white),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 1.0,
            maxScale: 4.0,
            child: CachedNetworkImage(
              imageUrl: widget.images[index],
              fit: BoxFit.contain,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(color: AppColors.buttonBg),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.red),
            ),
          );
        },
      ),
    );
  }
  
}