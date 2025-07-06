import 'package:flutter/material.dart';
import 'package:furniture_shop/ui/auth/view_models/reset_password_vm.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../data/AuthRepository.dart';
import 'FadeAnimation.dart';
import 'login.dart';

class ForgetPassword extends StatefulWidget {
  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  TextEditingController emailController = TextEditingController();
  bool isPasswordVisible = false;
  late ResetPasswordViewModel resetViewModel;

  @override
  void initState() {
    super.initState();
    resetViewModel = Get.find<ResetPasswordViewModel>();
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
                  Get.offAll(SignIn());
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
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 100, left: 130),
                            child: Text.rich(TextSpan(
                                text: 'Forget Password',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                                children: <InlineSpan>[])),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 50,
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
                    //reset password

                    Obx(
                      () {
                        return resetViewModel.isLoading.value
                            ? CircularProgressIndicator()
                            : FadeAnimation(
                                1.6,
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 70.0),
                                  child: Container(
                                      height: 50,
                                      width: 300,

                                      // margin: EdgeInsets.symmetric(horizontal: 50),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          gradient: LinearGradient(colors: [
                                            Colors.black87,
                                            Colors.black
                                          ])),
                                      child: GestureDetector(
                                        onTap: () {
                                          resetViewModel
                                              .reset(emailController.text);
                                        },
                                        child: Center(
                                          child: Text(
                                            "Submit",
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
                  ],
                ),
              ),
            )));
  }
}

class ResetPasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthRepository());
    Get.put(ResetPasswordViewModel());
  }
}
