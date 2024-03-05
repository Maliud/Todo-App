import 'package:flutter/foundation.dart';

class NotificationProvider extends ChangeNotifier {
  final bool _notification = false;

  bool get notification => _notification;

  void setnotification(bool notification) {
    notification = notification;
  }
}
