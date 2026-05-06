import 'package:flutter/widgets.dart';

class AppSpacing {
  // 8pt-based spacing system (with 4pt for fine-grained adjustments).
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 16;
  static const double md = 24;
  static const double lg = 32;
  static const double xl = 48;
}

class AppInsets {
  static const EdgeInsets page = EdgeInsets.all(16);
  static const EdgeInsets card = EdgeInsets.all(16);
}

class AppBreakpoints {
  static const double narrow = 520;
  static const double medium = 720;
  static const double wide = 980;
  static const double ultraWide = 1200;
}
