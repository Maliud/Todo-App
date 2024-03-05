import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/model.dart';
import 'package:todo_app/providers/selectedbox_provider.dart';
import 'package:todo_app/providers/theme_provider.dart';
import 'package:todo_app/providers/time_provider.dart';
import 'package:todo_app/screens/home_screen.dart';
import 'package:todo_app/utilities/features.dart';
import 'package:todo_app/utilities/firebase_database.dart';
import 'package:todo_app/utilities/notification_service.dart';
import 'package:todo_app/widgets/custom_widgets.dart';

TextEditingController title = TextEditingController();
TextEditingController note = TextEditingController();
TextEditingController date = TextEditingController();
TextEditingController starttime = TextEditingController();
TextEditingController endtime = TextEditingController();
TextEditingController reminder = TextEditingController();

AdditionslFeature feature = AdditionslFeature();

@override
void dispose() {
  title.dispose();
  note.dispose();
  date.dispose();
  starttime.dispose();
  endtime.dispose();
  reminder.dispose();
}

List<String> options = [
  '5 Minutes early',
  '10 Minutes early',
  '15 Minutes early',
  '30 Minutes early'
];

aftertrue(BuildContext context) {
  Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const home_screen(),
      ));
  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    content: Text(
      "Task Updated !",
      style: TextStyle(
          fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
    ),
    backgroundColor: Colors.black,
  ));
  // Navigator.of(context).pop();
}

afterfalse(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    content: Text(
      "Unable to Update Task !",
      style: TextStyle(
          fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
    ),
    backgroundColor: Colors.black,
  ));
  Navigator.of(context).pop();
}

Future<NoteModel?> GetTaskDetails(String docId) async {
  try {
    var querySnapshot = await FirebaseFirestore.instance
        .collection("User")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("Task")
        .doc(
            docId) // Use doc method instead of get for retrieving a specific document
        .get();

    if (!querySnapshot.exists) {
      print('No document found for the specified ID.');
      return null;
    }

    Map<String, dynamic> data = querySnapshot.data() as Map<String, dynamic>;
    NoteModel task = NoteModel(
      id: docId,
      title: data['title'],
      note: data['note'],
      date: data['date'],
      starttime: data['starttime'],
      endtime: data['endtime'],
      reminder: data['reminder'],
      isCompleted: data['isCompleted'],
    );

    return task;
  } catch (e) {
    print('An error occurred: $e');
    return null;
  }
}

void updatesheet(BuildContext context, String docId, String uid) async {
  GetTaskDetails(docId);
  NoteModel? task = await GetTaskDetails(docId);
  if (task != null) {
    title.text = task.title ?? '';
    note.text = task.note ?? '';
    date.text = task.date ?? '';
    starttime.text = task.starttime ?? '';
    endtime.text = task.endtime ?? '';
    reminder.text = task.reminder ?? '';
  }

  final timeProvider = Provider.of<TimeProvider>(context, listen: false);
  final provider = context.read<SelectedBoxProvider>();
  String datevalue = provider.getFormattedDate().toString();
  showModalBottomSheet(
    isScrollControlled: true,
    isDismissible: true,
    context: context,
    builder: (context) {
      return UpdateTask(
        timeProvider: timeProvider,
        docId: docId,
      );
    },
  );
}

class UpdateTask extends StatefulWidget {
  const UpdateTask(
      {super.key, required this.timeProvider, required this.docId});

  final TimeProvider timeProvider;
  final String docId;

  @override
  State<UpdateTask> createState() => _UpdateTaskState();
}

