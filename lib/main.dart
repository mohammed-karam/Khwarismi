import 'package:codeforcers/core/storage/app_settings.dart';
import 'package:codeforcers/core/storage/solved_store.dart';
import 'package:codeforcers/core/theme/app_colors.dart';
import 'package:codeforcers/features/shell/views/main_shell_view.dart';
import 'package:codeforcers/features/splash/views/splash_view.dart';
import 'package:codeforcers/features/submit/data/cf_verdict_store.dart';
import 'package:codeforcers/features/timer/manager/timer_controller.dart';
import 'package:codeforcers/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await AppSettings.init();
  await SolvedStore.init();
  await CfVerdictStore.init();
  await TimerController.instance.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Khwarizmi',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.navy),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.navy,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashView(),
    );
  }
}
