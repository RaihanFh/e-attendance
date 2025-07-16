import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();

  @override
  void onInit() {
    super.onInit();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _updateConnectionStatus(List<ConnectivityResult> connectivityResult) {
    if (connectivityResult.contains(ConnectivityResult.none)) {
      Get.rawSnackbar(
        messageText: const Text(
          'PLEASE CONNECT TO THE INTERNET',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        isDismissible: false,
        duration: Duration(days: 1),
        backgroundColor: Colors.red,
        icon: const Icon(Icons.wifi_off, color: Colors.white, size: 35),
        snackStyle: SnackStyle.FLOATING,
        snackPosition: SnackPosition.TOP, // Doesn't matter much when using alignment
        margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 250),
        borderRadius: 10,
        boxShadows: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        overlayBlur: 0.1,
      );
    } else {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
    }
  }
}