import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/main.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/providers/theme_provider.dart';
import 'package:todo_app/screens/home_screen.dart';
import 'package:todo_app/screens/signin_screen.dart';
import 'package:todo_app/utilities/firebase_database.dart';
import 'package:todo_app/utilities/user_data.dart';
import 'package:todo_app/widgets/custom_widgets.dart';

class signup_screen extends StatefulWidget {
  const signup_screen({Key? key});
  @override
  _signup_screenState createState() => _signup_screenState();
}

class _signup_screenState extends State<signup_screen> {
  final _formkey1 = GlobalKey<FormState>();
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController pass = TextEditingController();
  TextEditingController cpass = TextEditingController();

  Future<void> movetosignup() async {
    print("Success");
    if (_formkey1.currentState != null && _formkey1.currentState!.validate()) {
      var result = await FirebaseStore.createuser(email.text, pass.text.trim());
      if (result == true) {
        var SharedPref = await SharedPreferences.getInstance();
        SharedPref.setBool(splash_screenState.KEYLOGIN, true);
        await UserData.userdata(
            FirebaseAuth.instance.currentUser!.uid, email.text, name.text);

        // context.go('/');

        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const home_screen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              const curve = Curves.ease;

              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);

              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
          ),
        );

        print("Succes");
      } else if (result is String) {
        String errorCode = result;
        if (errorCode == "invalid-email") {
          CustomSnackBar.showSnackBar(
              context, "ok", () => {}, "Lütfen Geçerli Bir E-posta Girin");
        } else if (errorCode == "email-already-in-use") {
          CustomSnackBar.showSnackBar(
              context, "ok", () => {}, "Kullanıcı Zaten Var");
        } else if (errorCode == 'weak-password') {
          CustomSnackBar.showSnackBar(context, "ok", () => {}, "Weak Password");
        } else if (errorCode == 'ağ-talep-başarısız') {
          CustomSnackBar.showSnackBar(
              context, "Ok", () => null, "Lütfen İnternetinizi Kontrol Edin ");
        }

        // .then((value) async {
        // SharedPreference.saveCredentials(email.text, pass.text)
        //     .then((value) => Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //           builder: (context) => adiconst home_screen(),
        //         )));
        // });
      } else {
        // context.go('/signup_screen');
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const signin_screen(),
            ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeprovider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formkey1,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height - 550,
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Stack(
                      children: <Widget>[
                        SvgPicture.asset('assets/images/sign_up.svg'),
                        Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                                onPressed: () {
                                  themeprovider.toggleTheme();
                                },
                                icon: Icon(
                                  themeprovider.getThemeIcon(),
                                  size: 25,
                                )))
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10, left: 10),
                  child: Container(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        CustomTextFormField(
                          labelText: "İsim Soyisim",
                          hintText: "Ali Ali",
                          controller: name,
                          sur: const Icon(
                            Icons.abc_outlined,
                            size: 35,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "İsim boş olamaz";
                            } else {
                              return null;
                            }
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        CustomTextFormField(
                          labelText: "Email",
                          hintText: "ali@gmail.com",
                          controller: email,
                          sur: const Icon(
                            Icons.email_outlined,
                            size: 30,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "E-posta boş olamaz";
                            } else if (!value.contains('@')) {
                              return "Lütfen Geçerli Bir E-posta Girin";
                            } else {
                              return null;
                            }
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        CustomTextFormField(
                          labelText: "Şifre",
                          hintText: "Ali123@2266",
                          controller: pass,
                          obscureText: true,
                          sur: const Icon(
                            Icons.password_outlined,
                            size: 30,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Şifre boş olamaz";
                            } else if (value.length < 6) {
                              return "Şifre 6 Rakamdan Büyük Olmalıdır";
                            } else {
                              return null;
                            }
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        CustomTextFormField(
                          labelText: "Şifreyi Onayla",
                          hintText: "Ali123@2266",
                          controller: cpass,
                          obscureText: true,
                          sur: const Icon(
                            Icons.password_outlined,
                            size: 30,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Şifre boş olamaz";
                            } else if (value.length < 6) {
                              return "Şifre 6 Rakamdan Büyük Olmalıdır";
                            } else if (value != pass.text) {
                              return "Parola Eşleşmesi Başarısız";
                            } else {
                              return null;
                            }
                          },
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        CustomElevatedButton(
                          message: "Kayıt Ol",
                          function: movetosignup,
                        ),
                        //  Elevated button
                        // ElevatedButton(
                        //   onPressed: () {
                        //     movetosignup();
                        //   },
                        //   style: ButtonStyle(
                        //     backgroundColor:
                        //         MaterialStateProperty.all<Color>(Colors.blue),
                        //     shape: MaterialStateProperty.all(
                        //       const RoundedRectangleBorder(
                        //         borderRadius:
                        //             BorderRadius.all(Radius.circular(10)),
                        //       ),
                        //     ),
                        //     padding: MaterialStateProperty.all(
                        //       const EdgeInsets.only(
                        //           left: 140, right: 140, top: 12, bottom: 12),
                        //     ),
                        //     elevation: MaterialStateProperty.all(1),
                        //   ),
                        //   child: const Text(
                        //     "Sign Up",
                        //     style: TextStyle(
                        //       color: Colors.white,
                        //       fontSize: 20,
                        //       fontWeight: FontWeight.bold,
                        //     ),
                        //   ),
                        // ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text("Yada"),
                        Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 5,
                            ),
                            const Text("Hesabınız Var Mı? "),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const signin_screen(),
                                    ));
                              },
                              child: const Text("Giriş Yap"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
