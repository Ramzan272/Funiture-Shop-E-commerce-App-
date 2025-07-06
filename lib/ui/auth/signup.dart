import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:furniture_shop/ui/auth/view_models/signup_vm.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../data/AuthRepository.dart';
import '../welcome/welcome_screen.dart';
import 'FadeAnimation.dart';
import 'login.dart';
class SignUp extends StatefulWidget {
  @override
  State<SignUp> createState() => _SignUpState();
}
class _SignUpState extends State<SignUp> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool isPasswordVisible = false;
  bool isPasswordVisible2 = false;
  late SignUpViewModel signUpViewModel;

  @override
  void initState() {
    super.initState();
    signUpViewModel = Get.find<SignUpViewModel>();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              backgroundColor: Colors.grey,
              leading: IconButton(
                icon: new Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Get.offAll(Home());
                },
              ),
            ),
            body: FadeAnimation(
              1.6,
              Container(
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.white),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: 150,
                      width: 420,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: ExactAssetImage("assets/images/img2.jpg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: FadeAnimation(
                        1.6,
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40.0),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 100, left: 180),
                            child: Text.rich(TextSpan(
                                text: 'Sign Up',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25,
                                ),
                                children: <InlineSpan>[])),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    //email
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 70.0),
                      child: Container(
                        width: 280,
                        child: TextField(
                          controller: emailController,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                              border: UnderlineInputBorder(),
                              prefixIcon: Icon(Icons.email),
                              hintText: 'Email address'),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    //password
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 70.0),
                      child: Container(
                        width: 280,
                        child: TextField(
                          controller: passwordController,
                          obscureText: !isPasswordVisible,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                              border: UnderlineInputBorder(),
                              prefixIcon: Icon(Icons.lock),
                              suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isPasswordVisible = !isPasswordVisible;
                                    });
                                  },
                                  icon: Icon(isPasswordVisible
                                      ? Icons.visibility_off
                                      : Icons.remove_red_eye)),
                              hintText: 'Password'),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    //Confirm password
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 70.0),
                      child: Container(
                        width: 280,
                        child: TextField(
                          controller: confirmPasswordController,
                          obscureText: !isPasswordVisible2,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                              border: UnderlineInputBorder(),
                              prefixIcon: Icon(Icons.lock),
                              suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isPasswordVisible2 = !isPasswordVisible2;
                                    });
                                  },
                                  icon: Icon(isPasswordVisible2
                                      ? Icons.visibility_off
                                      : Icons.remove_red_eye)),
                              hintText: 'Confirm Password'),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    //sginup button
                    Obx(
                      () {
                        return signUpViewModel.isLoading.value
                            ? CircularProgressIndicator()
                            : FadeAnimation(
                                1.6,
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 70.0),
                                  child: Container(
                                      height: 50,
                                      width: 300,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          gradient: LinearGradient(colors: [
                                            Colors.black,
                                            Colors.black87
                                          ])),
                                      child: GestureDetector(
                                        onTap: () {
                                          signUpViewModel.signup(
                                              emailController.text,
                                              passwordController.text,
                                              confirmPasswordController.text);
                                        },
                                        child: Center(
                                          child: Text(
                                            "SIGN UP",
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      )),
                                ));
                      },
                    ),

                    SizedBox(
                      height: 50,
                    ),
                    FadeAnimation(
                      1.6,
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 70.0),
                        child: Text.rich(TextSpan(
                            text: "Already have an account ? ",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 18,
                            ),
                            children: <InlineSpan>[
                              TextSpan(
                                text: 'Sign In',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.lightBlue,
                                    fontWeight: FontWeight.bold),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Get.offAll(SignIn(),
                                        binding: LoginBinding());

                                    // single tapped
                                  },
                              ),
                            ])),
                      ),
                    ),
                  ],
                ),
              ),
            )));
  }
}

class SignUpBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthRepository());
    Get.put(SignUpViewModel());
  }
}
