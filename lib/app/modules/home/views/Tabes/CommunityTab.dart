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
            return Center(
              child: Lottie.asset(
                'assets/animations/loading.json',
                height: 250,
                width: 500,
              ),
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

Widget _buildPostCard(Datum post, int index) {
  final isExpanded = controller.isExpanded[index] ?? false;
  const maxLines = 3;

  final textStyle = GoogleFonts.openSans(
    fontSize: 16,
    color: Colors.white,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  final textPainter = TextPainter(
    text: TextSpan(text: post.question, style: textStyle),
    maxLines: maxLines,
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: MediaQuery.of(context).size.width - 64);

  final exceedsMaxLines = textPainter.didExceedMaxLines;

  final commentController = TextEditingController();

  return SizedBox(
    height: MediaQuery.of(context).size.height * 0.75,
    child: Card(
      elevation: 6,
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
              /// 🔹 Header
              GestureDetector(
                onTap: () {
                  Get.toNamed(
                    Routes.USER_PROFILE,
                    arguments: {"user_id": post.userId},
                  );
                },
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: post.postuser?.image != null &&
                              post.postuser!.image.isNotEmpty
                          ? CachedNetworkImageProvider(post.postuser!.image)
                          : const AssetImage(
                                  'assets/images/default_user.png')
                              as ImageProvider,
                      backgroundColor: Colors.grey.shade800,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                post.postuser?.name ?? "Unknown",
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
                            '${post.location ?? " "} · ${post.createdAt != null ? "${post.createdAt!.year}-${post.createdAt!.month.toString().padLeft(2,'0')}-${post.createdAt!.day.toString().padLeft(2,'0')}" : ""}',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.more_horiz,
                          color: Colors.white70, size: 24),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              /// 🔹 Question
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.question,
                    maxLines: isExpanded ? null : maxLines,
                    overflow:
                        isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                    style: textStyle,
                  ),
                  if (exceedsMaxLines)
                    GestureDetector(
                      onTap: () => controller.toggleExpanded(index),
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

              /// 🔹 Image
              GestureDetector(
                onDoubleTap: () {
                  if (post.image.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            FullScreenImageGallery(images: post.image),
                      ),
                    );
                  }
                },
                child: post.image.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: post.image[0],
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey.shade800,
                            height: 200,
                            child: const Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.buttonBg),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 200,
                            color: Colors.grey.shade800,
                            child: const Icon(Icons.error, color: Colors.redAccent),
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
                          child: Text('No Images',
                              style: TextStyle(color: Colors.grey, fontSize: 16)),
                        ),
                      ),
              ),

              const SizedBox(height: 16),

              /// 🔹 Like & Comment Row (LinkedIn style)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => controller.toggleLike(post.id),
                        child: Icon(
                          post.isLiked == 1
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: post.isLiked == 1 ? Colors.red : Colors.white70,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (post.likesCount >= 0)
                        Text(
                          '${post.likesCount} Likes',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      // Focus comment field or scroll to comments
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.comment, color: Colors.white70, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          '${post.comments ?? 0} Comments',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// 🔹 Comment Input
              Row(
                children: [
                  GestureDetector(
                    onTap: (){
                       Get.toNamed(
                    Routes.USER_PROFILE,
                    arguments: {"user_id": post.userId},
                  );

                    },
                    child: CircleAvatar(
                      radius: 18,
                      backgroundImage: post.postuser?.image != null &&
                              post.postuser!.image.isNotEmpty
                          ? CachedNetworkImageProvider(post.postuser!.image)
                          : const AssetImage('assets/images/default_user.png')
                              as ImageProvider,
                      backgroundColor: Colors.grey.shade800,
                    ),
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
                        controller: commentController,
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Add a comment...',
                          hintStyle:
                              GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 14),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: AppColors.buttonBg, size: 24),
                    onPressed: () async {
                      final commentText = commentController.text.trim();
                      if (commentText.isEmpty) {
                        Get.snackbar("Error", "Comment cannot be empty",
                            backgroundColor: Colors.red, colorText: Colors.white);
                        return;
                      }

                      await controller.addComment(
                          postId: post.id, comment: commentText);
                      commentController.clear();
                    },
                  ),
                ],
              ),

              const SizedBox(height: 12),

              /// 🔹 Comments List with Like & Reply
          FutureBuilder(
  future: controller.fetchComments(post.id),
  builder: (context, snapshot) {
    final comments = controller.commentsMap[post.id] ?? [];

    if (snapshot.connectionState == ConnectionState.waiting &&
        comments.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: CircularProgressIndicator(color: AppColors.buttonBg),
        ),
      );
    }

    if (comments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          "No comments yet",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Comments",
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Column(
          children: comments.map((c) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Main comment
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: (){
                            print("User ID: ${c.user.id}");
                          Get.toNamed(
                            Routes.USER_PROFILE,
                            arguments: {"user_id": c.user.id},
                          );
                        },
                        child:CircleAvatar(
  radius: 16,
  backgroundColor: Colors.grey.shade300, // Insta jaisa background
  backgroundImage: c.user.image.isNotEmpty
      ? CachedNetworkImageProvider(c.user.image)
      : null, // agar image hai to show karo, nahi to initials
  child: c.user.image.isEmpty
      ? Text(
          c.user.name.isNotEmpty ? c.user.name[0].toUpperCase() : "?",
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black, // text color
          ),
        )
      : null,
),

                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.user.name,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              c.comment,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.grey.shade300,
                              ),
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {},
                                  child: Text(
                                    'Like',
                                    style: GoogleFonts.inter(
                                      color: AppColors.buttonBg,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                GestureDetector(
                                  onTap: () {},
                                  child: Text(
                                    'Reply',
                                    style: GoogleFonts.inter(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  /// Static Replies under each comment
                  Padding(
                    padding: const EdgeInsets.only(left: 50, top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Reply 1
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CircleAvatar(
                              radius: 14,
                              backgroundImage: AssetImage(
                                  'assets/images/default_user.png'),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "John Doe",
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    "I agree with this!",
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        /// Reply 2
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CircleAvatar(
                              radius: 14,
                              backgroundImage: AssetImage(
                                  'assets/images/default_user.png'),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Alice",
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    "Nice point 👍",
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  },
),

          
            ],
          ),
        ),
      ),
    ),
  );
}}


/// Full screen image gallery
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
        title: Text('${_currentPage + 1}/${widget.images.length}', style: GoogleFonts.inter(color: Colors.white)),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        onPageChanged: (index) => setState(() => _currentPage = index),
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 1.0,
            maxScale: 4.0,
            child: CachedNetworkImage(
              imageUrl: widget.images[index],
              fit: BoxFit.contain,
              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.red),
            ),
          );
        },
      ),
    );
  }
}
