import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_scankit/flutter_scankit.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'qr_bar_code_scanner_dialog_platform_interface.dart';

/// An implementation of [QrBarCodeScannerDialogPlatform] that uses method channels.
class MethodChannelQrBarCodeScannerDialog
    extends QrBarCodeScannerDialogPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('qr_bar_code_scanner_dialog');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  void scanBarOrQrCode(
      {BuildContext? context,
      ScanType scanType = ScanType.all,
      required Function(String? code) onScanSuccess}) {
    /// context is required to show alert in non-web platforms
    assert(context != null);
    FocusManager.instance.primaryFocus?.unfocus();
    SmartDialog.show(
      tag: "qr_bar_code_scanner_dialog",
      builder: (context) => Align(
        alignment: Alignment.center,
        child: Container(
          width: 600,
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: ScannerWidget(
              scanType: scanType,
              onScanSuccess: (code) {
                if (code != null) {
                  SmartDialog.dismiss(
                      status: SmartStatus.dialog,
                      tag: "qr_bar_code_scanner_dialog");
                  onScanSuccess(code);
                }
              }),
        ),
      ),
    );
  }
}

class ScannerWidget extends StatefulWidget {
  final void Function(String? code) onScanSuccess;
  final ScanType scanType;
  const ScannerWidget(
      {super.key, this.scanType = ScanType.all, required this.onScanSuccess});

  @override
  createState() => _ScannerWidgetState();
}

class _ScannerWidgetState extends State<ScannerWidget> {
  final ScanKitController _controller = ScanKitController();
  GlobalKey qrKey = GlobalKey(debugLabel: 'scanner');

  bool isScanned = false;

  @override
  void initState() {
    _controller.onResult.listen((result) {
      SmartDialog.dismiss(
          status: SmartStatus.dialog, tag: "qr_bar_code_scanner_dialog");
      debugPrint(
          "scanning result:value=${result.originalValue} scanType=${result.scanType}");
      if (!isScanned) {
        isScanned = true;
        widget.onScanSuccess(result.originalValue);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    /// dispose the controller
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: _buildQrView(context),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                SmartDialog.dismiss(
                    status: SmartStatus.dialog,
                    tag: "qr_bar_code_scanner_dialog");
              },
              child: const Text("Stop scanning"),
            ),
            IconButton(
              onPressed: () {
                _controller.switchLight();
              },
              icon: const Icon(
                Icons.lightbulb_outline_rounded,
                color: Colors.blue,
                size: 28,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQrView(BuildContext context) {
    double smallestDimension = MediaQuery.of(context).size.width;
    smallestDimension = min(smallestDimension, 550);
    var rect = Rect.fromLTWH(0, 0, smallestDimension, smallestDimension);
    int types = ScanTypes.all.bit;
    if (widget.scanType == ScanType.barCode) {
      types = ScanTypes.code39.bit |
          ScanTypes.code128.bit |
          ScanTypes.codaBar.bit |
          ScanTypes.code93.bit |
          ScanTypes.ean13.bit |
          ScanTypes.ean8.bit |
          ScanTypes.upcCodeE.bit |
          ScanTypes.upcCodeA.bit;
    } else if (widget.scanType == ScanType.qrCode) {
      types = ScanTypes.qRCode.bit |
          ScanTypes.aztec.bit |
          ScanTypes.pdf417.bit |
          ScanTypes.itf14.bit;
    }

    return SizedOverflowBox(
      alignment: Alignment.topCenter,
      size: Size(smallestDimension, smallestDimension),
      child: Align(
        alignment: Alignment.topCenter,
        child: ScanKitWidget(
          controller: _controller,
          continuouslyScan: false,
          boundingBox: rect,
          format: types,
        ),
      ),
    );
  }
}
