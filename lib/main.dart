import 'package:flutter/material.dart';
import 'package:kivu_haqms/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kivu_haqms/firebase_options.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(const KivuApp());
}
