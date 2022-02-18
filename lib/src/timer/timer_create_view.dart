import 'package:flutter/material.dart';

import '../const/ui.dart';
import 'timer.dart';
import 'timer_form.dart';

class TimerCreateView extends StatelessWidget {
  const TimerCreateView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Timer'),
      ),
      body: Padding(
        padding: pagePadding,
        child: TimerForm(timer: draftTimer(), isNew: true),
      ),
    );
  }
}
