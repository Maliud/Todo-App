import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:todo_app/models/model.dart';
import 'package:todo_app/providers/dateTime_provider.dart';
import 'package:todo_app/providers/selectedbox_provider.dart';
import 'package:todo_app/providers/task_provider.dart';
import 'package:todo_app/providers/theme_provider.dart';
import 'package:todo_app/screens/bottomsheet_addtask.dart';
import 'package:todo_app/screens/bottomsheet_profile.dart';
import 'package:todo_app/screens/bottomsheet_updatetask.dart';
import 'package:todo_app/screens/home_shimmer.dart';
import 'package:todo_app/utilities/firebase_database.dart';
import 'package:todo_app/utilities/notification_service.dart';


class home_screen extends StatefulWidget {
  const home_screen({super.key});

  @override
  State<home_screen> createState() => _home_screenState();
}

class _home_screenState extends State<home_screen> {
  StreamSubscription? connection;
  bool isoffline = false;

  checkinternet(BuildContext context) {
    connection = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      // whenevery connection status is changed.
      if (result == ConnectivityResult.none) {
        //there is no any connection
        setState(() {
          isoffline = true;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('İnternete bağlı değilsiniz 😞',
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
          ));
        });
      } else if (result == ConnectivityResult.mobile) {
        //connection is mobile data network
        setState(() {
          isoffline = false;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
              'Tekrar Hoşgeldiniz 👍🏻',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ));
        });
      } else if (result == ConnectivityResult.wifi) {
        //connection is from wifi
        setState(() {
          isoffline = false;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Tekrar Hoşgeldiniz 👍🏻',
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.green,
          ));
        });
      } else if (result == ConnectivityResult.ethernet) {
        //connection is from wired connection
        setState(() {
          isoffline = false;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Tekrar Hoşgeldiniz 👍🏻 👍🏻',
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.green,
          ));
        });
      } else if (result == ConnectivityResult.bluetooth) {
        //connection is from bluetooth threatening
        setState(() {
          isoffline = false;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Tekrar Hoşgeldiniz 👍🏻',
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.green,
          ));
        });
      }
    });
  }

  String? id;
  String? title;
  String? notebody;
  String? starttime;
  String? endtime;
  String? name;
  String? email;

  List<NoteModel> tasks = [];
  List<NoteModel> donetasks = [];

  List<Color> boxcolors = [
    Colors.deepPurple,
    const Color.fromARGB(255, 229, 91, 81),
    const Color.fromARGB(255, 61, 117, 63),
    const Color.fromARGB(255, 0, 137, 249),
    Colors.deepPurple,
    const Color.fromARGB(255, 229, 52, 111),
    Colors.purple,
    Colors.teal,
    Colors.deepOrange,
    Colors.deepPurple,
    const Color.fromARGB(255, 64, 77, 149)
  ];

  // Function to get the current date in a specific format

  // Function to get the current time in a specific format
  userinfo() async {
    try {
      Usermodel user = await FirebaseStore.userinfo();
      setState(() {
        name = user.name;
        email = user.email;
      });
    } catch (e) {
      // Handle the error here
      print("An error occurred: $e");
    }
    // print(del['email']);
  }

  String formatDate(Map<String, dynamic>? dateMap) {
    if (dateMap == null) {
      return "";
    } else {
      String day = dateMap['date'].toString();
      String month = dateMap['month'];
      String year = dateMap['year'].toString();
      return "$day $month $year";
    }
  }

  @override
  void initState() {
    super.initState();
    userinfo();
    checkinternet(context);
    // getcurrentmonth();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final selectedBoxProvider = context.read<SelectedBoxProvider>();
      final dates = DatesProvider();
      List<dynamic> dateList = dates.showDates();
      selectedBoxProvider.updateSelectedBox(dateList[0]);
      todaydate();

      //  to find today date and pass to throw notiiccation functions
      // DateTime now = DateTime.now();
      // String formattedDate = DateFormat('d MMM y').format(now);
      // print(" date : -- " + formattedDate);
      // FirebaseStore.thrownotificaion('7 Nov 2023');
      todaydonedate();
    });
  }

   todaydate() async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('d MMM y').format(now);
    print(formattedDate);

    tasks = await taskProvider.fetchTasks(formattedDate);
  }

  void todaydonedate() async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('d MMM y').format(now);

    donetasks = await taskProvider.fetchdoneTasks(formattedDate);
  }

  @override
  Widget build(BuildContext context) {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    // for checking mail is verified or not to change mail icon

    final selectedBoxProvider =
        Provider.of<SelectedBoxProvider>(context, listen: true);
    final selectedbox = selectedBoxProvider;
    final taskProvider = Provider.of<TaskProvider>(context);
    final dates = DatesProvider();
    List<dynamic> dateList = dates.showDates();

    List<NoteModel> tasks = taskProvider.tasks;
    List<NoteModel> donetasks = taskProvider.completedtask;

    showtask() async {
      tasks =
          await taskProvider.fetchTasks(formatDate(selectedbox.selectedBox));
      donetasks = await taskProvider
          .fetchdoneTasks(formatDate(selectedbox.selectedBox));
    }

    showdonetask() async {
      donetasks = await taskProvider
          .fetchdoneTasks(formatDate(selectedbox.selectedBox));
      print(donetasks);
    }

    Future<bool> checkNotificationPermission() async {
      var status = await Permission.notification.status;
      if (status.isGranted) {
        return true;
      } else {
        // Request notification permission
        await Permission.notification.request();
        return await Permission.notification.status.isGranted;
      }
    }


    final screenhight = MediaQuery.of(context).size.height;
    final themeprovider = Provider.of<ThemeProvider>(context);
    return name == null
        ? const home_shimmer()
        : Scaffold(
            body: SafeArea(
                child: SingleChildScrollView(
              child: Column(children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height / 12,
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        right: 10, left: 10, top: 5, bottom: 5),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                 

                                  showOptions(context, name.toString(),
                                      email.toString());
                                },
                                child: const CircleAvatar(
                                  minRadius: 25,
                                  maxRadius: 25,
                                  backgroundColor: Colors.blue,
                                  child: Icon(
                                    Icons.person_sharp,
                                    size: 25,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              // IconButton(
                              //     onPressed: () {
                              //       sign_out();
                              //     },
                              //     icon: const Icon(
                              //       Icons.logout_outlined,
                              //     ))
                            ],
                          ),
                          FittedBox(
                            child: Container(
                              constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width - 130),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: RichText(
                                  text: TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: "Merhaba, ",
                                        style: TextStyle(
                                          color: themeprovider.isDarkMode
                                              ? Colors.black
                                              : Colors.white,
                                          fontSize: 18,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                      TextSpan(
                                        text: "$name ",
                                        style: TextStyle(
                                          color: themeprovider.isDarkMode
                                              ? Colors.black
                                              : Colors.white,
                                          fontSize: 25,
                                          fontWeight: FontWeight.w200,
                                        ),
                                      ),
                                    ],
                                  ),
                                  overflow: TextOverflow
                                      .ellipsis, // Add this line to handle text overflow
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                                onPressed: () {
                                  themeprovider.toggleTheme();
                                },
                                icon: Icon(
                                  themeprovider.getThemeIcon(),
                                  size: 25,
                                )),
                          )
                        ]),
                  ),
                ),
                Container(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            // get task bottom model sheet appear heer
                            selectedbox.getFormattedDate();
                            gettask(context);
                          },
                          child: Container(
                            height: MediaQuery.of(context).size.height / 16,
                            width: MediaQuery.of(context).size.width / 3,
                            clipBehavior: Clip.none,
                            decoration: BoxDecoration(
                                color: Colors.deepPurple,
                                borderRadius: BorderRadius.circular(10)),
                            child: const Padding(
                              padding: EdgeInsets.only(right: 10, left: 8),
                              child: FittedBox(
                                child: Row(children: [
                                  Text(
                                    "Görev Ekle",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                  Icon(
                                    Icons.add,
                                    size: 25,
                                    color: Colors.white,
                                  ),
                                ]),
                              ),
                            ),
                          ),
                        ),
                        Text(
                          selectedbox.getFormattedDate(),
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.grey[650],
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),

                // Code Starts From here ------------------------

