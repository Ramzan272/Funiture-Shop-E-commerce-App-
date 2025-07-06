import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository{

  Future<UserCredential> login(String email, String password){
    return FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signup(String email, String password){
    return FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
  }

  User? getLoggedInUser(){
    return FirebaseAuth.instance.currentUser;
  }
  Future<void> resetPassword(String email){
    return FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  Future<void> sendVerificationEmail(){
    User? user=getLoggedInUser();
    if(user==null) return Future.value();
    return user.sendEmailVerification();
  }

  Future<void> changePassword(String newPassword){
    User? user=getLoggedInUser();
    if(user==null) return Future.value();
    return user.updatePassword(newPassword);
  }

  Future<void> changeName(String name){
    User? user=getLoggedInUser();
    if(user==null) return Future.value();
    return user.updateDisplayName(name);
  }

  void logout(){
    FirebaseAuth.instance.signOut();
  }

}