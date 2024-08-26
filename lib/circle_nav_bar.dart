import 'package:flutter/material.dart';

class CircleNavBar extends StatefulWidget {
  const CircleNavBar({
    required this.activeIndex,
    this.onTap,
    required this.middleIcons,
    required this.icons,
    this.circleWidth = 60,
    required this.color,
    this.height = 80,
    this.circleColor,
    this.cornerRadius = BorderRadius.zero,
    this.shadowColor = Colors.transparent,
    this.circleShadowColor = Colors.transparent,
    this.elevation = 0,
    this.gradient,
    this.circleGradient,
    this.levels,
    this.activeLevelsStyle,
    this.inactiveLevelsStyle,
    this.isStatic = false, // New parameter to control static behavior
    required this.onMiddleButtonPressed,
    required this.middleButtonIndex,
  })  : assert(circleWidth <= height, "circleWidth <= height"),
        assert(icons.length >= 3 && icons.length <= 5,
            "inactiveIcons.length >= 3 && inactiveIcons.length <= 5"),
        assert(middleButtonIndex == 2 || middleButtonIndex == 1,
            "middleButtonIndex == 2 || middleButtonIndex == 1"),
        assert(middleButtonIndex == 1 ? icons.length == 3 : icons.length == 5,
            "Invalid middleButtonIndex"),
        assert(
            icons.length > activeIndex, "inactiveIcons.length > activeIndex");

  final double height;
  final double circleWidth;
  final Color color;
  final Color? circleColor;
  final Widget middleIcons;
  final List<Widget> icons;
  final BorderRadius cornerRadius;
  final Color shadowColor;
  final Color? circleShadowColor;
  final double elevation;
  final Gradient? gradient;
  final Gradient? circleGradient;
  final int activeIndex;
  final Function(int index)? onTap;
  final List<String>? levels;
  final TextStyle? activeLevelsStyle;
  final TextStyle? inactiveLevelsStyle;
  final bool isStatic;
  final Function(int index) onMiddleButtonPressed;
  final int middleButtonIndex;

  @override
  State<StatefulWidget> createState() => _CircleNavBarState();
}

class _CircleNavBarState extends State<CircleNavBar> {
  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double middleButtonPosition = widget.middleButtonIndex == 1
        ? deviceWidth * 0.4 - widget.circleWidth * 0.15
        : deviceWidth / 2 - widget.circleWidth / 2;

