import 'package:flutter/material.dart';

class FatigueChartLayout {
  static bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  static double leftPadding(BuildContext context) =>
      isLandscape(context) ? 8.0 : 32.0;

  static double rightPadding(BuildContext context) =>
      isLandscape(context) ? 72.0 : 8.0;

  static double bottomLabelSpace(BuildContext context) =>
      isLandscape(context) ? 6.0 : 0.0;

  static double labelFontSize(BuildContext context) =>
      isLandscape(context) ? 10.0 : 14.0;

  static double chartLabelFontSize(BuildContext context) =>
      isLandscape(context) ? 10.0 : 10.0;

  static double chartValueFontSize(BuildContext context) =>
      isLandscape(context) ? 12.0 : 14.0;

  // 你可以依需求擴充更多屬性
}
