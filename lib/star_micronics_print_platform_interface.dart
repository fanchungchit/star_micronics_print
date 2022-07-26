import 'package:flutter/foundation.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:star_micronics_print/star_micronics_print.dart';

import 'star_micronics_print_method_channel.dart';

abstract class StarMicronicsPrintPlatform extends PlatformInterface {
  StarMicronicsPrintPlatform() : super(token: _token);

  static final Object _token = Object();

  static StarMicronicsPrintPlatform _instance =
      MethodChannelStarMicronicsPrint();

  static StarMicronicsPrintPlatform get instance => _instance;

  static set instance(StarMicronicsPrintPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> printBitmap(InterfaceType interfaceType, String identifier,
      Uint8List bitmap, int copies) {
    throw UnimplementedError('printBitmap() has not been implemented.');
  }

  Future<void> printPath(
      InterfaceType interfaceType, String identifier, String path, int copies) {
    throw UnimplementedError('printPath() has not been implemented.');
  }
}
