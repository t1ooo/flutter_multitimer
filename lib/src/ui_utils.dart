import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const pagePadding = EdgeInsets.all(20);

Widget withPadding(Widget child) =>
    Padding(padding: EdgeInsets.all(20), child: child);

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
