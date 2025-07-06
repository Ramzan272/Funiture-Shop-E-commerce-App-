import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../auth/FadeAnimation.dart';
import '../auth/login.dart';
import '../auth/signup.dart';

class Home extends StatelessWidget {
  const Home({super.key});
  @override
  Widget build(BuildContext context ) {
    return SafeArea(
      child: Scaffold(
        body: FadeAnimation(
          1.6,
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(color: Colors.white),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 250,
                  width: double.maxFinite,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: ExactAssetImage("assets/images/img2.jpg"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                      child: Container(
                        alignment: Alignment.center,
                        color: Colors.white.withOpacity(0.1),
                        child: const Padding(
                          padding: EdgeInsets.only(top: 30.0),
                          child: Text(
                            "Creative",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 150),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      children: [
                        FadeAnimation(
                          1.6,
                          Container(
                            height: 50,
                            width: 300,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.grey[900],
                            ),
                            child: GestureDetector(
                              onTap: () {
                                Get.to(() => SignUp(),
                                    binding: SignUpBinding());
                              },
                              child: const Center(
                                child: Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        FadeAnimation(
                          1.6,
                          Container(
                            height: 50,
                            width: 300,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.grey[900],
                            ),
                            child: GestureDetector(
                              onTap: () {
                                Get.to(() => SignIn(), binding: LoginBinding());
                              },
                              child: const Center(
                                child: Text(
                                  "Sign In",
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
