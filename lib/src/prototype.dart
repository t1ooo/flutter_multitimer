import 'package:flutter/material.dart';

// const pagePadding = EdgeInsets.all(20);
const pagePadding = EdgeInsets.symmetric(vertical: 30, horizontal: 20);

class HomeView extends StatelessWidget {
  HomeView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timers'),
      ),
      body: TimerList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TimerEditView(isNew: true)),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class TimerList extends StatelessWidget {
  TimerList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      // direction: Axis.vertical,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TimerListItem(),
        TimerListItem(),
        TimerListItem(),
      ],
    );
  }
}

class TimerListItem extends StatelessWidget {
  TimerListItem({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // return Text('timer list item');
    return InkWell(
      child: Padding(
        padding: pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text('name'),
            // SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.ideographic,
                  children: [
                    Text(
                      '24:00',
                      style: TextStyle(fontSize: 25),
                    ),
                    SizedBox(width: 10),
                    Text('name'),
                  ],
                ),
                // Switch(value: alarm.isActive, onChanged: (_) => onToggle()),
                ButtonBar(children: [
                  ElevatedButton(
                    child: Icon(Icons.play_arrow),
                    onPressed: () {
                      // TODO
                    },
                  ),
                  ElevatedButton(
                    child: Icon(Icons.stop),
                    onPressed: () {
                      // TODO
                    },
                  ),
                ]),
              ],
            ),
            SizedBox(height: 10),
            LinearProgressIndicator(value: 0.5),
          ],
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TimerEditView()),
        );
      },
    );
  }
}

class TimerEditView extends StatelessWidget {
  TimerEditView({Key? key, this.isNew = false}) : super(key: key);

  bool isNew;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Timer'),
      ),
      body: TimerEdit(isNew: isNew),
    );
  }
}

class TimerEdit extends StatelessWidget {
  TimerEdit({Key? key, this.isNew = false}) : super(key: key);

  bool isNew;

  @override
  Widget build(BuildContext context) {
    final verticalPadding = SizedBox(height: 30);

    return Padding(
      padding: pagePadding,
      child: Form(
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
                    initialValue: '01',
                    onSaved: (name) {
                      // TODO
                    },
                    validator: (name) {
                      // TODO
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
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
                    initialValue: '02',
                    onSaved: (name) {
                      // TODO
                    },
                    validator: (name) {
                      // TODO
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
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
                    initialValue: '03',
                    onSaved: (name) {
                      // TODO
                    },
                    validator: (name) {
                      // TODO
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
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
              initialValue: 'timer',
              onSaved: (name) {
                // TODO
              },
              validator: (name) {
                // TODO
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            verticalPadding,
            verticalPadding,
            ButtonBar(
              children: [
                if (isNew)
                  ElevatedButton(
                    child: Text('create'),
                    onPressed: () {
                      // TODO
                    },
                  )
                else
                  ElevatedButton(
                    child: Text('delete'),
                    onPressed: () {
                      // TODO
                    },
                  )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
