import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:swipe_cards/swipe_cards.dart';
import 'package:travel_app2/app/modules/home/views/Tabes/comment_model.dart';
import 'package:travel_app2/app/services/api_service.dart';
import '../../../models/post_model.dart';

class CommunityController extends GetxController {
  RxList<Datum> allPosts = <Datum>[].obs;
  RxList<Datum> locationPosts = <Datum>[].obs;
  RxList<Datum> filteredPosts = <Datum>[].obs;
  RxInt currentIndex = 0.obs;
  RxBool isTravelingMode = false.obs;
  RxMap<int, bool> isExpanded = <int, bool>{}.obs;
  late MatchEngine matchEngine;
  final ApiService apiService = Get.find<ApiService>();
  final RxString searchQuery = ''.obs;
  final GetStorage box = GetStorage();
var commentsMap = <int, List<CommentDatum>>{}.obs;
  @override
  void onInit() {
    super.onInit();
    initializeSwipeEngine();
    fetchPosts();
  }


Future<void> fetchComments(int postId) async {
  const String baseUrl = 'https://kotiboxglobaltech.com/travel_app/api';
  final url = Uri.parse('$baseUrl/comments/$postId');
  final token = box.read('token');

  try {
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    debugPrint("📥 Comment Response: ${response.body}");

    if (response.statusCode == 200) {
      final data = commentPostModelFromJson(response.body);

      if (data.status) {
        commentsMap[postId] = data.data;
        update();
      }
    } else {
      debugPrint("❌ Failed to fetch comments: ${response.body}");
    }
  } catch (e) {
    debugPrint("❌ Error in fetchComments: $e");
  }

}
/// ✅ Add Comment API
Future<void> addComment({
  required int postId,
  required String comment,
  int? parentId,
}) async {
  const String baseUrl = 'https://kotiboxglobaltech.com/travel_app/api';
  final url = Uri.parse('$baseUrl/add-comments');
  final token = box.read('token');

  if (token == null) {
    Get.snackbar("Auth Error", "You must login first",
        backgroundColor: Colors.red, colorText: Colors.white);
    return;
  }

  try {
    // ✅ Build form-data
    final body = {
      'post_id': postId.toString(),
      'comment': comment,
    };

    if (parentId != null) {
      body['parent_id'] = parentId.toString(); // only include if replying
    }

    debugPrint("📝 Sending form-data => $body");

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        // 'Content-Type': 'application/x-www-form-urlencoded' // optional
      },
      body: body, // this automatically sends as form-data
    );

    debugPrint("📥 Raw Response: ${response.body}");
    debugPrint("📊 Status Code: ${response.statusCode}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      debugPrint("✅ Comment Added: $data");

      Get.snackbar("Success", "Comment added successfully",
          backgroundColor: Colors.green, colorText: Colors.white);

      // optional refresh
      fetchPosts();
    } else {
      debugPrint("❌ Failed to add comment: ${response.body}");
      Get.snackbar("Error", "Failed to add comment",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  } catch (e) {
    debugPrint("❌ Error in addComment: $e");
    Get.snackbar("Error", "Something went wrong",
        backgroundColor: Colors.red, colorText: Colors.white);
  }
}

  /// ✅ Like toggle
  Future<void> toggleLike(int postId) async {
    const String baseUrl = 'https://kotiboxglobaltech.com/travel_app/api';
    final url = Uri.parse('$baseUrl/post/react');
    final token = box.read('token');

    if (token == null) {
      Get.snackbar("Auth Error", "You must login first",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    final indexAll = allPosts.indexWhere((p) => p.id == postId);
    if (indexAll == -1) return;

    final post = allPosts[indexAll];
    final alreadyLiked = post.isLiked == 1;
    final newReaction = alreadyLiked ? "dislike" : "like";

    final updatedPost = post.copyWith(
      isLiked: alreadyLiked ? 0 : 1,
      likesCount: alreadyLiked
          ? (post.likesCount > 0 ? post.likesCount - 1 : 0)
          : post.likesCount + 1,
    );

    allPosts[indexAll] = updatedPost;

    final indexFiltered = filteredPosts.indexWhere((p) => p.id == postId);
    if (indexFiltered != -1) filteredPosts[indexFiltered] = updatedPost;

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'post_id': postId.toString(), 'type': newReaction}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final likesFromApi = data['likes_count'] != null
            ? int.tryParse('${data['likes_count']}') ?? updatedPost.likesCount
            : updatedPost.likesCount;

        final finalPost = updatedPost.copyWith(likesCount: likesFromApi);
        allPosts[indexAll] = finalPost;
        if (indexFiltered != -1) filteredPosts[indexFiltered] = finalPost;

        debugPrint('✅ Like API success: $newReaction for post $postId');
      } else {
        allPosts[indexAll] = post;
        if (indexFiltered != -1) filteredPosts[indexFiltered] = post;
        debugPrint('❌ Like API failed: ${response.body}');
      }
    } catch (e) {
      allPosts[indexAll] = post;
      if (indexFiltered != -1) filteredPosts[indexFiltered] = post;
      debugPrint('❌ Toggle like failed: $e');
    }
  }

  Future<void> fetchPosts() async {
    try {
      final data = await apiService.fetchPosts();
      if (data['status'] == true && data['data'] is List) {
        allPosts.value = (data['data'] as List)
            .map((e) => Datum.fromJson(e as Map<String, dynamic>))
            .toList();
        updateFilteredPosts();
        initializeSwipeEngine();
      }
    } catch (e) {
      debugPrint('❌ Error in fetchPosts: $e');
    }
  }

  void updateFilteredPosts() {
    final basePosts = isTravelingMode.value ? locationPosts : allPosts;
    if (searchQuery.value.isEmpty) {
      filteredPosts.assignAll(basePosts);
    } else {
      final keyword = searchQuery.value.toLowerCase();
      filteredPosts.assignAll(
        basePosts.where(
          (post) =>
              post.question.toLowerCase().contains(keyword) ||
              post.location.toLowerCase().contains(keyword),
        ),
      );
    }
  }

  void searchPosts(String keyword) {
    searchQuery.value = keyword;
    updateFilteredPosts();
    initializeSwipeEngine();
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
    Future<void> fetchPostsByLocation(String location) async {
    try {
      final data = await apiService.fetchPostsByLocation(location);
      if (data['status'] == true && data['data'] is List) {
        locationPosts.value = (data['data'] as List)
            .map((e) => Datum.fromJson(e))
            .toList();
          updateFilteredPosts();
          fetchPosts();
            initializeSwipeEngine(); 
      }
    } catch (e) {
      debugPrint('❌ Error in fetchPostsByLocation: $e');
    }
  }
  

  void setTravelingMode(bool isTraveling) {
    isTravelingMode.value = isTraveling;
    updateFilteredPosts();
  }


}
