
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:furniture_shop/ui/auth/signup.dart';
import 'package:furniture_shop/ui/auth/view_models/login_vm.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../data/AuthRepository.dart';
import '../welcome/welcome_screen.dart';
import 'FadeAnimation.dart';
import 'forget_password.dart';

class SignIn extends StatefulWidget {
  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;
  late LoginViewModel loginViewModel;

  @override
  void initState() {
    super.initState();
    loginViewModel = Get.find<LoginViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (loginViewModel.isUserLoggedIn()) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.brown[200],
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
                        padding: const EdgeInsets.only(top: 100, left: 200),
                        child: Text.rich(
                          TextSpan(
                            text: 'Sign in',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.bold),
                            children: <InlineSpan>[],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 50),
                //email address
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
                        hintText: 'Email address',
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20),
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
                        hintText: 'Password',
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 30),
                //forget password
                FadeAnimation(
                  1.6,
                  Padding(
                    padding: const EdgeInsets.only(left: 220.0),
                    child: GestureDetector(
                      onTap: () {
                        Get.to(ForgetPassword(),
                            binding: ResetPasswordBinding());
                      },
                      child: Center(
                        child: Text(
                          "Forget Password ?",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[900],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 30),
                //sign-in
                Obx(
                  () {
                    return loginViewModel.isLoading.value
                        ? CircularProgressIndicator()
                        : FadeAnimation(
                            1.6,
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 70.0),
                              child: Container(
                                height: 50,
                                width: 300,

                                // margin: EdgeInsets.symmetric(horizontal: 50),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  gradient: LinearGradient(
                                    colors: [Colors.black87, Colors.black],
                                  ),
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    loginViewModel.login(emailController.text,
                                        passwordController.text);
                                  },
                                  child: Center(
                                    child: Text(
                                      "SIGN IN",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                  },
                ),
                SizedBox(height: 50),
                FadeAnimation(
                  1.6,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 70.0),
                    child: Text.rich(
                      TextSpan(
                        text: "Don't have an account ? ",
                        style: TextStyle(color: Colors.grey, fontSize: 18),
                        children: <InlineSpan>[
                          TextSpan(
                            text: 'Sign Up',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.lightBlue,
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Get.offAll(SignUp(), binding: SignUpBinding());
                                // single tapped
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthRepository());
    Get.put(LoginViewModel());
  }
}
