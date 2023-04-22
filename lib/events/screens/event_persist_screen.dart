import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/event_bloc.dart';
import '../models/event.dart';

class EventPersistScreen extends StatefulWidget {
  const EventPersistScreen({Key? key}) : super(key: key);

  @override
  State<EventPersistScreen> createState() => _EventPersistScreenState();
}

class _EventPersistScreenState extends State<EventPersistScreen> {
  final key = GlobalKey<FormState>();
  final name = TextEditingController();
  final date = TextEditingController(text: DateTime.now().toString());
  final address = TextEditingController();
  final dressCode = TextEditingController();
  final backgroundPhoto = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Event'),
      ),
      body: Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: key,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: name,
                        decoration: const InputDecoration(
                            label: Text('Name'), hintText: 'Name of the event'),
                      ),
                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: DateTimePicker(
                          controller: date,
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 1000)),
                          type: DateTimePickerType.dateTimeSeparate,
                          dateLabelText: 'Date',
                          timeLabelText: 'Time',
                        ),
                      ),
                      TextFormField(
                        controller: address,
                        decoration: const InputDecoration(
                          label: Text('Address'),
                          hintText: 'Address of the event',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(4),
              ),
              width: double.infinity,
              child: BlocBuilder<EventBloc, EventState>(
                builder: (context, state) {
                  if (state is EventLoaded) {
                    return state.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(color: Colors.white,),
                          )
                        : ElevatedButton(
                            onPressed: () {
                              context.read<EventBloc>().add(
                                    EventAdd(
                                      event: Event(
                                          name: name.text,
                                          address: address.text,
                                          date: DateTime.parse(date.text),
                                          dressCode: 'Classy',
                                          guests: const {},
                                          imageUrl: ''),
                                      onFinished: () => Navigator.pop(context),
                                    ),
                                  );
                            },
                            child: const Text('Add Event'),
                          );
                  } else {
                    return const SizedBox();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
