import 'package:flutter/widgets.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'qr_bar_code_scanner_dialog_method_channel.dart';

enum ScanType {
  /// 1. QRCode
  qrCode,

  /// 2. BarCode
  barCode,

  /// 3. QRCode and BarCode
  all,
}

abstract class QrBarCodeScannerDialogPlatform extends PlatformInterface {
  /// Constructs a QrBarCodeScannerDialogPlatform.
  QrBarCodeScannerDialogPlatform() : super(token: _token);

  static final Object _token = Object();

  static QrBarCodeScannerDialogPlatform _instance =
      MethodChannelQrBarCodeScannerDialog();

  /// The default instance of [QrBarCodeScannerDialogPlatform] to use.
  ///
  /// Defaults to [MethodChannelQrBarCodeScannerDialog].
  static QrBarCodeScannerDialogPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [QrBarCodeScannerDialogPlatform] when
  /// they register themselves.
  static set instance(QrBarCodeScannerDialogPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  void scanBarOrQrCode(
      {BuildContext? context,
      ScanType scanType = ScanType.all,
      required Function(String? code) onScanSuccess}) {
    throw UnimplementedError('scanBarOrQrCodeWeb() has not been implemented.');
  }
}
