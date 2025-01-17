import "package:firebase_auth/firebase_auth.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:permission_handler/permission_handler.dart";
import "package:azure_speech_recognition_null_safety/azure_speech_recognition_null_safety.dart";

class VoiceInput extends StatefulWidget {
  const VoiceInput({Key? key}) : super(key: key);

  @override
  _VoiceInputState createState() => _VoiceInputState();
}

class _VoiceInputState extends State<VoiceInput> {

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  String subKey = dotenv.env['SUB_KEY']!;
  String region = dotenv.env['SUB_REGION']!;
  String lang = "en-US";
  late AzureSpeechRecognition _speechAzure;

  bool voiceActive = false;
  String transcription = '';

  Future<void> statementPush(text) async {
    DateTime now = DateTime.now();
    Map<String, dynamic> upload = {
      "datetime": now,
      "content": text
    };

    final uid = auth.currentUser?.uid;
    await firestore.collection("users").where("uid", isEqualTo: uid).limit(1).get().then((QuerySnapshot snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.update({
          "logs": FieldValue.arrayUnion([upload])
        });
      }
    });
  }

  void activateSpeechRecognizer() {
    AzureSpeechRecognition.initialize(subKey, region, lang: lang, timeout: "1000");

    _speechAzure.setFinalTranscription((text) async {
      if (text[text.length - 1] == "?") {

      }
      else {
        await statementPush(text);
      }

      setState(() {
        voiceActive = false;
        transcription = text;
      });
    });

    _speechAzure.setRecognitionStartedHandler(() {
      setState(() {
        voiceActive = true;
      });
    });
  }

  void initState() {
    _speechAzure = AzureSpeechRecognition();
    activateSpeechRecognizer();
    super.initState();
  }

  Future _startRecognition() async {

    final PermissionStatus permission = await Permission.microphone.status;
    if (permission.isPermanentlyDenied) openAppSettings();

    if (permission.isDenied) {
      final Map<Permission, PermissionStatus> permissionStatus = await [Permission.microphone].request();

      if (permissionStatus[Permission.microphone] == PermissionStatus.granted) {
        try {
          AzureSpeechRecognition.simpleVoiceRecognition();
        }
        on PlatformException catch (e) {
          print("Failed to get text '${e.message}'.");
        }
      }
    } else {
      try {
        AzureSpeechRecognition.simpleVoiceRecognition();
      }
      on PlatformException catch (e) {
        print("Failed to get text '${e.message}'.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: !voiceActive ? _startRecognition : null,
      foregroundColor: voiceActive ? Colors.green : Colors.black,
      child: const Icon(Icons.mic),
    );
  }
}
