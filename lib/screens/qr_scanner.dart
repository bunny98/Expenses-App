import 'dart:io';

import 'package:expense/models/upi_payment.dart';
import 'package:expense/screens/pay_from_qr.dart';
import 'package:expense/utils/global_func.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScannerWidget extends StatefulWidget {
  const QRScannerWidget({Key? key}) : super(key: key);

  @override
  _QRScannerWidgetState createState() => _QRScannerWidgetState();
}

class _QRScannerWidgetState extends State<QRScannerWidget> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan and Pay"),
      ),
      body: Stack(
        children: <Widget>[
          _buildQrView(context),
          Positioned(
            bottom: 10,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                        onPressed: () async {
                          await controller?.toggleFlash();
                          setState(() {});
                        },
                        child: FutureBuilder(
                          future: controller?.getFlashStatus(),
                          builder: (context, snapshot) {
                            if (snapshot.data != null &&
                                snapshot.data as bool) {
                              return const Icon(Icons.flash_off);
                            }
                            if (snapshot.data != null &&
                                !(snapshot.data as bool)) {
                              return const Icon(Icons.flash_on);
                            }
                            return const CircularProgressIndicator();
                          },
                        )),
                    ElevatedButton(
                        onPressed: () async {
                          await controller?.flipCamera();
                          setState(() {});
                        },
                        child: const Icon(Icons.cameraswitch_sharp)),
                    // ElevatedButton(
                    //   onPressed: () async {
                    //     await controller?.pauseCamera();
                    //   },
                    //   child: const Text('pause', style: TextStyle(fontSize: 20)),
                    // ),
                    // ElevatedButton(
                    //   onPressed: () async {
                    //     await controller?.resumeCamera();
                    //   },
                    //   child: const Text('resume', style: TextStyle(fontSize: 20)),
                    // ),
                  ]),
            ),
          ),
          if (result != null)
            Text(
                'Barcode Type: ${describeEnum(result!.format)}   Data: ${result!.code}')
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 250.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.blueAccent,
        cutOutBottomOffset: 50,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: scanArea,
      ),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) async {
      controller.pauseCamera();
      Uri uri = Uri.parse(scanData.code!);
      Map<String, dynamic> params = uri.queryParameters;
      if (!params.containsKey('pa') || !params.containsKey('pn')) {
        controller.resumeCamera();
        showToast("Invalid QR");
        return;
      }
      UPIPayment upiPayment =
          UPIPayment(upiId: params['pa'], recipientName: params['pn']);
      await Navigator.of(context).push(MaterialPageRoute(
          builder: (ctx) => PayFromQRScreen(upiPayment: upiPayment)));
      controller.resumeCamera();
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    debugPrint('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
