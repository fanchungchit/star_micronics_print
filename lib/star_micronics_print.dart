import 'package:flutter/foundation.dart';

import 'src/interface_type.dart';
import 'star_micronics_print_platform_interface.dart';

export 'src/interface_type.dart';

class StarMicronicsPrint {
  Future<void> printBitmap({
    required InterfaceType interfaceType,
    required String identifier,
    required Uint8List bitmap,
  }) {
    return StarMicronicsPrintPlatform.instance
        .printBitmap(interfaceType, identifier, bitmap);
  }

  Future<void> printPath({
    required InterfaceType interfaceType,
    required String identifier,
    required String path,
  }) {
    return StarMicronicsPrintPlatform.instance
        .printPath(interfaceType, identifier, path);
  }
}
