import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:star_micronics_print/star_micronics_print.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeView(),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final star = StarMicronicsPrint();
  final captureKey = GlobalKey();

  final interfaceType = InterfaceType.bluetooth;
  final identifier = '00:11:62:18:DA:4E';
  final copies = 2;

  Future<Uint8List> capture() async {
    final RenderRepaintBoundary boundary =
        captureKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
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
            await star.printBitmap(
                interfaceType: interfaceType,
                identifier: identifier,
                bitmap: bitmap,
                copies: copies);
          }
        },
        child: const Text(
          'Print',
          style: TextStyle(color: Colors.white),
        ));
  }

  Widget printPathButton() {
    return FloatingActionButton(
      onPressed: () async {
        final result = await FilePicker.platform.pickFiles();
        if (result != null) {
          await star.printPath(
              interfaceType: interfaceType,
              identifier: identifier,
              path: result.files.single.path!,
              copies: copies);
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
        ],
      ),
      body: SingleChildScrollView(
          child: RepaintBoundary(
        key: captureKey,
        child: Center(
            child: SizedBox(
          width: 576,
          child: Column(children: [
            Image.asset(
              'assets/company_logo.webp',
              scale: MediaQuery.of(context).devicePixelRatio,
            ),
            const ListTile(
                title: Text('Some company',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold))),
            ListTile(
              title: Text('${DateTime.now()}', textAlign: TextAlign.center),
            ),
            ListTile(
              title: Row(children: const [
                Text(
                  'Item Des.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Text('QTY', style: TextStyle(fontWeight: FontWeight.bold)),
              ]),
            ),
            ...List.generate(
                10,
                (index) => ListTile(
                      title: Row(children: [
                        Text(
                          'Item $index',
                        ),
                        const Spacer(),
                        Text('${Random().nextInt(50)}'),
                      ]),
                    )),
            ListTile(
              title: BarcodeWidget(
                  data: 'https://github.com/Bridges-Tech/star_micronics_print',
                  barcode: Barcode.qrCode()),
            )
          ]),
        )),
      )),
      floatingActionButton: printPathButton(),
    );
  }
}
