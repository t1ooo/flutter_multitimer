import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../util/date_time.dart';

import '../logic/timer.dart';
import '../logic/timers_cubit.dart';

// TODO: split to methods
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

  DateTime _dateTimeFromDuration(Duration duration) {
    return dateTime(
      hour: duration.inSeconds ~/ (60 * 60 * 24),
      minute: duration.inSeconds ~/ 60,
      second: duration.inSeconds % 60,
    );
  }

  @override
  Widget build(BuildContext context) {
    final verticalPadding = SizedBox(height: 30);

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
              hourField(context),
              SizedBox(width: 10),
              minuteField(context),
              SizedBox(width: 10),
              secondField(context),
            ],
          ),
          verticalPadding,
          nameField(context),
          verticalPadding,
          ButtonBar(
            alignment: MainAxisAlignment.spaceBetween,
            children: [
              deleteButton(context),
              ButtonBar(
                children: [
                  cancelButton(context),
                  saveButton(context),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget hourField(BuildContext context) {
    return Flexible(
      child: TextFormField(
        decoration: InputDecoration(
          labelText: 'h', // TODO: MAYBE: l10n
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
    );
  }

  Widget minuteField(BuildContext context) {
    return Flexible(
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
    );
  }

  Widget secondField(BuildContext context) {
    return Flexible(
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
    );
  }

  Widget nameField(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return TextFormField(
      decoration: InputDecoration(
        labelText: l10n.timerNameLabel,
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
    );
  }

  Widget deleteButton(BuildContext context) {
    final l10nMaterial = MaterialLocalizations.of(context);
    final cubit = context.read<TimersCubit>();

    return Visibility(
      visible: !isNew,
      child: ElevatedButton(
        onPressed: () {
          cubit.delete(timer);
          Navigator.pop(context);
        },
        child: Text(l10nMaterial.deleteButtonTooltip),
      ),
    );
  }

  Widget cancelButton(BuildContext context) {
    final l10nMaterial = MaterialLocalizations.of(context);

    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
      },
      child: Text(l10nMaterial.cancelButtonLabel),
    );
  }

  Widget saveButton(BuildContext context) {
    final l10nMaterial = MaterialLocalizations.of(context);
    final cubit = context.read<TimersCubit>();

    return ElevatedButton(
      onPressed: () {
        final name = nameController.text;
        final duration = Duration(
          hours: int.parse(hourController.text),
          minutes: int.parse(minuteController.text),
          seconds: int.parse(secondController.text),
        );
        final newTimer = timer.copyWith(duration: duration, name: name);
        isNew ? cubit.create(newTimer) : cubit.update(newTimer);
        Navigator.pop(context);
      },
      child: Text(l10nMaterial.saveButtonLabel),
    );
  }
}
