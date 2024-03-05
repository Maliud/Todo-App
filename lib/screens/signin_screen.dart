import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:todo_app/providers/theme_provider.dart';
import 'package:todo_app/screens/forgetpassword_screen.dart';
import 'package:todo_app/screens/home_screen.dart';
import 'package:todo_app/screens/signup_screen.dart';
import 'package:todo_app/utilities/firebase_database.dart';
import 'package:todo_app/widgets/custom_widgets.dart';
import 'package:todo_app/main.dart';

class signin_screen extends StatefulWidget {
  const signin_screen({Key? key}) : super(key: key);

  @override
  State<signin_screen> createState() => _signin_screenState();
}

class _signin_screenState extends State<signin_screen> {
  TextEditingController email = TextEditingController();
  TextEditingController pass = TextEditingController();
  final _formkey0 = GlobalKey<FormState>();

  Future<void> movetosignin() async {
    if (_formkey0.currentState != null && _formkey0.currentState!.validate()) {
      var result =
          await FirebaseStore.signinuser(email.text.trim(), pass.text.trim());
      if (result == true) {
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

                  var tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));
                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                }));

        var SharedPref = await SharedPreferences.getInstance();
        SharedPref.setBool(splash_screenState.KEYLOGIN, true);
        print("Success");
      } else if (result is String) {
        print(result);
        String errorCode = result;

        if (errorCode == "invalid-email") {
          CustomSnackBar.showSnackBar(
              context, "ok", () => {}, "Please Enter a Valid Email");
        } else if (errorCode == 'wrong-password') {
          CustomSnackBar.showSnackBar(
              context, "Ok", () => null, 'Wrong Password');
        } else if (errorCode == "email-already-in-use") {
          CustomSnackBar.showSnackBar(
              context, "ok", () => {}, "User Already Exist");
        } else if (errorCode == 'weak-password') {
          CustomSnackBar.showSnackBar(context, "ok", () => {}, "Weak Password");
        } else if (errorCode == 'unknown') {
          CustomSnackBar.showSnackBar(
              context, "ok", () => {}, "Something Went Wrong");
        } else if (errorCode == 'user-not-found') {
          CustomSnackBar.showSnackBar(context, "ok", () => {}, "No User Found");
        } else if (errorCode == 'INVALID_LOGIN_CREDENTIALS') {
          CustomSnackBar.showSnackBar(
              context, "ok", () => {}, "Invalid login details");
        } else if (errorCode == 'network-request-failed') {
          CustomSnackBar.showSnackBar(
              context, "Ok", () => null, "Pleace Check Your Internet ");
        }
      }

      // bool isUserAuthenticated =
      //     await SharedPreference.authenticateUser(email.text, pass.text);
      // if (isUserAuthenticated) {
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => home_screen(),
      //     ),
      //   );
      // } else {
      //   // Handle authentication failure
      //   print("Authentication failed");
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeprovider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                  height: MediaQuery.of(context).size.height - 450,
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.all(13.0),
                    child: Stack(
                      children: <Widget>[
                        SvgPicture.asset('assets/images/sign_in.svg'),
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
                  )),
              Container(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Form(
                  key: _formkey0,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      CustomTextFormField(
                        controller: email,
                        labelText: "Email Adresi",
                        hintText: "abc@gmail.com",
                        sur: const Icon(
                          Icons.email_outlined,
                          size: 30,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "E-posta boş olamaz";
                          } else if (!value.contains('@')) {
                            return "Lütfen geçerli bir e-posta girin";
                          } else {
                            return null;
                          }
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      CustomTextFormField(
                        controller: pass,
                        obscureText: true,
                        labelText: "Şifre",
                        hintText: "Ali123@2266",
                        sur: const Icon(
                          Icons.password_outlined,
                          size: 30,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Şifre boş olamaz";
                          } else if (value.length < 6) {
                            return "Şifre en az 6 karakterden oluşmalıdır";
                          } else {
                            return null;
                          }
                        },
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      CustomElevatedButton(
                        message: "Giriş Yap",
                        function: movetosignin,
                      ),
                      const SizedBox(height: 2),
                      Align(
                        alignment: Alignment.topRight,
                        child: TextButton(
                          onPressed: () {
                            // context.go('/forgetpassword_screen');
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const forgetpassword_screen(),
                                ));
                          },
                          child: const Text("Şifremi Unuttum"),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text("Yada"),
                      const SizedBox(
                        height: 7,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 5,
                          ),
                          const Text("Yeni bir hesap oluşturun? "),
                          TextButton(
                            onPressed: () async {
                         

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const signup_screen(),
                                ),
                              );
                            },
                            child: const Text("Kayıt Ol"),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
