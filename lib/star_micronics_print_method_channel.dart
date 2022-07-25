import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:star_micronics_print/src/interface_type.dart';
import 'package:star_micronics_print/src/star_micronics_printer.dart';

import 'star_micronics_print_platform_interface.dart';

/// An implementation of [StarMicronicsPrintPlatform] that uses method channels.
class MethodChannelStarMicronicsPrint extends StarMicronicsPrintPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('star_micronics_print');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  // @override
  // Future<List<StarMicronicsPrinter>> discovery(
  //     List<InterfaceType> interfaceTypes, int discoveryTime) async {
  //   final printers =
  //       await methodChannel.invokeMethod<List<dynamic>>('discovery', {
  //     'interfaceTypes': interfaceTypes.map((e) => e.sdkName).toList(),
  //     'discoveryTime': discoveryTime,
  //   });

  //   return printers
  //           ?.map((e) => StarMicronicsPrinter.fromJson(
  //               (e as Map).cast<String, dynamic>()))
  //           .toList() ??
  //       [];
  // }

  @override
  Future<void> printBitmap(Uint8List bitmap) async {
    return methodChannel.invokeMethod('printBitmap', {'bitmap': bitmap});
  }

  @override
  Future<void> printReceipt() async {
    return methodChannel.invokeMethod('printReceipt');
  }

  @override
  Future<void> printPath(String path) async {
    return methodChannel.invokeMethod('printPath', {'path': path});
  }
}
