import 'package:flutter/material.dart';

import 'timer_create_view.dart';

class TimerCreateButton extends StatelessWidget {
  const TimerCreateButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TimerCreateView(),
          ),
        );
      },
      child: Icon(Icons.add),
    );
  }
}
