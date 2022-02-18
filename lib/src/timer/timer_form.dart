import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../util/date_time.dart';
import 'timer.dart';
import 'timers_cubit.dart';

class TimerForm extends StatelessWidget {
  const TimerForm({Key? key, required this.timer, required this.isNew})
      : super(key: key);

  static final hourController = TextEditingController();
  static final minuteController = TextEditingController();
  static final secondController = TextEditingController();
  static final nameController = TextEditingController();

  final bool isNew;
  final Timer timer;

  String _format(int n) {
    return n.toString().padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    final verticalPadding = SizedBox(height: 30);

    final cubit = context.read<TimersCubit>();

    final durationDateTime = _dateTimeFromDuration(timer.duration);
    hourController.text = _format(durationDateTime.hour);
    minuteController.text = _format(durationDateTime.minute);
    secondController.text = _format(durationDateTime.second);

    nameController.text = timer.name;

    return Form(
      child: Column(
        children: [
          Row(
            children: [
              Flexible(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'h',
                    border: OutlineInputBorder(),
                  ),
                  controller: hourController,
                  onFieldSubmitted: (String value) {
                    final controller = hourController;
                    if (value == '') {
                      controller.text = '00';
                      return;
                    }
                    final num = int.tryParse(value);
                    if (num == null || num < 0) {
                      controller.text = '00';
                      return;
                    }
                  },
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'm',
                    border: OutlineInputBorder(),
                  ),
                  controller: minuteController,
                  onFieldSubmitted: (String value) {
                    final controller = minuteController;
                    if (value == '') {
                      controller.text = '00';
                      return;
                    }
                    final num = int.tryParse(value);
                    if (num == null || num < 0) {
                      controller.text = '00';
                      return;
                    }
                    if (59 < num) {
                      controller.text = '59';
                      return;
                    }
                  },
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 's',
                    border: OutlineInputBorder(),
                  ),
                  controller: secondController,
                  onFieldSubmitted: (String value) {
                    final controller = secondController;
                    if (value == '') {
                      controller.text = '00';
                      return;
                    }
                    final num = int.tryParse(value);
                    if (num == null || num < 0) {
                      controller.text = '00';
                      return;
                    }
                    if (59 < num) {
                      controller.text = '59';
                      return;
                    }
                  },
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                ),
              ),
            ],
          ),
          verticalPadding,
          TextFormField(
            decoration: InputDecoration(
              labelText: 'name',
              border: OutlineInputBorder(),
            ),
            controller: nameController,
            onFieldSubmitted: (String value) {
              final controller = nameController;
              if (value == '') {
                controller.text = timer.name;
                return;
              }
            },
            textInputAction: TextInputAction.done,
          ),
          verticalPadding,
          ButtonBar(
            alignment: MainAxisAlignment.spaceBetween,
            children: [
              Visibility(
                visible: !isNew,
                child: ElevatedButton(
                  onPressed: () {
                    cubit.delete(timer);
                    Navigator.pop(context);
                  },
                  child: Text('DELETE'),
                ),
              ),
              ButtonBar(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('CANCEL'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final name = nameController.text;
                      final duration = Duration(
                        hours: int.parse(hourController.text),
                        minutes: int.parse(minuteController.text),
                        seconds: int.parse(secondController.text),
                      );
                      final newTimer =
                          timer.copyWith(duration: duration, name: name);
                      isNew ? cubit.create(newTimer) : cubit.update(newTimer);
                      Navigator.pop(context);
                    },
                    child: Text('SAVE'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

DateTime _dateTimeFromDuration(Duration duration) {
  return dateTime(
    hour: duration.inSeconds ~/ (60 * 60 * 24),
    minute: duration.inSeconds ~/ 60,
    second: duration.inSeconds % 60,
  );
}
