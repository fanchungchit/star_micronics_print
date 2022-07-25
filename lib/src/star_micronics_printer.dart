import 'package:star_micronics_print/src/interface_type.dart';

enum StarMicronicsPrinterModel {
  tsp100iiiBi,
}

extension StarMicronicsPrinterModelExtension on StarMicronicsPrinterModel {
  /// Communicate with SDK.
  String get sdkName {
    return name.toUpperCase();
  }
}

class StarMicronicsPrinter {
  StarMicronicsPrinter({
    required this.identifier,
    required this.model,
    required this.interfaceType,
  });

  /// MAC address of the printer.
  String identifier;

  StarMicronicsPrinterModel model;

  InterfaceType interfaceType;

  @override
  String toString() => '''Identifier: $identifier,
Model: $model,
InterfaceType: $interfaceType''';

  factory StarMicronicsPrinter.fromJson(Map<String, dynamic> json) {
    try {
      final identifier = json['identifier'];

      final model = StarMicronicsPrinterModel.values
          .where((model) => model.sdkName == json['model']);
      if (model.length != 1) {
        throw 'Model ${json['model']} not supported.';
      }

      final interfaceType = InterfaceType.values.where(
          (interfaceType) => interfaceType.sdkName == json['interfaceType']);
      if (interfaceType.length != 1) {
        throw 'Interface Type ${json['interfaceType']} not supported';
      }

      return StarMicronicsPrinter(
          identifier: identifier,
          model: model.single,
          interfaceType: interfaceType.single);
    } catch (e) {
      rethrow;
    }
  }
}
