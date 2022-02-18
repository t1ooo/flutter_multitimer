import 'package:flutter/material.dart';

import '../style/style.dart';
import 'timer.dart';
import 'timer_form.dart';

class TimerEditView extends StatelessWidget {
  const TimerEditView({Key? key, required this.timer})
      : super(key: key);

  final Timer timer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Timer'),
      ),
      body: Padding(
        padding: pagePadding,
        child: TimerForm(timer: timer, isNew: false),
      ),
    );
  }
}
