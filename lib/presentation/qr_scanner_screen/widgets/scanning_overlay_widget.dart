import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class ScanningOverlayWidget extends StatefulWidget {
  final bool isScanning;
  final String instructionText;

  const ScanningOverlayWidget({
    Key? key,
    this.isScanning = false,
    this.instructionText = 'Position QR code within frame',
  }) : super(key: key);

  @override
  State<ScanningOverlayWidget> createState() => _ScanningOverlayWidgetState();
}

class _ScanningOverlayWidgetState extends State<ScanningOverlayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.isScanning) {
      _animationController.repeat();
    }
  }

  @override
  void didUpdateWidget(ScanningOverlayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isScanning && !oldWidget.isScanning) {
      _animationController.repeat();
    } else if (!widget.isScanning && oldWidget.isScanning) {
      _animationController.stop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60.w,
            height: 60.w,
            child: Stack(
              children: [
                // Scanning frame
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppTheme.primaryLight,
                      width: 3,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: CustomPaint(
                    size: Size(60.w, 60.w),
                    painter: DashedBorderPainter(
                      color: AppTheme.primaryLight,
                      strokeWidth: 2,
                      dashLength: 8,
                      gapLength: 4,
                    ),
                  ),
                ),
                // Corner indicators
                Positioned(
                  top: -2,
                  left: -2,
                  child: _buildCornerIndicator(true, true),
                ),
                Positioned(
                  top: -2,
                  right: -2,
                  child: _buildCornerIndicator(true, false),
                ),
                Positioned(
                  bottom: -2,
                  left: -2,
                  child: _buildCornerIndicator(false, true),
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: _buildCornerIndicator(false, false),
                ),
                // Animated scanning line
                if (widget.isScanning)
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Positioned(
                        top: (60.w - 4) * _animation.value,
                        left: 8,
                        right: 8,
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                AppTheme.primaryLight,
                                Colors.transparent,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
          SizedBox(height: 4.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.instructionText,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCornerIndicator(bool isTop, bool isLeft) {
    return Container(
      width: 8.w,
      height: 8.w,
      decoration: BoxDecoration(
        border: Border(
          top: isTop
              ? BorderSide(color: AppTheme.primaryLight, width: 4)
              : BorderSide.none,
          bottom: !isTop
              ? BorderSide(color: AppTheme.primaryLight, width: 4)
              : BorderSide.none,
          left: isLeft
              ? BorderSide(color: AppTheme.primaryLight, width: 4)
              : BorderSide.none,
          right: !isLeft
              ? BorderSide(color: AppTheme.primaryLight, width: 4)
              : BorderSide.none,
        ),
        borderRadius: BorderRadius.only(
          topLeft: isTop && isLeft ? Radius.circular(8) : Radius.zero,
          topRight: isTop && !isLeft ? Radius.circular(8) : Radius.zero,
          bottomLeft: !isTop && isLeft ? Radius.circular(8) : Radius.zero,
          bottomRight: !isTop && !isLeft ? Radius.circular(8) : Radius.zero,
        ),
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.gapLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(16),
      ));

    _drawDashedPath(canvas, path, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final pathMetrics = path.computeMetrics();
    for (final pathMetric in pathMetrics) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        final double nextDistance = distance + dashLength;
        final Path extractPath = pathMetric.extractPath(
          distance,
          nextDistance > pathMetric.length ? pathMetric.length : nextDistance,
        );
        canvas.drawPath(extractPath, paint);
        distance = nextDistance + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}