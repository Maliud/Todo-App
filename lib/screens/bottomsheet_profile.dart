import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/providers/theme_provider.dart';
import 'package:todo_app/screens/show_history.dart';
import 'package:todo_app/screens/signin_screen.dart';
import 'package:todo_app/utilities/firebase_database.dart';
import 'package:todo_app/utilities/notification_service.dart';
import 'package:todo_app/main.dart';


Future<void> sign_out(BuildContext context) async {
  FirebaseAuth.instance.signOut().then((value) async {
    var SharedPref = await SharedPreferences.getInstance();
    SharedPref.setBool(splash_screenState.KEYLOGIN, false);
    if (context.mounted) {
      Navigator.of(context).pop();
      Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const signin_screen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              final tween = Tween(begin: begin, end: end);
              final offsetAnimation = animation.drive(tween);

              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
          ));
    }
    // context.go('/signin_screen');
  });
}

bool emailverify = false;
checkmail() {
  var currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser != null) {
    emailverify = currentUser.emailVerified;
    return emailverify;
  } else {
    // Handle the case where currentUser is null, e.g., user not signed in
    return false;
  }
}

showOptions(BuildContext context, String name, String email) {
  showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context) {
      return MyCupertinoActionSheet(name: name, email: email);
    },
  );
}

class MyCupertinoActionSheet extends StatefulWidget {
  final String name;
  final String email;

  const MyCupertinoActionSheet({super.key, required this.name, required this.email});

  @override
  _MyCupertinoActionSheetState createState() => _MyCupertinoActionSheetState();
}

class _MyCupertinoActionSheetState extends State<MyCupertinoActionSheet> {
  bool notification = true;

  @override
  void initState() {
    super.initState();
    loadNotificationState();
  }

  void loadNotificationState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      notification = prefs.getBool('notification') ?? true;
    });
  }

  void saveNotificationState(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('notification', value);
  }

  onNotificationChanged(bool value) {
    setState(() {
      notification = value;
      saveNotificationState(value);
      setState(() {
        // NotificationService().pauseNotifications();
      });
      if (!notification) {
        setState(() {
          // NotificationService().unpauseNotifications();
        });
      }
      print(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenhight = MediaQuery.of(context).size.height;
    final themeprovider = Provider.of<ThemeProvider>(context, listen: false);
    return CupertinoActionSheet(
      actions: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.55,
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const CircleAvatar(
                      minRadius: 50,
                      maxRadius: 50,
                      backgroundColor: Colors.blue,
                      child: Icon(
                        Icons.person_sharp,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: 100,
                      width: 200,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FittedBox(
                              child: Text(
                            widget.name,
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                decoration: TextDecoration.none),
                          )),
                          const SizedBox(
                            height: 10,
                          ),
                          FittedBox(
                              child: Text('${widget.email} ',
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      decoration: TextDecoration.none)))
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              CupertinoActionSheetAction(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Temayı Değiştir',
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w400),
                    ),
                    Icon(
                      themeprovider.getThemeIcon(),
                      size: 25,
                      color: Colors.white,
                    )
                  ],
                ),
                onPressed: () {
                  themeprovider.toggleTheme();
                },
              ),
              CupertinoActionSheetAction(
                child:  Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     const Text(
                      'Hatırlatıcı',
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w400),
                    ),
                    CupertinoSwitch(
                      value: notification,
                      onChanged: onNotificationChanged,
                      activeColor: Colors.purple,
                    ),
                  ],
                ),
                onPressed: () {},
              ),
              CupertinoActionSheetAction(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Email Doğrulama',
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w400),
                    ),
                    Icon(
                      checkmail()
                          ? Icons.mark_email_read_outlined
                          : Icons.email_outlined,
                      color: Colors.white,
                    )
                  ],
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  if (checkmail() == true) {
                    final scaffoldContext = ScaffoldMessenger.of(context);
                    scaffoldContext.showSnackBar(
                      const SnackBar(
                        content: Text(
                          "E-Postanız Zaten Doğrulandı !",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: Colors.black,
                      ),
                    );
                  } else {
                    final scaffoldContext = ScaffoldMessenger.of(context);
                    FirebaseStore.SendMailVerification().then((value) {
                      scaffoldContext.showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Posta Gönderildi! Lütfen Postanızı Kontrol Edin !",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: Colors.black,
                        ),
                      );
                    });
                                    }
                },
              ),
              CupertinoActionSheetAction(
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Görev Geçmişi',
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w400),
                    ),
                    Icon(
                      Icons.history_edu_outlined,
                      color: Colors.white,
                    )
                  ],
                ),
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const show_history(),
                      ));
                },
              ),
              CupertinoActionSheetAction(
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Uygulamayı Paylaş',
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w400),
                    ),
                    Icon(
                      Icons.ios_share_outlined,
                      color: Colors.white,
                    )
                  ],
                ),
                onPressed: () async {
                  try {
                    await Share.share(
                        '🚀 Todo Uygulaması ile düzenli kalın! 📝📅⏰\n\n'
                        '🌟 Sorunsuz görev yönetimine dalın ve zamanında hatırlatıcılar alın!\n\n'
                        '📱 Todo Uygulamasını şimdi indirin ve günlük rutinlerinizi basitleştirin!\n'
                        '🔗 GitHub Link: https://github.com/Maliud/Todo-App\n\n'
                        '🔥 Todo Uygulaması ile bugün bir üretkenlik şampiyonu olun! 🔥',
                        subject: '⭐ Mükemmel Görev Yönetimi Yoldaşınız ⭐');
                  } catch (e) {
                    print(e);
                  }
                },
              ),
            ],
          ),
        ),
        CupertinoActionSheetAction(
          child: const Text(
            'Çıkış Yap',
            style: TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.w400),
          ),
          onPressed: () {
            sign_out(context);
          },
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            "İptal Et",
            style: TextStyle(color: Colors.red),
          )),
    );
  }
}