class _UpdateTaskState extends State<UpdateTask> {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final _formkey3 = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.9,
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 6,
                width: 120,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Görevi Güncelle",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Form(
                  key: _formkey3,
                  child: Column(
                    children: [
                      CustomTextFormField(
                        maxLine: 10,
                        controller: title,
                        sur: const Icon(Icons.note_add_outlined),
                        labelText: "Not Başlığı",
                        hintText: "Atıştırmalıklar Yeme",
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Title can not be empty";
                          } else if (value.length < 3) {
                            return "It needs a minimum of 3 letters";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      CustomTextFormField(
                        maxLine: 50,
                        controller: note,
                        sur: const Icon(
                          Icons.abc_outlined,
                          size: 30,
                        ),
                        labelText: "Note Açıklaması",
                        hintText: "Kola ile cips yiyeceğim!",
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Body can not be empty";
                          } else if (value.length < 3) {
                            return "It needs a minimum of 3 letters";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        enabled: false,
                        controller: date,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          labelText: 'Tarih',
                          suffixIcon: const Icon(Icons.date_range),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Date can not be empty";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.all(5),
                              child: TextFormField(
                                controller: starttime,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  labelText: "Başlangıç Zamanı",
                                  hintText: "12:15",
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      TimePicker timePicker = TimePicker(
                                        labelText: 'Zaman Seçiniz',
                                        selectedTime: TimeOfDay.now(),
                                        onSelectedTime: (TimeOfDay newTime) {
                                          final formattedTime = widget
                                              .timeProvider
                                              .formatTime(newTime, context);
                                          widget.timeProvider
                                              .updateStartTime(formattedTime);
                                          starttime.text =
                                              formattedTime; // Add this line
                                        },
                                      );
                                      timePicker.selectTime(context);
                                    },
                                    icon:
                                        const Icon(Icons.watch_later_outlined),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Start time can not be empty";
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.all(5),
                              child: TextFormField(
                                controller: endtime,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  labelText: "Bitiş Zamanı",
                                  hintText: "12:45",
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      TimePicker timePicker = TimePicker(
                                        labelText: 'Zaman Seçiniz',
                                        selectedTime: TimeOfDay.now(),
                                        onSelectedTime: (TimeOfDay newTime) {
                                          final formattedTime = widget
                                              .timeProvider
                                              .formatTime(newTime, context);
                                          widget.timeProvider
                                              .updateEndTime(formattedTime);
                                          endtime.text =
                                              formattedTime; // Add this line
                                        },
                                      );
                                      timePicker.selectTime(context);
                                    },
                                    icon:
                                        const Icon(Icons.watch_later_outlined),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "End time can not be empty";
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      DropdownButtonFormField<String>(
                        // value: options.contains(reminder.text)
                        //     ? reminder.text
                        //     : null,
                        value: reminder.text,
                        icon: const Icon(Icons.arrow_downward),
                        iconSize: 24,
                        elevation: 16,
                        style: TextStyle(
                          color: Provider.of<ThemeProvider>(context).isDarkMode
                              ? Colors.black
                              : Colors.white,
                        ),
                        onChanged: (String? newValue) {
                          // Update the dropdown value when the user selects an option
                          setState(() {
                            reminder.text = newValue!;
                          });
                        },
                        items: options.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          labelText: 'Reminder',
                          hintText: "5 Minutes early ",
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      CustomElevatedButton(
                          message: "Update Task",
                          function: () async {
                            // if (_formkey3.currentState != null &&
                            //     _formkey3.currentState!.validate()) {
                            await Updatetask(widget.docId, context);
                            // }
                          }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String cleanDate(String dirtyDate) {
  return dirtyDate.replaceAll(RegExp(r'[┤├]'), '');
}

String formatTime(DateTime time) {
  return DateFormat("hh:mm a").format(time);
}

String calculateStartTime(String selectedStartTime, String reminderOption) {
  try {
    String cleanedDate = cleanDate(date.text);
    DateTime parsedDate = DateFormat("dd MMM yyyy").parse(cleanedDate);

    DateTime startTime = DateFormat("dd MMM yyyy HH:mm").parse(
      '${DateFormat("dd MMM yyyy").format(parsedDate)} $selectedStartTime',
    );

    Duration reminderDuration = const Duration(seconds: 0);

    switch (reminderOption) {
      case '5 Minutes early':
        reminderDuration = const Duration(minutes: 5);
        break;
      case '10 Minutes early':
        reminderDuration = const Duration(minutes: 10);
        break;
      case '15 Minutes early':
        reminderDuration = const Duration(minutes: 15);
        break;
      case '30 Minutes early':
        reminderDuration = const Duration(minutes: 30);
        break;
    }

    // Subtract the reminder duration from the original start time
    startTime = startTime.subtract(reminderDuration);

    return formatTime(startTime); // Pass the DateTime object directly
  } catch (e) {
    print("Error calculating start time: $e");
    return formatTime(DateTime.now()); // Return current time as a fallback
  }
}


  Future<void> Updatetask(String docId, BuildContext context) async {
    print("running program");
    if (_formkey3.currentState != null && _formkey3.currentState!.validate()) {
        String selectedReminder = reminder.text;
       String calculatedStartTime =
          calculateStartTime(starttime.text, selectedReminder);

      NoteModel n = NoteModel(
        id: docId,
        title: title.text,
        note: note.text,
        date: date.text,
        starttime: starttime.text,
        endtime: endtime.text,
        reminder: reminder.text,
      );
      try {
        bool result = await FirebaseStore.Updatask(
            n, docId, FirebaseAuth.instance.currentUser!.uid);
        if (result == true) {
          // Deteleing Notification
          var del = NotificationService().hashString(docId.toString());
          print("this is del : $del");
          await _flutterLocalNotificationsPlugin.cancel(del);

          // Schedule Notification
          
          
 n = n.copyWith(starttime: calculatedStartTime.toString());
          NotificationService().scheduleNotification(n);
          print(n);
          // Navigator.of(context).pop();
          aftertrue(context);
        } else {
          // Navigator.of(context).pop();
          afterfalse(context);
        }
      } catch (e) {
        print("An error occurred: $e");
      }
    }
  }
}
