import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../util/date_time.dart';

import '../logic/timer.dart';
import '../logic/timers_cubit.dart';

class TimerForm extends StatelessWidget {
  const TimerForm({
    Key? key,
    required this.timer,
    required this.isNew,
  }) : super(key: key);

  static final _hourController = TextEditingController();
  static final _minuteController = TextEditingController();
  static final _secondController = TextEditingController();
  static final _nameController = TextEditingController();

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
    _hourController.text = _format(durationDateTime.hour);
    _minuteController.text = _format(durationDateTime.minute);
    _secondController.text = _format(durationDateTime.second);

    _nameController.text = timer.name;

    return Form(
      child: Column(
        children: [
          Row(
            children: [
              _hourField(context),
              SizedBox(width: 10),
              _minuteField(context),
              SizedBox(width: 10),
              _secondField(context),
            ],
          ),
          verticalPadding,
          nameField(context),
          verticalPadding,
          ButtonBar(
            alignment: MainAxisAlignment.spaceBetween,
            children: [
              _deleteButton(context),
              ButtonBar(
                children: [
                  _cancelButton(context),
                  _saveButton(context),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _hourField(BuildContext context) {
    return Flexible(
      child: TextFormField(
        decoration: InputDecoration(
          labelText: 'h', // TODO: MAYBE: l10n
          border: OutlineInputBorder(),
        ),
        controller: _hourController,
        onFieldSubmitted: (String value) {
          final controller = _hourController;
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

  Widget _minuteField(BuildContext context) {
    return Flexible(
      child: TextFormField(
        decoration: InputDecoration(
          labelText: 'm',
          border: OutlineInputBorder(),
        ),
        controller: _minuteController,
        onFieldSubmitted: (String value) {
          final controller = _minuteController;
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

  Widget _secondField(BuildContext context) {
    return Flexible(
      child: TextFormField(
        decoration: InputDecoration(
          labelText: 's',
          border: OutlineInputBorder(),
        ),
        controller: _secondController,
        onFieldSubmitted: (String value) {
          final controller = _secondController;
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
      controller: _nameController,
      onFieldSubmitted: (String value) {
        final controller = _nameController;
        if (value == '') {
          controller.text = timer.name;
          return;
        }
      },
      textInputAction: TextInputAction.done,
    );
  }

  Widget _deleteButton(BuildContext context) {
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

  Widget _cancelButton(BuildContext context) {
    final l10nMaterial = MaterialLocalizations.of(context);

    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
      },
      child: Text(l10nMaterial.cancelButtonLabel),
    );
  }

  Widget _saveButton(BuildContext context) {
    final l10nMaterial = MaterialLocalizations.of(context);
    final cubit = context.read<TimersCubit>();

    return ElevatedButton(
      onPressed: () {
        final name = _nameController.text;
        final duration = Duration(
          hours: int.parse(_hourController.text),
          minutes: int.parse(_minuteController.text),
          seconds: int.parse(_secondController.text),
        );
        final newTimer = timer.copyWith(duration: duration, name: name);
        isNew ? cubit.create(newTimer) : cubit.update(newTimer);
        Navigator.pop(context);
      },
      child: Text(l10nMaterial.saveButtonLabel),
    );
  }
}
