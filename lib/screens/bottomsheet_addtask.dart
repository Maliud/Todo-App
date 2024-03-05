import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/model.dart';
import 'package:todo_app/providers/selectedbox_provider.dart';
import 'package:todo_app/providers/theme_provider.dart';
import 'package:todo_app/providers/time_provider.dart';
import 'package:todo_app/screens/home_screen.dart';
import 'package:todo_app/utilities/features.dart';
import 'package:todo_app/utilities/firebase_database.dart';
import 'package:todo_app/widgets/custom_widgets.dart';
import 'package:todo_app/utilities/notification_service.dart';

TextEditingController title = TextEditingController();
TextEditingController note = TextEditingController();
TextEditingController date = TextEditingController();
TextEditingController starttime = TextEditingController();
TextEditingController endtime = TextEditingController();
TextEditingController reminder = TextEditingController();

@override
void dispose() {
  title.dispose();
  note.dispose();
  date.dispose();
  starttime.dispose();
  endtime.dispose();
  reminder.dispose();
}

AdditionslFeature feature = AdditionslFeature();

List<String> options = [
  '5 Dakika erken',
  '10 Dakika erken',
  '15 Dakika erken',
  '30 Dakika erken'
];

aftertrue(BuildContext context) {
  Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const home_screen(),
      ));
  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    content: Text(
      "Görev Ekleri !",
      style: TextStyle(
          fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
    ),
    backgroundColor: Colors.black,
  ));
  // Navigator.of(context).pop();
}

gettask(BuildContext context) {
  final bool expands;
  final timeProvider = Provider.of<TimeProvider>(context, listen: false);
  final provider = context.read<SelectedBoxProvider>();
  String datevalue = provider.getFormattedDate().toString();

  print(datevalue);

  date.text = datevalue;
  reminder.text = '5 Dakika erken';
  showModalBottomSheet(
    isScrollControlled: true,
    isDismissible: true,
    context: context,
    builder: (context) {
      return TaskForm(timeProvider: timeProvider);
    },
  );
}

class TaskForm extends StatefulWidget {
  const TaskForm({
    super.key,
    required this.timeProvider,
  });

  final TimeProvider timeProvider;

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formkey2 = GlobalKey<FormState>();
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
                "Görevi Ekle",
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
                  key: _formkey2,
                  child: Column(
                    children: [
                      CustomTextFormField(
                        maxLine: 10,
                        controller: title,
                        sur: const Icon(Icons.note_add_outlined),
                        labelText: "Not Başlığı",
                        hintText: "ör. Ders Çalışma Saati Geldi",
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Başlık boş olamaz";
                          } else if (value.length < 3) {
                            return "En az 3 harf olması gerekiyor";
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
                        labelText: "Not Açıklaması",
                        hintText: "ör. Ders Çalışma Maddeleri",
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Açıklama boş olamaz";
                          } else if (value.length < 3) {
                            return "En az 3 harf olması gerekiyor";
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
                            return "Tarih boş olamaz";
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
                                keyboardType: TextInputType.none,
                                controller: starttime,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  labelText: "Başlama Saati",
                                  hintText: "12:15",
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      FocusScope.of(context).unfocus();
                                      TimePicker timePicker = TimePicker(
                                        labelText: 'Saat Seçiniz',
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
                                    return "Başlangıç zamanı boş olamaz";
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
                                keyboardType: TextInputType.none,
                                controller: endtime,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  labelText: "Bitiş Saati",
                                  hintText: "12:45",
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      FocusScope.of(context).unfocus();
                                      TimePicker timePicker = TimePicker(
                                        labelText: 'Saat Seçiniz',
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
                                    return "Bitiş zamanı boş olamaz";
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
                        value: options[0],
                        icon: const Icon(Icons.arrow_downward),
                        iconSize: 24,
                        elevation: 16,
                        style: TextStyle(
                            color:
                                Provider.of<ThemeProvider>(context).isDarkMode
                                    ? Colors.black
                                    : Colors.white),
                        onChanged: (String? newValue) {
                          // Update the dropdown value when the user selects an option

                          reminder.text = newValue!;
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
                          labelText: 'Hatırlatıcı',
                          hintText: "5 Dakika erken ",
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      CustomElevatedButton(
                        message: "Görev Ekle",
                        function: () async {
                          if (_formkey2.currentState != null &&
                              _formkey2.currentState!.validate()) {
                            await sendtask(context);
                          }
                        },
                      ),
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
      case '5 Dakika erken':
        reminderDuration = const Duration(minutes: 5);
        break;
      case '10 Dakika erken':
        reminderDuration = const Duration(minutes: 10);
        break;
      case '15 Dakika erken':
        reminderDuration = const Duration(minutes: 15);
        break;
      case '30 Dakika erken':
        reminderDuration = const Duration(minutes: 30);
        break;
    }

    // Subtract the reminder duration from the original start time
    startTime = startTime.subtract(reminderDuration);

    return formatTime(startTime); // Pass the DateTime object directly
  } catch (e) {
    print("Başlangıç zamanı hesaplanırken hata oluştu: $e");
    return formatTime(DateTime.now()); // Return current time as a fallback
  }
}

  Future<void> sendtask(BuildContext context) async {
    print("Program Çalışıyor.");
    if (_formkey2.currentState != null && _formkey2.currentState!.validate()) {
      String selectedReminder = reminder.text;

      // Calculate the start time for the notification
      String calculatedStartTime =
          calculateStartTime(starttime.text, selectedReminder);

      print("Bu zamandan önce : ${calculatedStartTime.toString()}");
      NoteModel n = NoteModel(
        title: title.text,
        note: note.text,
        date: date.text,
        starttime: starttime.text,
        endtime: endtime.text,
        reminder: reminder.text,
      );
      print(n);
      try {
        List<dynamic> result = await FirebaseStore.Savetask(n, date.text);
        if (result[0] == true) {
          String docId = result[1];
          n = n.copyWith(id: docId);
          n = n.copyWith(starttime: calculatedStartTime.toString());
          NotificationService().scheduleNotification(n);
          // Extract the document ID from the result

          // Update the NoteModel with the retrieved document ID
          n = n.copyWith(id: docId);

          title.text = '';
          note.text = '';
          date.text = '';
          starttime.text = '';
          endtime.text = '';
          reminder.text = '';
          print("Done Data Saved");
          aftertrue(context);
        } else if (result[0] is String) {
          print(result[0]);
        } else {
          print("Something went wrong ");
        }
      } catch (e) {
        print("An error occurred: $e");
      }
    }
  }
}
