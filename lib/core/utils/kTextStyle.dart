import 'package:flutter/material.dart';

TextStyle kTextStyle({double size = 20, isBold = false, color = Colors.black}) {
  return TextStyle(
    fontSize: size,
    color: color,
    fontWeight: isBold == false ? FontWeight.normal : FontWeight.bold,
  );
}
