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

    // Calculate if the text exceeds maxLines using TextPainter
    final textPainter = TextPainter(
      text: TextSpan(text: post.question, style: textStyle),
      
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: MediaQuery.of(context).size.width - 64); // Account for padding

    final exceedsMaxLines = textPainter.didExceedMaxLines;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.70,
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
                // Header
                Row(
                  children: [
                    // 👉 Avatar Click
                    GestureDetector(
                      onTap: () {
                        Get.toNamed(
                          Routes.USER_PROFILE,
                          arguments: {

                            "name": "Kunal Patel",
                            "profileImage": "https://randomuser.me/api/portraits/men/10.jpg",
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

                    // 👉 Name Click
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Get.toNamed(
                            Routes.USER_PROFILE,
                            arguments: {
                              "name": "Kunal Patel",
                              "profileImage": "https://randomuser.me/api/portraits/men/10.jpg",
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
                      icon: const Icon(Icons.more_horiz, color: Colors.white70, size: 24),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                // Question
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.question,
                      maxLines: isExpanded ? null : maxLines,
                      overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
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

                // Single Image with Double Tap
                GestureDetector(
                  onDoubleTap: () {
                    if (post.images.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenImageGallery(images: post.images),
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
                        child: const Icon(Icons.error, color: Colors.red),
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

                // Likes/Reply/Share
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Row(
                        children: [
                          Image.asset('assets/icons/fav.png', width: 24, height: 24),
                          const SizedBox(width: 8),
                          Text(
                            '124 Likes',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {},
                      child: Row(
                        children: [
                          Image.asset('assets/icons/message.png', width: 24, height: 24),
                          const SizedBox(width: 8),
                          Text(
                            'Reply',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.buttonBg,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.share_outlined, color: AppColors.buttonBg, size: 24),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Hardcoded Comment
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: const NetworkImage('https://randomuser.me/api/portraits/men/12.jpg'),
                      backgroundColor: Colors.grey.shade800,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF252525),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tanya Dutta',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "It's my dream to visit there someday!",
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Add Comment
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundImage: const NetworkImage("https://randomuser.me/api/portraits/men/1.jpg"),
                      backgroundColor: Colors.grey.shade800,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical:0),
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
                      icon: const Icon(Icons.send, color: AppColors.buttonBg, size: 24),
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