// ...

                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: dateList.length,
                      itemBuilder: (context, index) {
                        final item = dateList[index];
                        final color = boxcolors[index % boxcolors.length];
                        final selectedBoxValue = selectedbox.selectedBox;

                        return Padding(
                          padding: const EdgeInsets.only(right: 5, left: 3),
                          child: GestureDetector(
                            onTap: () async {
                              selectedbox.updateSelectedBox(item);
                              showtask();
                              showdonetask();
                            },
                            child: Container(
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.deepPurple.withOpacity(1)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey
                                        .withOpacity(0.2), // Shadow color
                                    spreadRadius: 2, // Spread radius
                                    blurRadius: 2, // Blur radius
                                    offset: const Offset(0, 3), // Offset
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(10),
                                // color: Colors.deepPurple
                                // color: color
                                color: selectedBoxValue['year'] ==
                                            item['year'] &&
                                        selectedBoxValue['month'] ==
                                            item['month'] &&
                                        selectedBoxValue['date'] ==
                                            item['date'] &&
                                        selectedBoxValue['dayOfWeek'] ==
                                            item['dayOfWeek']
                                    ? Colors.deepPurple
                                    : Colors.deepPurple.withOpacity(0.4),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    FittedBox(
                                      child: Text(
                                        item['month'] ?? '',
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: themeprovider.isDarkMode
                                              ? Colors.white
                                              : Colors.white,
                                          // selectedbox == index
                                          // ? Colors.white
                                          // : Colors.white
                                        ),
                                      ),
                                    ),
                                    Text(
                                      item['date'] != null
                                          ? item['date'].toString()
                                          : '',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,

                                        // selectedbox == index
                                        // ? Colors.white
                                        // : Colors.white
                                      ),
                                    ),
                                    FittedBox(
                                      child: Text(
                                        item['dayOfWeek'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                          // selectedbox == index
                                          // ? Colors.white
                                          // : Colors.white
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Second Container Starts

                Padding(
                    padding: const EdgeInsets.only(right: 10, left: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                            colors: [
                              Colors.purple[200]!.withOpacity(1),
                              Colors.deepPurple.withOpacity(0.5)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight),
                      ),
                      width: MediaQuery.of(context).size.width,
                      height: screenhight / 1.9,
                      child: tasks.isNotEmpty && tasks != 0
                          ? Padding(
                              padding: const EdgeInsets.only(top: 3, bottom: 5),
                              child: ListView.builder(
                                itemCount: tasks.length,
                                itemBuilder: (context, index) {
                                  final currentTask = tasks[index];

                                  final color =
                                      boxcolors[index % boxcolors.length];

                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        top: 5, bottom: 5, left: 5, right: 5),
                                    child: GestureDetector(
                                      onTap: () {},
                                      onLongPress: () {
                                        showCupertinoModalPopup(
                                          context: context,
                                          builder: (context) {
                                            return CupertinoActionSheet(
                                              actions: [
                                                Material(
                                                  child: Container(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height /
                                                              3,
                                                      width: 300,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          color: color),
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                FittedBox(
                                                                  child:
                                                                      Container(
                                                                    constraints: BoxConstraints(
                                                                        maxWidth:
                                                                            MediaQuery.of(context).size.width -
                                                                                100,
                                                                        maxHeight:
                                                                            MediaQuery.of(context).size.height /
                                                                                8),
                                                                    child:
                                                                        ListView(
                                                                      shrinkWrap:
                                                                          true,
                                                                      children: [
                                                                        Text(
                                                                          "Başlık :  ${currentTask.title ?? ""}",
                                                                          style: const TextStyle(
                                                                              letterSpacing: 2,
                                                                              fontSize: 20,
                                                                              color: Colors.white,
                                                                              fontWeight: FontWeight.bold),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                                FittedBox(
                                                                  child:
                                                                      Container(
                                                                    constraints: BoxConstraints(
                                                                        maxWidth:
                                                                            MediaQuery.of(context).size.width -
                                                                                100,
                                                                        maxHeight:
                                                                            MediaQuery.of(context).size.height /
                                                                                10),
                                                                    child:
                                                                        SingleChildScrollView(
                                                                      scrollDirection:
                                                                          Axis.vertical,
                                                                      child:
                                                                          Text(
                                                                        // "Note 1",
                                                                        "Görev : ${currentTask.note ?? ""}",
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                18,
                                                                            color:
                                                                                Colors.white,
                                                                            fontWeight: FontWeight.w300),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    const Icon(
                                                                      Icons
                                                                          .lock_clock,
                                                                      size: 28,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                    Text(
                                                                      // "    02:04 PM - 02:19 PM",
                                                                      "    ${currentTask.starttime} - ${currentTask.endtime}",

                                                                      style:
                                                                          const TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(10.0),
                                                            child: Container(
                                                              child: Row(
                                                                children: [
                                                                  Container(
                                                                    height:
                                                                        1000,
                                                                    width: 1,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 8,
                                                                  ),
                                                                  const RotatedBox(
                                                                    quarterTurns:
                                                                        3, // Set the number of clockwise quarter turns
                                                                    child: Text(
                                                                      'Görev',
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            13,
                                                                        color: Colors
                                                                            .white,
                                                                      ), // Define the text style
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      )),
                                                ),
                                                const SizedBox(
                                                  height: 30,
                                                ),
                                                CupertinoActionSheetAction(
                                                  child: Text(
                                                    "Tamamlandı Olarak İşaretle 🙂",
                                                    style: TextStyle(
                                                        color: Colors
                                                            .grey.shade600),
                                                  ),
                                                  onPressed: () async {
                                                    DateTime now =
                                                        DateTime.now();

                                                    // Format the time using DateFormat
                                                    String formattedTime =
                                                        DateFormat('hh:mm a')
                                                            .format(now);
                                                    bool rs = await FirebaseStore
                                                        .MarkasRead(
                                                            currentTask.id
                                                                .toString(),
                                                            FirebaseAuth
                                                                .instance
                                                                .currentUser!
                                                                .uid,
                                                            formattedTime);
                                                    if (rs = true) {
                                                      Navigator.pushReplacement(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                const home_screen(),
                                                          ));
                                                      final scaffoldContext =
                                                          ScaffoldMessenger.of(
                                                              context);
                                                      scaffoldContext
                                                          .showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                            "Görev Tamamlandı 👍🏻",
                                                            style: TextStyle(
                                                              fontSize: 15,
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          backgroundColor:
                                                              Colors.black,
                                                        ),
                                                      );
                                                    } else {
                                                      print(
                                                          "Something is wrong while deleting the Task");
                                                    }
                                                  },
                                                ),
                                                CupertinoActionSheetAction(
                                                  child: Text(
                                                    "Görevi Paylaş",
                                                    style: TextStyle(
                                                        color: Colors
                                                            .grey.shade600),
                                                  ),
                                                  onPressed: () async {
                                                    await Share.share(
                                                        "🚀 Görev Detayı 🚀\n\n"
                                                        "📌 Görev Başlığı: ${currentTask.title}\n"
                                                        "📋 Görev Açıklaması: ${currentTask.note}\n"
                                                        "📆 Görev Tarihi: ${currentTask.date}\n"
                                                        "⏰ Görev Başlangıç Tarihi: ${currentTask.starttime}\n"
                                                        "⌛ Görev Bitiş Tarihi: ${currentTask.endtime}\n"
                                                        "🚧 Görev Durumu: Devam Ediyor\n\n"
                                                        "📝 Son teknoloji Todo uygulaması ile sorunsuz görev yönetimine devam edin!\n\n"
                                                        "🌟 GitHub'daki Todo uygulamasının sonsuz olanaklarını keşfedin. Görev yönetimi yolculuğunuzu birlikte basitleştirelim.\n"
                                                        "GitHub Link: https://github.com/Maliud/Todo-App",
                                                        subject:
                                                            "📅 Todo Uygulamasından Görev Ayrıntıları 📝");
                                                  },
                                                ),
                                                CupertinoActionSheetAction(
                                                  child: Text(
                                                    "Düzenle",
                                                    style: TextStyle(
                                                        color: Colors
                                                            .grey.shade600),
                                                  ),
                                                  onPressed: () {
                                                    updatesheet(
                                                        context,
                                                        currentTask.id
                                                            .toString(),
                                                        FirebaseAuth.instance
                                                            .currentUser!.uid);
                                                  },
                                                ),
                                                CupertinoActionSheetAction(
                                                  child: Text(
                                                    "Sil",
                                                    style: TextStyle(
                                                        color: Colors
                                                            .grey.shade600),
                                                  ),
                                                  onPressed: () async {
                                                    bool rs = await FirebaseStore
                                                        .DeleteTask(
                                                            currentTask.id
                                                                .toString(),
                                                            FirebaseAuth
                                                                .instance
                                                                .currentUser!
                                                                .uid);
                                                    if (rs = true) {
                                                      var del =
                                                          NotificationService()
                                                              .hashString(
                                                                  currentTask.id
                                                                      .toString());
                                                      print(
                                                          "del: : $del");
                                                      await flutterLocalNotificationsPlugin
                                                          .cancel(del);
                                                      Navigator.pushReplacement(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                const home_screen(),
                                                          ));
                                                      final scaffoldContext =
                                                          ScaffoldMessenger.of(
                                                              context);
                                                      scaffoldContext
                                                          .showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                            "Görev Başarıyla Silindi! ",
                                                            style: TextStyle(
                                                              fontSize: 15,
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          backgroundColor:
                                                              Colors.black,
                                                        ),
                                                      );
                                                    } else {
                                                      print(
                                                          "Görevi silerken bir şeyler yanlış gitti.");
                                                    }
                                                  },
                                                ),
                                              ],
                                              cancelButton:
                                                  CupertinoActionSheetAction(
                                                isDefaultAction: true,
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text(
                                                  "İptal Et",
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      child: Container(
                                          height: 110,
                                          width: 300,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              color: color),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    FittedBox(
                                                      child: Container(
                                                        constraints: BoxConstraints(
                                                            maxHeight: 20,
                                                            maxWidth: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width -
                                                                100),
                                                        child:
                                                            SingleChildScrollView(
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          child: Text(
                                                            // "Note 1",
                                                            currentTask.title ??
                                                                "",
                                                            style: const TextStyle(
                                                                fontSize: 18,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w300),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        const Icon(
                                                          Icons.lock_clock,
                                                          size: 28,
                                                          color: Colors.white,
                                                        ),
                                                        Text(
                                                          // "    02:04 PM - 02:19 PM",
                                                          "    ${currentTask.starttime} - ${currentTask.endtime}",

                                                          style:
                                                              const TextStyle(
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    FittedBox(
                                                      child: Container(
                                                        constraints: BoxConstraints(
                                                            maxHeight: 25,
                                                            maxWidth: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width -
                                                                100),
                                                        child:
                                                            SingleChildScrollView(
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          child: Text(
                                                            // "Note 1",
                                                            currentTask.note ??
                                                                "",
                                                            style: const TextStyle(
                                                                fontSize: 18,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w300),
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                child: Container(
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        height: 100,
                                                        width: 1,
                                                        color: Colors.white,
                                                      ),
                                                      const SizedBox(
                                                        width: 8,
                                                      ),
                                                      const RotatedBox(
                                                        quarterTurns:
                                                            3, // Set the number of clockwise quarter turns
                                                        child: Text(
                                                          'Görev',
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            color: Colors.white,
                                                          ), // Define the text style
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],
                                          )),
                                    ),
                                  );
                                },
                              ),
                            )
                          : SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: screenhight / 1.9,
                              child: Center(
                                  child: FittedBox(
                                child: GestureDetector(
                                  onTap: () {
                                    gettask(context);
                                  },
                                  child: Column(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/images/empty_todo.svg',
                                        height: 200,
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      const Text(
                                        "Verimliliğinizi Artırmak İçin Bazı Görevler Ekleyin!",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontStyle: FontStyle.normal,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ))),

                      // second Container strts from here
                    )),

                //  i want to show another list in sizedbox with same features and funtions only list is changes from task to donetask and all other things are same how can i do that , one more feature if donetask list is empty then it will srink but show the container

                const SizedBox(
                  height: 10,
                ),
                donetasks.isNotEmpty && donetasks != 0
                    ? Container(
                        height: 30,
                        width: 200,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.green.withOpacity(0.2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 1,
                              )
                            ]),
                        child: const Center(
                          child: Text(
                            "Tamamlanan Görevler",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox(),
                const SizedBox(
                  height: 20,
                ),
                donetasks.isNotEmpty && donetasks != 0
                    ? Padding(
                        padding: const EdgeInsets.only(right: 10, left: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                                colors: [
                                  Colors.purple[200]!.withOpacity(1),
                                  Colors.deepPurple.withOpacity(0.5)
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight),
                          ),
                          width: MediaQuery.of(context).size.width,
                          height: screenhight / 1.9,
                          child: donetasks.isNotEmpty && donetasks != 0
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      top: 3, bottom: 3, right: 3, left: 3),
                                  child: ListView.builder(
                                    itemCount: donetasks.length,
                                    itemBuilder: (context, index) {
                                      final currentdoneTask = donetasks[index];
                                      final color =
                                          boxcolors[index % boxcolors.length];

                                      return Padding(
                                        padding: const EdgeInsets.only(
                                            top: 5,
                                            bottom: 5,
                                            left: 5,
                                            right: 5),
                                        child: GestureDetector(
                                          onTap: () {
                                            print(currentdoneTask);
                                          },
                                          onLongPress: () {
                                            showCupertinoModalPopup(
                                              context: context,
                                              builder: (context) {
                                                return CupertinoActionSheet(
                                                  actions: [
                                                    Material(
                                                      child: Container(
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height /
                                                            3,
                                                        width: 300,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          color: color,
                                                        ),
                                                        child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      const Text(
                                                                        "Görev Şu Saatte Tamamlandı : ",
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              15,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                          width:
                                                                              5),
                                                                      Text(
                                                                        currentdoneTask.completedTime ??
                                                                            '',
                                                                        style: const TextStyle(
                                                                            color:
                                                                                Colors.white),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Container(
                                                                    constraints:
                                                                        BoxConstraints(
                                                                      maxWidth:
                                                                          MediaQuery.of(context).size.width -
                                                                              100,
                                                                      maxHeight:
                                                                          MediaQuery.of(context).size.height /
                                                                              8,
                                                                    ),
                                                                    child: ListView(
                                                                        shrinkWrap:
                                                                            true,
                                                                        children: [
                                                                          Text(
                                                                            "Başlık :  ${currentdoneTask.title ?? ""}",
                                                                            style:
                                                                                const TextStyle(
                                                                              letterSpacing: 2,
                                                                              fontSize: 20,
                                                                              color: Colors.white,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                        ]),
                                                                  ),
                                                                  Container(
                                                                    constraints:
                                                                        BoxConstraints(
                                                                      maxWidth:
                                                                          MediaQuery.of(context).size.width -
                                                                              100,
                                                                      maxHeight:
                                                                          MediaQuery.of(context).size.height /
                                                                              10,
                                                                    ),
                                                                    child:
                                                                        ListView(
                                                                      shrinkWrap:
                                                                          true,
                                                                      children: [
                                                                        Text(
                                                                          currentdoneTask.note ??
                                                                              "",
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                18,
                                                                            color:
                                                                                Colors.white,
                                                                            fontWeight:
                                                                                FontWeight.w300,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(
                                                                      10.0),
                                                              child: Container(
                                                                child: Row(
                                                                  children: [
                                                                    Container(
                                                                      height:
                                                                          1000,
                                                                      width: 1,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                            8),
                                                                    const RotatedBox(
                                                                      quarterTurns:
                                                                          3,
                                                                      child:
                                                                          Text(
                                                                        'Görev',
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              13,
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 30),
                                                    CupertinoActionSheetAction(
                                                      child: Text(
                                                        "Görevi Paylaş",
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey.shade600),
                                                      ),
                                                      onPressed: () async {
                                                        await Share.share(
                                                          "🚀 Görev Detayı 🚀\n\n"
                                                          "📌 Görev Başlığı: ${currentdoneTask.title}\n"
                                                          "📋 Görev Açıklaması: ${currentdoneTask.note}\n"
                                                          "🗓 Görev Tarihi: ${currentdoneTask.date}\n"
                                                          "⏰ Görev Başlama Tarihi: ${currentdoneTask.starttime}\n"
                                                          "🎉 Görev Tamamlama Süresi: ${currentdoneTask.completedTime}\n\n"
                                                          "✅ Görev Tamamlandı! Son teknoloji Todo uygulaması ile sorunsuz görev yönetimine girin!\n\n"
                                                          "🌟 GitHub'daki Todo uygulamasının sonsuz olanaklarını keşfedin. Görev yönetimi yolculuğunuzu birlikte basitleştirelim.\n"
                                                          "GitHub Link: https://github.com/Maliud/Todo-App",
                                                          subject:
                                                              "📅 Todo Uygulamasından Görev Ayrıntıları 📝",
                                                        );
                                                      },
                                                    ),
                                                    CupertinoActionSheetAction(
                                                      child: Text(
                                                        "Sil",
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey.shade600),
                                                      ),
                                                      onPressed: () async {
                                                        bool rs =
                                                            await FirebaseStore
                                                                .DeleteTask(
                                                          currentdoneTask.id
                                                              .toString(),
                                                          FirebaseAuth.instance
                                                              .currentUser!.uid,
                                                        );
                                                        if (rs == true) {
                                                          Navigator
                                                              .pushReplacement(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  const home_screen(),
                                                            ),
                                                          );
                                                          final scaffoldContext =
                                                              ScaffoldMessenger
                                                                  .of(context);
                                                          scaffoldContext
                                                              .showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                "Görev Başarıyla Silindi! ",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 15,
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              backgroundColor:
                                                                  Colors.black,
                                                            ),
                                                          );
                                                        } else {
                                                          print(
                                                              "Görevi silerken bir şeyler yanlış gitti.");
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                  cancelButton:
                                                      CupertinoActionSheetAction(
                                                    isDefaultAction: true,
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: const Text(
                                                      "İptal Et",
                                                      style: TextStyle(
                                                          color: Colors.red),
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          child: Container(
                                              height: 110,
                                              width: 300,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  color: color),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        FittedBox(
                                                          child: Container(
                                                            constraints: BoxConstraints(
                                                              maxHeight: 20,
                                                                maxWidth: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width -
                                                                    100),
                                                            child:
                                                                SingleChildScrollView(
                                                              scrollDirection:
                                                                  Axis.horizontal,
                                                              child: Text(
                                                                // "Title " + index.toString(),
                                                                currentdoneTask
                                                                        .title ??
                                                                    "",
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        17,
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              "Görev Şu Tarihte Tamamlandı : ",
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                            Text(
                                                              // "    02:04 PM - 02:19 PM",
                                                              currentdoneTask
                                                                      .completedTime ??
                                                                  " ",

                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        FittedBox(
                                                          child: Container(
                                                            constraints: BoxConstraints(
                                                              maxHeight: 20,
                                                                maxWidth: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width -
                                                                    100),
                                                            child:
                                                                SingleChildScrollView(
                                                              scrollDirection:
                                                                  Axis.horizontal,
                                                              child: Text(
                                                                // "Note 1",
                                                                currentdoneTask
                                                                        .note ??
                                                                    "",
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        18,
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w300),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: Container(
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            height: 100,
                                                            width: 1,
                                                            color: Colors.white,
                                                          ),
                                                          const SizedBox(
                                                            width: 8,
                                                          ),
                                                          const RotatedBox(
                                                            quarterTurns:
                                                                3, // Set the number of clockwise quarter turns
                                                            child: Text(
                                                              'Görev',
                                                              style: TextStyle(
                                                                fontSize: 13,
                                                                color: Colors
                                                                    .white,
                                                              ), // Define the text style
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              )),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : const SizedBox(),

                          // second Container strts from here
                        ))
                    : const SizedBox(),
              ]),
            )),
          );
  }
}
