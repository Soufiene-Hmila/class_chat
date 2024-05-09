import 'package:class_chat/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool pageInitialized = false;
  final googleSignIn = GoogleSignIn(
    scopes: [
      'email', 'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  final firebaseAuth = FirebaseAuth.instance;
  @override
  void initState() {
    Firebase.initializeApp().whenComplete(() {

      setState(() {});
    });
    checkIfUserLoggedIn();
    super.initState();
  }

  checkIfUserLoggedIn() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    bool userLoggedIn  = (_prefs.getString('id')!=null?true:false);

    if(userLoggedIn==true){
      print(_prefs.getString('id'));
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (BuildContext context) => const HomeScreen()));
    }else{
      setState(() {
        pageInitialized = true;
      });
    }

  }

  handleSignIn()async{
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    final res = await googleSignIn.signIn();
    final auth = await res?.authentication;
    final credentials = GoogleAuthProvider.credential(accessToken: auth?.accessToken, idToken: auth?.idToken);
    final firebaseUser = (await firebaseAuth.signInWithCredential(credentials)).user;
    if(firebaseUser != null){
      final results = (await FirebaseFirestore.instance.collection('users').where('id', isEqualTo: firebaseUser.uid).get()).docs;

      if(results.isEmpty){
        FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).set({
          "id": firebaseUser.uid,
          "name": firebaseUser.displayName,
          "created_at": DateTime.now()
        });
        _prefs.setString('id', firebaseUser.uid);
        _prefs.setString('name', "${firebaseUser.displayName}");

        Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => const HomeScreen()));
      }
      else{
        _prefs.setString('id', results[0]['id']);
        _prefs.setString('name', results[0]['name']);
        Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => const HomeScreen()));
      }
    }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: pageInitialized ?
        Center(
          child: ElevatedButton(
            onPressed: handleSignIn,
            child: const Text('Sign In'),
          ),
        ) :
        const Center(
          child: SizedBox(
            height: 36, width: 36,
            child: CircularProgressIndicator(),
          ),
        ),
    );
  }
}
