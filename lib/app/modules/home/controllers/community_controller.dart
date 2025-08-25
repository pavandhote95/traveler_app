import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

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
Future<void> likePost(String postId) async {
  const String baseUrl = 'https://kotiboxglobaltech.com/travel_app/api';
  final url = Uri.parse('$baseUrl/post/react');
  final token = box.read('token');

  if (token == null) {
    Get.snackbar(
      "Auth Error", 
      "You must login first",
      backgroundColor: Colors.red, 
      colorText: Colors.white,
    );
    return;
  }

  try {
    // Find the post index
    final index = allPosts.indexWhere((p) => p.id.toString() == postId);
    if (index == -1) return;

    final post = allPosts[index];

    // Toggle like
    final bool isLiked = post.userReaction == "like";
    final String newReaction = isLiked ? "" : "like";

    // Prepare optimistic updated post
    final updatedPost = isLiked
        ? post.copyWith(userReaction: "", likes: (post.likes > 0 ? post.likes - 1 : 0))
        : post.copyWith(userReaction: "like", likes: post.likes + 1);

    // Save original post in case we need to rollback
    final originalPost = post;

    // ✅ Optimistic update
    allPosts[index] = updatedPost;
    updateFilteredPosts();

    // 🔹 API call
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'post_id': postId,
        'type': newReaction.isEmpty ? "dislike" : "like",
      }),
    );

    // Rollback if API fails
    if (!(response.statusCode == 200 || response.statusCode == 201)) {
      debugPrint("❌ API failed: ${response.body}");
      allPosts[index] = originalPost; // rollback
      updateFilteredPosts();
    }

  } catch (e) {
    debugPrint("❌ Like failed: $e");
  }
}


  Future<void> fetchPosts() async {
    try {
      final data = await apiService.fetchPosts();
      if (data['status'] == true && data['data'] is List) {
        allPosts.value = (data['data'] as List)
            .map((e) => ApiPostModel.fromJson(e))
            .toList();
        updateFilteredPosts();
      } else {
        throw Exception('Invalid API response format');
      }
    } catch (e) {
      debugPrint('❌ Error in fetchPosts: $e');
      Get.snackbar('Error', 'Failed to load posts: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> fetchPostsByLocation(String location) async {
    try {
      final data = await apiService.fetchPostsByLocation(location);

      if (data['status'] == true && data['data'] is List) {
        locationPosts.value = (data['data'] as List)
            .map((e) => ApiPostModel.fromJson(e))
            .toList();

        fetchPosts();

        // 🔹 Show message if no posts for the location
        if (locationPosts.isEmpty) {
          Get.snackbar(
            'No Posts Found',
            'No posts available for "$location"',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 3),
          );
        }
      } else {
        throw Exception('Invalid API response format for location posts');
      }
    } catch (e) {
      debugPrint('❌ Error in fetchPostsByLocation: $e');
      Get.snackbar(
        'Error',
        'Failed to load location posts: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
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
