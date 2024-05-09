import 'package:class_chat/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:social_media_recorder/audio_encoder_type.dart';
import 'package:social_media_recorder/screen/social_media_recorder.dart';
import 'package:voice_message_package/voice_message_package.dart';

bool shouldUseFirestoreEmulator = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  if (shouldUseFirestoreEmulator) {
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
