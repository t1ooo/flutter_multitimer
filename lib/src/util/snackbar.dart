import 'package:flutter/material.dart';

void showErrorSnackBar(BuildContext context, String error) {
  WidgetsBinding.instance?.addPostFrameCallback((_) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
  });
}
