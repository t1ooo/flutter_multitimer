import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Widget whenDebug(Widget Function() builder) {
  return kDebugMode
      ? Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red),
          ),
          child: builder(),
        )
      : Container();
}
