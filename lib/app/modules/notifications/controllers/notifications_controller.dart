// controllers/notification_controller.dart
import 'package:get/get.dart';

import '../notifications_model.dart';


class NotificationController extends GetxController {
  var notifications = <NotificationModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  void fetchNotifications() {
    notifications.value = [
      NotificationModel(
        title: "New Comment",
        message: "Someone commented on your post.",
        time: "2 mins ago",
      ),
      NotificationModel(
        title: "New Follower",
        message: "John Doe started following you.",
        time: "10 mins ago",
      ),
      NotificationModel(
        title: "Update Available",
        message: "A new version of the app is available.",
        time: "1 hour ago",
      ),


      NotificationModel(
        title: "Reminder",
        message: "Don't forget your meeting at 5 PM.",
        time: "4 hours ago",
      ),
      NotificationModel(
        title: "Security Alert",
        message: "Unusual login activity detected.",
        time: "5 hours ago",
      ),


      NotificationModel(
        title: "Offer Unlocked",
        message: "You have unlocked a 20% discount coupon.",
        time: "Yesterday",
      ),
    ];
  }

}
