import 'package:flutter/material.dart';

abstract final class Responsive {
  static const _tabletBreakpoint = 600.0;
  static const _desktopBreakpoint = 900.0;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < _tabletBreakpoint;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= _tabletBreakpoint && width < _desktopBreakpoint;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= _desktopBreakpoint;

  static int characterGridCrossAxisCount(BuildContext context) {
    if (isDesktop(context)) return 4;
    if (isTablet(context)) return 4;
    return 3;
  }

 
}