    return SizedBox(
      // margin: EdgeInsets.all(10),
      width: double.infinity,
      height: widget.height,
      child: Stack(
        children: [
          // Navigation Bar Background
          CustomPaint(
            painter: _CircleBottomPainter(
              iconWidth: widget.circleWidth,
              color: widget.color,
              circleColor: widget.circleColor ?? widget.color,
              xOffsetPercent: 0, // Static, no animation
              boxRadius: widget.cornerRadius,
              shadowColor: widget.shadowColor,
              circleShadowColor: widget.circleShadowColor ?? widget.shadowColor,
              elevation: widget.elevation,
              gradient: widget.gradient,
              circleGradient: widget.circleGradient ?? widget.gradient,
              isStatic: widget.isStatic, // Pass static behavior to painter
            ),
            child: SizedBox(
              height: widget.height,
              width: double.infinity,
            ),
          ),
          // Bottom Navigation Bar with Inactive Icons and Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: widget.icons.asMap().entries.map((entry) {
              int currentIndex = entry.key;
              Widget e = entry.value;
              bool isMiddle = currentIndex == widget.activeIndex;

              return Expanded(
                child: GestureDetector(
                  onTap: () => widget.onTap?.call(currentIndex),
                  child: Column(
                    mainAxisAlignment: widget.levels != null &&
                            currentIndex < widget.levels!.length
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.center,
                    children: [
                      e, // Show inactive icon
                      if (widget.levels != null &&
                          currentIndex < widget.levels!.length)
                        Padding(
                          padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                          child: Text(
                            widget.levels![currentIndex],
                            style: isMiddle
                                ? widget.activeLevelsStyle
                                : widget.inactiveLevelsStyle,
                          ),
                        ),
                        SizedBox(height: 6),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          // Static Middle Button
          Positioned(
            left: middleButtonPosition,
            child: GestureDetector(
              onTap: () =>
                  widget.onMiddleButtonPressed(widget.middleButtonIndex),
              child: Container(
                width: widget.circleWidth,
                height: widget.circleWidth,
                transform: Matrix4.translationValues(
                    0,
                    -(widget.circleWidth * 0.5) +
                        _CircleBottomPainter.getMiniRadius(widget.circleWidth),
                    0),
                child:
                    widget.middleIcons, // Show active icon in the middle button
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleBottomPainter extends CustomPainter {
  _CircleBottomPainter({
    required this.iconWidth,
    required this.color,
    required this.circleColor,
    required this.xOffsetPercent,
    required this.boxRadius,
    required this.shadowColor,
    required this.circleShadowColor,
    required this.elevation,
    this.gradient,
    this.circleGradient,
    required this.isStatic,
  });

  final Color color;
  final Color circleColor;
  final double iconWidth;
  final double xOffsetPercent;
  final BorderRadius boxRadius;
  final Color shadowColor;
  final Color circleShadowColor;
  final double elevation;
  final Gradient? gradient;
  final Gradient? circleGradient;
  final bool isStatic;

  static double getR(double circleWidth) {
    return circleWidth / 2 * 1.2;
  }

  static double getMiniRadius(double circleWidth) {
    return getR(circleWidth) * 0.3;
  }

  static double convertRadiusToSigma(double radius) {
    return radius * 0.57735 + 0.5;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();
    Paint paint = Paint();
    Paint? circlePaint;

    if (color != circleColor || circleGradient != null) {
      circlePaint = Paint();
      circlePaint.color = circleColor;
    }

    final w = size.width;
    final h = size.height;
    final r = getR(iconWidth);
    final miniRadius = getMiniRadius(iconWidth);
    final x = w / 2; // Static, center the circle
    final firstX = x - r;
    final secondX = x + r;

    // TopLeft Radius
    path.moveTo(0, 0 + boxRadius.topLeft.y);
    path.quadraticBezierTo(0, 0, boxRadius.topLeft.x, 0);
    path.lineTo(firstX - miniRadius, 0);
    path.quadraticBezierTo(firstX, 0, firstX, miniRadius);

    path.arcToPoint(
      Offset(secondX, miniRadius),
      radius: Radius.circular(r),
      clockwise: false,
    );

    path.quadraticBezierTo(secondX, 0, secondX + miniRadius, 0);

    // TopRight Radius
    path.lineTo(w - boxRadius.topRight.x, 0);
    path.quadraticBezierTo(w, 0, w, boxRadius.topRight.y);

    // BottomRight Radius
    path.lineTo(w, h - boxRadius.bottomRight.y);
    path.quadraticBezierTo(w, h, w - boxRadius.bottomRight.x, h);

    // BottomLeft Radius
    path.lineTo(boxRadius.bottomLeft.x, h);
    path.quadraticBezierTo(0, h, 0, h - boxRadius.bottomLeft.y);

    path.close();

    paint.color = color;

    if (gradient != null) {
      Rect shaderRect =
          Rect.fromCircle(center: Offset(w / 2, h / 2), radius: 180.0);
      paint.shader = gradient!.createShader(shaderRect);
    }

    if (circleGradient != null) {
      Rect shaderRect =
          Rect.fromCircle(center: Offset(x, miniRadius), radius: iconWidth / 2);
      circlePaint?.shader = circleGradient!.createShader(shaderRect);
    }

    // Static Shadow Painting
    canvas.drawPath(
        path,
        Paint()
          ..color = shadowColor
          ..maskFilter = MaskFilter.blur(
              BlurStyle.normal, convertRadiusToSigma(elevation)));

    canvas.drawCircle(
        Offset(x, miniRadius),
        iconWidth / 2,
        Paint()
          ..color = circleShadowColor
          ..maskFilter = MaskFilter.blur(
              BlurStyle.normal, convertRadiusToSigma(elevation)));

    canvas.drawPath(path, paint);
    canvas.drawCircle(
        Offset(x, miniRadius), iconWidth / 2, circlePaint ?? paint);
  }

  @override
  bool shouldRepaint(_CircleBottomPainter oldDelegate) => oldDelegate != this;
}
