import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:swipe_cards/swipe_cards.dart';
import 'package:travel_app2/app/services/api_service.dart';
import '../../../models/post_model.dart';

class CommunityController extends GetxController {
  RxList<ApiPostModel> allPosts = <ApiPostModel>[].obs;
  RxList<ApiPostModel> locationPosts = <ApiPostModel>[].obs;
  RxList<ApiPostModel> filteredPosts = <ApiPostModel>[].obs;
  RxInt currentIndex = 0.obs;
  RxBool isTravelingMode = false.obs;
  RxMap<int, bool> isExpanded = <int, bool>{}.obs;
  late MatchEngine matchEngine;
  final ApiService apiService = Get.find<ApiService>();
  final RxString searchQuery = ''.obs;
  final GetStorage box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    initializeSwipeEngine();
    fetchPosts();
  }

  /// ✅ Only Like toggle (Instagram style)
  /// ✅ Only Like toggle (Instagram style)
  Future<void> toggleLike(String postId) async {
    const String baseUrl = 'https://kotiboxglobaltech.com/travel_app/api';
    final url = Uri.parse('$baseUrl/post/react');
    final token = box.read('token');

    if (token == null) {
      Get.snackbar("Auth Error", "You must login first",
          backgroundColor: Colors.red, colorText: Colors.white);
      debugPrint("❌ No token found, user not logged in");
      return;
    }

    try {
      final index = allPosts.indexWhere((p) => p.id.toString() == postId);
      if (index == -1) {
        debugPrint("⚠️ Post with id $postId not found");
        return;
      }

      final post = allPosts[index];
      final alreadyLiked = post.isLiked;
      final newReaction = alreadyLiked ? "remove" : "like";

      final updatedPost = alreadyLiked
          ? post.copyWith(
        isLiked: false,
        likesCount: post.likesCount > 0 ? post.likesCount - 1 : 0,
      )
          : post.copyWith(
        isLiked: true,
        likesCount: post.likesCount + 1,
      );

      final originalPost = post;

      // ✅ Optimistic update
      allPosts[index] = updatedPost;
      updateFilteredPosts();

      debugPrint(
          "🔄 Optimistic update -> PostID: $postId | Reaction: $newReaction | Likes: ${updatedPost.likesCount}");

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'post_id': postId,
          'type': newReaction,
        }),
      );

      debugPrint("📩 API Response [${response.statusCode}] ${response.body}");

      if (response.statusCode != 200 && response.statusCode != 201) {
        // rollback if API fails
        allPosts[index] = originalPost;
        updateFilteredPosts();
        debugPrint("⏪ Rollback -> API failed, restored original state");
      } else {
        debugPrint("✅ Reaction success -> PostID: $postId, Status: $newReaction");
      }
    } catch (e) {
      debugPrint("❌ Toggle like failed: $e");
    }
  }

  Future<void> fetchPosts() async {
    try {
      final data = await apiService.fetchPosts();
      if (data['status'] == true && data['data'] is List) {
        allPosts.value =
            (data['data'] as List).map((e) => ApiPostModel.fromJson(e)).toList();
        updateFilteredPosts();
      }
    } catch (e) {
      debugPrint('❌ Error in fetchPosts: $e');
    }
  }

  Future<void> fetchPostsByLocation(String location) async {
    try {
      final data = await apiService.fetchPostsByLocation(location);

      if (data['status'] == true && data['data'] is List) {
        locationPosts.value =
            (data['data'] as List).map((e) => ApiPostModel.fromJson(e)).toList();
        fetchPosts();
      }
    } catch (e) {
      debugPrint('❌ Error in fetchPostsByLocation: $e');
    }
  }

  void setTravelingMode(bool isTraveling) {
    isTravelingMode.value = isTraveling;
    updateFilteredPosts();
  }

  void updateFilteredPosts() {
    final basePosts = isTravelingMode.value ? locationPosts : allPosts;
    if (searchQuery.value.isEmpty) {
      filteredPosts.assignAll(basePosts);
    } else {
      final keyword = searchQuery.value.toLowerCase();
      filteredPosts.assignAll(basePosts.where((post) =>
      post.question.toLowerCase().contains(keyword) ||
          post.location.toLowerCase().contains(keyword)));
    }
    initializeSwipeEngine();
  }

  void searchPosts(String keyword) {
    searchQuery.value = keyword;
    updateFilteredPosts();
  }

  void initializeSwipeEngine() {
    final swipeItems = filteredPosts.isEmpty
        ? <SwipeItem>[]
        : List<SwipeItem>.generate(
      filteredPosts.length * 100,
          (index) => SwipeItem(
        content: filteredPosts[index % filteredPosts.length],
        likeAction: () => incrementIndex(index % filteredPosts.length),
        nopeAction: () => incrementIndex(index % filteredPosts.length),
      ),
    );
    matchEngine = MatchEngine(swipeItems: swipeItems);
    update();
  }

  void incrementIndex(int index) {
    if (filteredPosts.isNotEmpty) {
      currentIndex.value = (index + 1) % filteredPosts.length;
    }
    update();
  }

  void reset() {
    currentIndex.value = 0;
    fetchPosts();
    update();
  }

  void toggleExpanded(int index) {
    isExpanded[index] = !(isExpanded[index] ?? false);
    update();
  }
}
