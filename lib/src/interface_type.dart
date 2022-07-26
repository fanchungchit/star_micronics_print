import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum InterfaceType {
  lan,
  bluetooth,
  usb,
}

extension InterfaceTypeExtension on InterfaceType {
  String get fullName {
    switch (this) {
      case InterfaceType.lan:
        return 'LAN';
      case InterfaceType.bluetooth:
        return 'Bluetooth';
      case InterfaceType.usb:
        return 'USB';
    }
  }

  /// Communicate with SDK.
  String get sdkName {
    return '${name[0].toUpperCase()}${name.substring(1)}';
  }

  Widget get icon {
    switch (this) {
      case InterfaceType.lan:
        return const FaIcon(FontAwesomeIcons.ethernet);
      case InterfaceType.bluetooth:
        return const FaIcon(FontAwesomeIcons.bluetooth);
      case InterfaceType.usb:
        return const FaIcon(FontAwesomeIcons.usb);
    }
  }
}
