import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/queue_service.dart';
import '../main.dart';
import 'package:visibility_detector/visibility_detector.dart';

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({super.key});

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> with WidgetsBindingObserver {
  bool _isProcessing = false;
  late MobileScannerController controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      returnImage: false,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (controller.value.isInitialized) {
      if (state == AppLifecycleState.resumed) {
        controller.start();
      } else if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
        controller.stop();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    
    final String? code = barcodes.first.rawValue;
    if (code == null) return;

    if (code.startsWith('sqms://join/')) {
      setState(() => _isProcessing = true);
      final queueId = code.replaceFirst('sqms://join/', '');
      
      try {
        await context.read<QueueService>().generateToken(queueId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Joined Queue Successfully! ✅ Go to Home to see your token.'), 
              backgroundColor: Colors.green,
              duration: Duration(seconds: 4),
            ),
          );
          setState(() => _isProcessing = false);
          if (mounted) {
            context.read<NavigationProvider>().setIndex(0); // Switch to Home tab
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error joining queue: $e'), backgroundColor: Colors.red),
          );
          setState(() => _isProcessing = false);
        }
      }
    } else {
       // Invalid QR for our app
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Invalid SQMS QR Code ❌')),
       );
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('qr-scanner-visibility-key'),
      onVisibilityChanged: (visibilityInfo) {
        var visiblePercentage = visibilityInfo.visibleFraction * 100;
        if (visiblePercentage < 1) {
          if (controller.value.isInitialized) {
            controller.stop();
          }
        } else {
          if (controller.value.isInitialized) {
            controller.start();
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            MobileScanner(
              controller: controller,
              onDetect: _onDetect,
            ),
            Positioned.fill(
              child: Container(
                decoration: ShapeDecoration(
                  shape: QrScannerOverlayShape(
                    borderColor: const Color(0xFF4DA1FF),
                    borderRadius: 30,
                    borderLength: 40,
                    borderWidth: 10,
                    cutOutSize: 280,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 50,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () {
                      context.read<NavigationProvider>().setIndex(0);
                    },
                  ),
                  Text(
                    "SCAN STATION QR",
                    style: GoogleFonts.tomorrow(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      fontSize: 16,
                    ),
                  ),
                  IconButton(
                    icon: ValueListenableBuilder<MobileScannerState>(
                      valueListenable: controller,
                      builder: (context, state, child) {
                        switch (state.torchState) {
                          case TorchState.off:
                            return const Icon(Icons.flash_off, color: Colors.white38);
                          case TorchState.on:
                            return const Icon(Icons.flash_on, color: Color(0xFF4DA1FF));
                          case TorchState.unavailable:
                            return const Icon(Icons.flash_off, color: Colors.redAccent);
                          case TorchState.auto:
                            return const Icon(Icons.flash_auto, color: Colors.white38);
                          default:
                            return const Icon(Icons.flash_off, color: Colors.white38);
                        }
                      },
                    ),
                    onPressed: () => controller.toggleTorch(),
                  ),
                ],
              ),
            ),
            if (_isProcessing)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(color: Color(0xFF4DA1FF)),
                ),
              ),
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  "Align QR code within the frame",
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.5),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const QrScannerOverlayShape({
    this.borderColor = Colors.white,
    this.borderWidth = 10,
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) => Path()..addRect(rect);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final height = rect.height;

    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    final cutOutRect = Rect.fromCenter(
      center: Offset(width / 2, height / 2),
      width: cutOutSize,
      height: cutOutSize,
    );

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(rect),
        Path()..addRRect(RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius))),
      ),
      paint,
    );

    final linePaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;

    final halfWidth = cutOutSize / 2;
    final center = Offset(width / 2, height / 2);

    // Top Left
    canvas.drawPath(
      Path()
        ..moveTo(center.dx - halfWidth, center.dy - halfWidth + borderLength)
        ..lineTo(center.dx - halfWidth, center.dy - halfWidth)
        ..lineTo(center.dx - halfWidth + borderLength, center.dy - halfWidth),
      linePaint,
    );

    // Top Right
    canvas.drawPath(
      Path()
        ..moveTo(center.dx + halfWidth - borderLength, center.dy - halfWidth)
        ..lineTo(center.dx + halfWidth, center.dy - halfWidth)
        ..lineTo(center.dx + halfWidth, center.dy - halfWidth + borderLength),
      linePaint,
    );

    // Bottom Left
    canvas.drawPath(
      Path()
        ..moveTo(center.dx - halfWidth, center.dy + halfWidth - borderLength)
        ..lineTo(center.dx - halfWidth, center.dy + halfWidth)
        ..lineTo(center.dx - halfWidth + borderLength, center.dy + halfWidth),
      linePaint,
    );

    // Bottom Right
    canvas.drawPath(
      Path()
        ..moveTo(center.dx + halfWidth - borderLength, center.dy + halfWidth)
        ..lineTo(center.dx + halfWidth, center.dy + halfWidth)
        ..lineTo(center.dx + halfWidth, center.dy + halfWidth - borderLength),
      linePaint,
    );
  }

  @override
  ShapeBorder scale(double t) => QrScannerOverlayShape(
        borderColor: borderColor,
        borderWidth: borderWidth,
        borderRadius: borderRadius,
        borderLength: borderLength,
        cutOutSize: cutOutSize,
      );
}
