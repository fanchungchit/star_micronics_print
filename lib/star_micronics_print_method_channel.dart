import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:star_micronics_print/star_micronics_print.dart';

import 'star_micronics_print_platform_interface.dart';

class MethodChannelStarMicronicsPrint extends StarMicronicsPrintPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('star_micronics_print');

  @override
  Future<void> printBitmap(
    InterfaceType interfaceType,
    String identifier,
    Uint8List bitmap,
    int copies,
  ) {
    return methodChannel.invokeMethod('printBitmap', {
      'interfaceType': interfaceType.sdkName,
      'identifier': identifier,
      'bitmap': bitmap,
      'copies': copies,
    });
  }

  @override
  Future<void> printPath(
    InterfaceType interfaceType,
    String identifier,
    String path,
    int copies,
  ) {
    return methodChannel.invokeMethod('printPath', {
      'interfaceType': interfaceType.sdkName,
      'identifier': identifier,
      'path': path,
      'copies': copies,
    });
  }
}
