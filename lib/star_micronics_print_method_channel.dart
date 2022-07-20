import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'star_micronics_print_platform_interface.dart';

/// An implementation of [StarMicronicsPrintPlatform] that uses method channels.
class MethodChannelStarMicronicsPrint extends StarMicronicsPrintPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('star_micronics_print');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
