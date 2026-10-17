// import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxService {
  final isOnline = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Connectivity().onConnectivityChanged.listen((result) {
    //   isOnline.value = result != ConnectivityResult.none;
    // });
  }
}