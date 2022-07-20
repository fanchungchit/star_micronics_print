import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'star_micronics_print_method_channel.dart';

abstract class StarMicronicsPrintPlatform extends PlatformInterface {
  /// Constructs a StarMicronicsPrintPlatform.
  StarMicronicsPrintPlatform() : super(token: _token);

  static final Object _token = Object();

  static StarMicronicsPrintPlatform _instance = MethodChannelStarMicronicsPrint();

  /// The default instance of [StarMicronicsPrintPlatform] to use.
  ///
  /// Defaults to [MethodChannelStarMicronicsPrint].
  static StarMicronicsPrintPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [StarMicronicsPrintPlatform] when
  /// they register themselves.
  static set instance(StarMicronicsPrintPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
