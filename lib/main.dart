import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:firebase_core/firebase_core.dart';

import 'core/app.dart';
import 'core/error_handler.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    developer.log("🚀 開始初始化 Firebase...", name: 'Firebase');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    developer.log("✅ Firebase 初始化成功！", name: 'Firebase');
    runApp(const MyApp());
  } catch (e, stackTrace) {
    developer.log(
      "❌ Firebase 初始化失敗",
      name: 'Firebase',
      error: e,
      stackTrace: stackTrace,
    );
    runApp(ErrorHandler(error: e.toString()));
  }
}
