import 'package:class_chat/firebase_options.dart';
import 'package:class_chat/home_screen.dart';
import 'package:class_chat/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:social_media_recorder/audio_encoder_type.dart';
import 'package:social_media_recorder/screen/social_media_recorder.dart';
import 'package:voice_message_package/voice_message_package.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const Application());
}

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error'));
          }

          if (snapshot.connectionState == ConnectionState.done) {
            return const LoginScreen();
          }
          return const Center(child: SizedBox(height: 36, width: 36, child: CircularProgressIndicator(),),);
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String? soundRef;
  String? soundUrl;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            soundUrl != null ?
            VoiceMessageView(
              controller: VoiceController(
                /// audioSrc: 'https://dl.solahangs.com/Music/1403/02/H/128/Hiphopologist%20-%20Shakkak%20%28128%29.mp3',
                audioSrc: '$soundUrl',
                onComplete: () {
                  /// do something on complete
                },
                onPause: () {
                  /// do something on pause
                },
                onPlaying: () {
                  /// do something on playing
                },
                onError: (err) {
                  /// do somethin on error
                },
                maxDuration: const Duration(seconds: 60),
                isFile: false,
              ),
              innerPadding: 12,
              cornerRadius: 20,
            ): const SizedBox(),
            SocialMediaRecorder(
              maxRecordTimeInSecond: 60,
              startRecording: () {

              },
              stopRecording: (time) {

              },
              sendRequestFunction: (soundFile, time) {
                debugPrint("Sound File Path: ${soundFile.path}");
                setState(() {
                  soundRef = soundFile.path.substring(soundFile.path.lastIndexOf("/") + 1,
                      soundFile.path.lastIndexOf("."));
                });

                if(soundRef != null){
                  FirebaseStorage.instance.ref("sounds/$soundRef").putFile(soundFile,
                  ).then((taskSnapshot) {
                    taskSnapshot.ref.getDownloadURL().then((downloadURL) {
                      debugPrint("Sound File Url: $downloadURL");
                      FirebaseFirestore.instance.collection('sounds').add({"url": downloadURL, "name": soundRef}
                      ).then((value) {
                        setState(() => soundUrl = downloadURL);

                      });
                    });
                  });
                }

              },

              encode: AudioEncoderType.AAC,
            ),
          ],
        ),
      ),
    );
  }
}
