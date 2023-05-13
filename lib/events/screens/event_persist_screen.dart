import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../invitations/bloc/invitation_bloc.dart';
import '../../utils/platform_specific_dialog.dart';
import '../bloc/event_bloc.dart';
import '../models/event.dart';

class EventPersistScreen extends StatefulWidget {
  const EventPersistScreen({Key? key, this.event}) : super(key: key);
  final Event? event;

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
  Map<String, Response> guests = {};
  bool isValid = false;

  @override
  void initState() {
    if (widget.event != null) {
      name.text = widget.event!.name;
      date.text = widget.event!.date.toString();
      address.text = widget.event!.address;
      dressCode.text = widget.event!.dressCode;
      backgroundPhoto.text = widget.event!.imageUrl;
      guests = Map.from(widget.event!.guests);
    }
    isValid = formValid();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.event != null
            ? Text(widget.event?.name ?? 'Update Event')
            : const Text('Add Event'),
        actions: [
          if (widget.event != null)
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => BlocProvider.value(
                    value: context.read<EventBloc>(),
                    child: PlatformSpecificDialog(
                      title: const Text(
                          'Are you sure you want to delete this event?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary),
                          ),
                        ),
                        BlocBuilder<EventBloc, EventState>(
                          builder: (context, state) {
                            if (state is EventLoaded) {
                              return state.isLoading
                                  ? const Padding(
                                      padding:
                                          EdgeInsets.only(right: 20, left: 10),
                                      child: CircularProgressIndicator(),
                                    )
                                  : TextButton(
                                      onPressed: () {
                                        context.read<EventBloc>().add(
                                              EventDelete(
                                                eventId: widget.event!.id ?? '',
                                                onFinished: () {
                                                  Navigator.pop(context);
                                                  Navigator.pop(context);
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            );
                                      },
                                      child: Text(
                                        'Yes',
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    );
                            } else {
                              return const SizedBox();
                            }
                          },
                        )
                      ],
                    ),
                  ),
                );
              },
              child: Container(
                color: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: const Icon(Icons.delete),
              ),
            ),
        ],
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: name,
                        decoration: const InputDecoration(
                            label: Text('Name'), hintText: 'Name of the event'),
                        onChanged: (_) => setState(() => isValid = formValid()),
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
                        onChanged: (_) => setState(() => isValid = formValid()),
                      ),
                      const SizedBox(height: 20),
                      const Text('Guest list'),
                      BlocBuilder<EventBloc, EventState>(
                        builder: (context, state) {
                          if (state is EventLoaded) {
                            return Column(
                              children: List.generate(
                                state.guests.length,
                                (index) => Row(
                                  children: [
                                    Checkbox(
                                      value: guests
                                          .containsKey(state.guests[index].id),
                                      onChanged: (value) => setState(
                                        () {
                                          if (value ?? false) {
                                            guests[state.guests[index].id ??
                                                ''] = Response.pending;
                                          } else {
                                            guests
                                                .remove(state.guests[index].id);
                                          }
                                          isValid = formValid();
                                        },
                                      ),
                                    ),
                                    Text(
                                        state.guests[index].name ?? ''),
                                  ],
                                ),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
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
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : ElevatedButton(
                            onPressed: isValid
                                ? widget.event != null
                                    ? () {
                                        var index = state.events.indexWhere(
                                            (element) =>
                                                element.id == widget.event?.id);
                                        if (index != -1) {
                                          context.read<EventBloc>().add(
                                                EventUpdate(
                                                  event: state.events[index]
                                                      .copyWith(
                                                    name: name.text,
                                                    address: address.text,
                                                    date: DateTime.parse(
                                                        date.text),
                                                    dressCode: 'Classy',
                                                    guests: guests,
                                                    imageUrl: '',
                                                  ),
                                                  onFinished: () {
                                                    context
                                                        .read<InvitationBloc>()
                                                        .add(
                                                          InvitationFetch(
                                                            onFinished: () =>
                                                                Navigator.pop(
                                                                    context),
                                                          ),
                                                        );
                                                  },
                                                ),
                                              );
                                        }
                                      }
                                    : () {
                                        context.read<EventBloc>().add(
                                              EventAdd(
                                                event: Event(
                                                  name: name.text,
                                                  address: address.text,
                                                  date:
                                                      DateTime.parse(date.text),
                                                  dressCode: 'Classy',
                                                  guests: guests,
                                                  imageUrl: '',
                                                ),
                                                onFinished: () =>
                                                    Navigator.pop(context),
                                              ),
                                            );
                                      }
                                : null,
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(isValid
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey),
                            ),
                            child: widget.event != null
                                ? const Text(
                                    'Update Event',
                                    style: TextStyle(color: Colors.white),
                                  )
                                : const Text('Add Event',
                                    style: TextStyle(color: Colors.white)),
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

  bool formValid() {
    return name.text.isNotEmpty && address.text.isNotEmpty;
  }
}
