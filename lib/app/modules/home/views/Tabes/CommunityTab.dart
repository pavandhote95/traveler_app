import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:travel_app2/app/constants/app_color.dart';
import 'package:travel_app2/app/modules/my_profile/controllers/my_profile_controller.dart';
import 'package:travel_app2/app/modules/post_quesions/views/bottom_sheet_questions.dart';
import 'package:travel_app2/app/routes/app_pages.dart';
import '../../../../models/post_model.dart';
import '../../controllers/community_controller.dart';

class CommunityTab extends StatefulWidget {
  const CommunityTab({super.key});

  @override
  State<CommunityTab> createState() => _CommunityTabState();
}

class _CommunityTabState extends State<CommunityTab>
    with WidgetsBindingObserver {
  final controller = Get.put(CommunityController());
  final profileController = Get.find<MyProfileController>();
  bool isKeyboardVisible = false;

  /// Keep one TextEditingController per post to avoid leaks
  final Map<int, TextEditingController> _commentControllers = {};
  final box = GetStorage();
  int get userId => box.read('userId') ?? 0;

  TextEditingController _getControllerForPost(int postId) {
    return _commentControllers.putIfAbsent(
      postId,
      () => TextEditingController(),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    for (final c in _commentControllers.values) {
      c.dispose();
    }
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
                  final post = controller.filteredPosts[postIndex];
                  return _buildPostCard(post, postIndex);
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
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
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
    final commentController = _getControllerForPost(post.id);

    final textStyle = GoogleFonts.openSans(
      fontSize: 16,
      color: Colors.white,
      fontWeight: FontWeight.w400,
      height: 1.4,
    );

    // Load comments if not yet loaded
    if (!controller.commentsMap.containsKey(post.id) &&
        (controller.commentsLoading[post.id] != true)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.fetchComments(post.id);
      });
    }

     

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
        color: AppColors.centerright,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Header
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
                        backgroundColor: Colors.grey.shade800,
                        backgroundImage: post.postuser?.image.isNotEmpty == true
                            ? CachedNetworkImageProvider(post.postuser!.image)
                            : null,
                        child: (post.postuser?.image.isEmpty ?? true)
                            ? const Icon(Icons.person, size: 28, color: Colors.white70)
                            : null,
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
                              '${post.location ?? " "} · ${post.createdAt != null ? "${post.createdAt!.year}-${post.createdAt!.month.toString().padLeft(2, '0')}-${post.createdAt!.day.toString().padLeft(2, '0')}" : ""}',
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
                        icon: const Icon(
                          Icons.more_horiz,
                          color: Colors.white70,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                /// Question
             
                /// Question
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

                /// Image
                post.image.isNotEmpty
                    ? GestureDetector(
                        onDoubleTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FullScreenImageGallery(images: post.image),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: post.image[0],
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
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

                const SizedBox(height: 16),

                /// Like & Comment Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => controller.toggleLike(post.id),
                          child: Icon(
                            post.isLiked == 1 ? Icons.favorite : Icons.favorite_border,
                            color: post.isLiked == 1 ? Colors.red : Colors.white70,
                          ),
                        ),
                        const SizedBox(width: 8),
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
                    Row(
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
                  ],
                ),

                const SizedBox(height: 16),

                /// Comment Input
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                      Get.toNamed(
  Routes.USER_PROFILE,
  arguments: {"user_id": userId},
);
                      },
                      child: Obx(() {
                        if (profileController.profileImage.value.isEmpty &&
                            profileController.isLoading.value) {
                          return _buildShimmerAvatar();
                        }
                        return CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white24,
                          child: profileController.profileImage.value.isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    profileController.profileImage.value,
                                    width: 52,
                                    height: 52,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.person, size: 28, color: Colors.white70),
                                  ),
                                )
                              : const Icon(Icons.person, size: 28, color: Colors.white70),
                        );
                      }),
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
                      onPressed: () async {
                        final commentText = commentController.text.trim();
                        if (commentText.isEmpty) {
                          Get.snackbar(
                            "Error",
                            "Comment cannot be empty",
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                          return;
                        }
                        await controller.addComment(postId: post.id, comment: commentText);
                        commentController.clear();
                        FocusScope.of(context).unfocus();
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// Comments Section (with like & reply)
                Obx(() {
                  final loading = controller.commentsLoading[post.id] ?? false;
                  final comments = controller.commentsMap[post.id] ?? [];

                  if (loading && comments.isEmpty) {
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
                      child: Text("No comments yet", style: TextStyle(color: Colors.grey)),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: comments.map((c) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Comment Row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    // Handle avatar tap
                                       Get.toNamed(
                                      Routes.USER_PROFILE,
                                      arguments: {"user_id": c.user.id},
                                    );
                                  },
                                  child: CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Colors.grey.shade800,
                                    backgroundImage:
                                        c.user.image.isNotEmpty ? CachedNetworkImageProvider(c.user.image) : null,
                                    child: c.user.image.isEmpty
                                        ? const Icon(Icons.person, size: 20, color: Colors.white70)
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          // Handle username tap
                                             Get.toNamed(
                                            Routes.USER_PROFILE,
                                            arguments: {"user_id": c.user.id},
                                          );
                                        },
                                        child: Text(c.user.name,
                                            style: GoogleFonts.inter(
                                                fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                                      ),
                                      Text(c.comment,
                                          style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade300)),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              controller.toggleCommentLike(
                                                  postId: post.id, commentId: c.id);
                                            },
                                            child: Row(
                                              children: [
                                                Icon(
                                                  c.userLiked == 1
                                                      ? Icons.thumb_up
                                                      : Icons.thumb_up_outlined,
                                                  size: 16,
                                                  color: c.userLiked == 1
                                                      ? AppColors.buttonBg
                                                      : Colors.white70,
                                                ),
                                                const SizedBox(width: 4),
                                                Text("${c.likesCount} Likes",
                                                    style: GoogleFonts.inter(
                                                        color: Colors.white70, fontSize: 12)),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          GestureDetector(
                                            onTap: () {
                                              Get.bottomSheet(
                                                _buildReplyBottomSheet(
                                                    context, post.id, c.id, c.user.name),
                                              );
                                            },
                                            child: Text('Reply',
                                                style: GoogleFonts.inter(
                                                    color: Colors.white70,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            /// Replies
                        /// Replies
if (c.replies.isNotEmpty)
  Padding(
    padding: const EdgeInsets.only(left: 40, top: 8),
    child: Column(
      children: c.replies.map((r) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: Colors.grey.shade800,
                backgroundImage: r.user.image.isNotEmpty
                    ? CachedNetworkImageProvider(r.user.image)
                    : null,
                child: r.user.image.isEmpty
                    ? const Icon(Icons.person, size: 20, color: Colors.white70)
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.user.name,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      r.comment,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.grey.shade300,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            controller.toggleCommentLike(
                              postId: post.id,
                              commentId: r.id, // Use reply ID
                            );
                          },
                          child: Row(
                            children: [
                              Icon(
                                r.userLiked == 1
                                    ? Icons.thumb_up
                                    : Icons.thumb_up_outlined,
                                size: 14,
                                color: r.userLiked == 1
                                    ? AppColors.buttonBg
                                    : Colors.white70,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${r.likesCount} Likes",
                                style: GoogleFonts.inter(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () {
                            Get.bottomSheet(
                              _buildReplyBottomSheet(
                                context,
                                post.id,
                                c.id,
                                r.user.name,
                              ),
                            );
                          },
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
        );
      }).toList(),
    ),
  ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerAvatar() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[600]!,
      child: const CircleAvatar(
        radius: 26,
        backgroundColor: Colors.grey,
      ),
    );
  }

Widget _buildReplyBottomSheet(
    BuildContext context, int postId, int parentId, String userName) {
  final replyController = TextEditingController(text: '@$userName ');

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: const BoxDecoration(
      color: AppColors.centerright,
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Reply to $userName",
          style: GoogleFonts.inter(
              fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: replyController,
          autofocus: true,
          style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
          maxLines: 3,
          decoration: InputDecoration(
            hintText: "Write your reply...",
            hintStyle: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.buttonBg), // Changed to yellow
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.buttonBg), // Yellow for enabled state
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.buttonBg, width: 2), // Yellow for focused state
            ),
            filled: true,
            fillColor: const Color(0xFF252525),
          ),
          onSubmitted: (text) {
            if (text.trim().isNotEmpty && text.trim() != '@$userName') {
              controller.replyToComment(
                  postId: postId, parentId: parentId, reply: text.trim());
              replyController.clear();
              Get.back();
            } else {
              Get.snackbar(
                "Error",
                "Reply cannot be empty",
                backgroundColor: Colors.red,
                colorText: AppColors.buttonBg,
              );
            }
          },
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonBg,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: () {
            final replyText = replyController.text.trim();
            if (replyText.isNotEmpty && replyText != '@$userName') {
              controller.replyToComment(
                  postId: postId, parentId: parentId, reply: replyText);
              replyController.clear();
              Get.back();
            } else {
              Get.snackbar(
                "Error",
                "Reply cannot be empty",
                backgroundColor: Colors.red,
                colorText: AppColors.buttonBg,
              );
            }
          },
          child: Text(
            "Post Reply",
            style: GoogleFonts.inter(
                color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
      ],
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
        title: Text('${_currentPage + 1}/${widget.images.length}',
            style: GoogleFonts.inter(color: Colors.white)),
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
              placeholder: (context, url) =>
                  const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.error, color: Colors.red),
            ),
          );
        },
      ),
    );
  }
}
