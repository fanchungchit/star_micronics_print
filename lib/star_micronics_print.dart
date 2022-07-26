import 'dart:typed_data';

import 'src/interface_type.dart';
import 'star_micronics_print_platform_interface.dart';
export 'src/interface_type.dart';

class StarMicronicsPrint {
  Future<void> printBitmap({
    required InterfaceType interfaceType,
    required String identifier,
    required Uint8List bitmap,
    int copies = 1,
  }) {
    return StarMicronicsPrintPlatform.instance
        .printBitmap(interfaceType, identifier, bitmap, copies);
  }

  Future<void> printPath({
    required InterfaceType interfaceType,
    required String identifier,
    required String path,
    int copies = 1,
  }) {
    return StarMicronicsPrintPlatform.instance
        .printPath(interfaceType, identifier, path, copies);
  }
}
