import 'package:flutter/material.dart';
import 'package:skit_bfb/Patient_end/ambs.dart';
import 'package:skit_bfb/Patient_end/diet_screen.dart';
import 'package:skit_bfb/Patient_end/doc_prescription/first_page.dart';
import 'package:skit_bfb/Patient_end/healthupdates.dart';
import 'package:skit_bfb/Patient_end/medflow_splash.dart';
import 'package:skit_bfb/Patient_end/take_appointment.dart';
import 'hosp_list.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppColors {
  static const Color appPrimary = Color(0xFF007069);
  static const Color appSecondary = Color(0xFFC5D4E5);
  static const Color appBackground = Color(0xFFFFFFFF);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MedFlowLoadingScreen(),

      
    );
  }
}