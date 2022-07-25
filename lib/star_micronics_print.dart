// You have generated a new plugin project without specifying the `--platforms`
// flag. A plugin project with no platform support was generated. To add a
// platform, run `flutter create -t plugin --platforms <platforms> .` under the
// same directory. You can also find a detailed instruction on how to add
// platforms in the `pubspec.yaml` at
// https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'package:flutter/foundation.dart';
import 'star_micronics_print_platform_interface.dart';

class StarMicronicsPrint {
  Future<String?> getPlatformVersion() {
    return StarMicronicsPrintPlatform.instance.getPlatformVersion();
  }

  // Future<List<StarMicronicsPrinter>> discovery({
  //   /// Interfaces to discovery.
  //   List<InterfaceType> interfaceTypes = InterfaceType.values,

  //   /// Discovery timeout
  //   int discoveryTime = 10000,
  // }) {
  //   return StarMicronicsPrintPlatform.instance
  //       .discovery(interfaceTypes, discoveryTime);
  // }

  Future<void> printBitmap({required Uint8List bitmap}) {
    return StarMicronicsPrintPlatform.instance.printBitmap(bitmap);
  }

  Future<void> printReceipt() {
    return StarMicronicsPrintPlatform.instance.printReceipt();
  }

  Future<void> printPath({required String path}) {
    return StarMicronicsPrintPlatform.instance.printPath(path);
  }
}
