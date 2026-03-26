import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finme/app.dart';
import 'package:finme/data/sync/background_sync_worker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO: Uncomment after running `flutterfire configure`
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await registerBackgroundSync();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const ProviderScope(child: FinMeApp()));
}
