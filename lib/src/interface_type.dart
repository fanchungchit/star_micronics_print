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
}
