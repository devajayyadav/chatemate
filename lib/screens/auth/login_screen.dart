import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../api/apis.dart';
import '../../helper/dialogs.dart';
import '../../main.dart';
import '../home_screen.dart';

//login screen -- implements google sign in or sign up feature for app
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;

  @override
  void initState() {
    super.initState();

    //for auto triggering animation
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() => _isAnimate = true);
    });
  }

  // handles google login button click
  _handleGoogleBtnClick() {
    //for showing progress bar
    Dialogs.showLoading(context);

    _signInWithGoogle().then((user) async {
      //for hiding progress bar
      Navigator.pop(context);

      if (user != null) {
        log('\nUser: ${user.user}');
        log('\nUserAdditionalInfo: ${user.additionalUserInfo}');

        if (await APIs.userExists() && mounted) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        } else {
          await APIs.createUser().then((value) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const HomeScreen()));
          });
        }
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      log('\n_signInWithGoogle: $e');


      if (mounted) {
        Dialogs.showSnackbar(context, 'Something Went Wrong (Check Internet!)');
      }

      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    //initializing media query (for getting device screen size)
    mq = MediaQuery.sizeOf(context);

    return Scaffold(
      //app bar
      appBar: AppBar(

        automaticallyImplyLeading: false,
        title: const Text('Welcome to chatmate',style:

          TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),),
      ),

      //body
      body: Stack(children: [
        //app logo
        AnimatedPositioned(
            top: mq.height * .15,
            right: _isAnimate ? mq.width * .25 : -mq.width * .5,
            width: mq.width * .5,
            duration: const Duration(seconds: 1),
            child: Image.asset('assets/images/icon.png')),
        AnimatedPositioned(duration: (Duration(seconds: 2)),
            bottom:  80,
              left: _isAnimate ?140 : -mq.width *.5,
            height: 50,


            child: MaterialButton(
              splashColor:  Colors.purple,
              shape: StadiumBorder(),
              onPressed: (){
                Dialogs.showSnackbar(context, 'coming soon');
              },
              child: Text("login with email",style:

                TextStyle(
                  color: Colors.green,
                ),),
            )),

        //google login button
        AnimatedPositioned(
          duration: (Duration(seconds: 2)),
            bottom: mq.height * .15,
            left:  _isAnimate ? mq.width * .05 : -mq.width * 5,
            width: mq.width * .9,
            height: mq.height * .06,
            child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(238, 223, 255, 147),
                    shape: const StadiumBorder(),
                    elevation: 1),


                // on tap
                onPressed: _handleGoogleBtnClick,

                //google icon
                icon: Image.asset('assets/images/google.png',
                    height: mq.height * .03),

                //login with google label
                label: RichText(
                  text: const TextSpan(
                      style: TextStyle(color: Colors.black, fontSize: 16),
                      children: [
                        TextSpan(text: 'Login with '),
                        TextSpan(
                            text: 'Google',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                      ]),
                )),

        ),

      ]),
    );
  }
}
