import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/queue_service.dart';

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({super.key});

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  bool _isProcessing = false;
  MobileScannerController controller = MobileScannerController();

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
            const SnackBar(content: Text('Joined Queue Successfully! ✅'), backgroundColor: Colors.green),
          );
          Navigator.of(context).pop(); // Go back to home
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
          ),
          
          // Overlay UI
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

          // Header
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
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
                  icon: ValueListenableBuilder(
                    valueListenable: controller.torchState,
                    builder: (context, state, child) {
                      switch (state) {
                        case TorchState.off:
                          return const Icon(Icons.flash_off, color: Colors.white38);
                        case TorchState.on:
                          return const Icon(Icons.flash_on, color: Color(0xFF4DA1FF));
                      }
                    },
                  ),
                  onPressed: () => controller.toggleTorch(),
                ),
              ],
            ),
          ),

          // Loading Indicator
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF4DA1FF)),
              ),
            ),
          
          // Bottom Tip
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
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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
