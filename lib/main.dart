import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'core/app.dart';
import 'core/error_handler.dart';
import 'firebase_options.dart';

Future<String> getOrCreateUid() async {
  final auth = FirebaseAuth.instance;
  User? user = auth.currentUser;
  if (user == null) {
    UserCredential credential = await auth.signInAnonymously();
    user = credential.user;
  }
  return user!.uid;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    developer.log("🚀 開始初始化 Firebase...", name: 'Firebase');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    developer.log("✅ Firebase 初始化成功！", name: 'Firebase');

    // 匿名登入並取得 uid
    final uid = await getOrCreateUid();
    developer.log('目前使用者的 UID：$uid', name: 'FirebaseAuth');

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
