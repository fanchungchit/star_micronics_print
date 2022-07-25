import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:star_micronics_print/star_micronics_print.dart';
import 'dart:ui' as ui;

import 'package:url_launcher/url_launcher.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String _platformVersion = 'Unknown';
  final _starMicronicsPrintPlugin = StarMicronicsPrint();

  final key = GlobalKey();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await _starMicronicsPrintPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<Uint8List> capture() async {
    final RenderRepaintBoundary boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    print(pixelRatio);
    final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();
    return bytes;
  }

  Widget printBitmapButton() {
    return TextButton(
        onPressed: () async {
          final statuses = await [
            Permission.bluetooth,
            Permission.bluetoothConnect,
            Permission.bluetoothScan,
            Permission.bluetoothAdvertise,
          ].request();

          if (statuses.values.every((element) => element.isGranted)) {
            final bitmap = await capture();
            await _starMicronicsPrintPlugin.printBitmap(bitmap: bitmap);
          }

          print('Complete');
        },
        child: const Text(
          'Bitmap',
          style: TextStyle(color: Colors.white),
        ));
  }

  // Widget printReceiptButton() {
  //   return TextButton(
  //       onPressed: () async {
  //         final statuses = await [
  //           Permission.bluetooth,
  //           Permission.bluetoothConnect,
  //           Permission.bluetoothScan,
  //           Permission.bluetoothAdvertise,
  //         ].request();

  //         if (statuses.values.every((element) => element.isGranted)) {
  //           await _starMicronicsPrintPlugin.printReceipt();
  //         }

  //         print('Complete');
  //       },
  //       child: const Text(
  //         'Receipt',
  //         style: TextStyle(color: Colors.white),
  //       ));
  // }

  Widget captureButton() {
    return FloatingActionButton(
      onPressed: () async {
        final bitmap = await capture();
        await launchUrl(Uri.dataFromBytes(bitmap));
      },
      child: const Icon(Icons.download),
    );
  }

  Widget printPathButton() {
    return FloatingActionButton(
      onPressed: () async {
        final result = await FilePicker.platform.pickFiles();
        if (result != null) {
          await _starMicronicsPrintPlugin.printPath(
              path: result.files.single.path!);
        }
      },
      child: const Icon(Icons.folder),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
        actions: [
          printBitmapButton(),
          // printReceiptButton(),
        ],
      ),
      body: SingleChildScrollView(
          child: RepaintBoundary(
        key: key,
        child: Center(
            child: SizedBox(
          width: 576,
          child: Column(children: [
            ...List.generate(
                20,
                (index) => ListTile(
                      title: Row(children: const [
                        Text(
                          'Item 1',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Spacer(),
                        Text('12'),
                        Text('  \$56')
                      ]),
                    ))
          ]),
        )),
      )),
      floatingActionButton: printPathButton(),
    );
  }
}
