import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_app2/app/constants/custom_button.dart';
import 'package:travel_app2/app/modules/post_quesions/controllers/bottom_sheet_controller.dart';


class BottomSheetQuestionsView extends GetView<BottomSheetQuestionsController> {
  BottomSheetQuestionsView({super.key});

  final BottomSheetQuestionsController controller =
      Get.put(BottomSheetQuestionsController());

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F2027),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 20,
        right: 20,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 16),
            _questionField(),
            const SizedBox(height: 16),
            _locationSearch(),
            const SizedBox(height: 24),
            Obx(() => CustomButton(
                  isLoading: controller.isLoading,
                  onPressed: controller.submitPost,
                  text: "Post",
                  textColor: Colors.white,
                )),
          ],
        ),
      ),
    );
  }

  Widget _header() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Create a Post",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.close, color: Colors.white70),
          ),
        ],
      );

  Widget _questionField() => TextField(
        onChanged: controller.updateQuestion,
        maxLines: 4,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "What's on your mind?",
          hintStyle: TextStyle(color: Colors.grey.shade500),
          filled: true,
          fillColor: const Color(0xFF1F1F1F),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      );

  Widget _locationSearch() {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller.locationController,
            onChanged: (value) {
              controller.updateLocation(value);
              controller.fetchLocations(value);
            },
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "Location",
              labelStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: const Color(0xFF1F1F1F),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              suffixIcon: controller.isSearching.value
                  ? const Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.search, color: Colors.white70),
            ),
          ),
          if (controller.searchResults.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1F1F1F),
                borderRadius: BorderRadius.circular(12),
              ),
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: controller.searchResults.length,
                itemBuilder: (context, i) {
                  final place = controller.searchResults[i];
                  return ListTile(
                    title: Text(place, style: const TextStyle(color: Colors.white)),
                    onTap: () {
                      controller.updateLocation(place);
                      controller.searchResults.clear();
                      FocusScope.of(context).unfocus();
                    },
                  );
                },
              ),
            ),
        ],
      );
    });
  }
}
