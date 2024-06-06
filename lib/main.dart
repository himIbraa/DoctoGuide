// ignore_for_file: unused_local_variable, prefer_const_constructors

import 'package:dio/dio.dart';
import 'package:doctoguidedoctorapp/firebase_options.dart';
import 'package:provider/provider.dart';
import 'models/request.dart';
import 'screens/home/consultationpage.dart';
import 'screens/loginSignUp/login.dart';
import 'screens/loginSignUp/signupStep2.dart';
import 'screens/profile/myInformation.dart';
import 'screens/profile/my_profile.dart';
import 'screens/profile/professionalDocuments.dart';
import 'screens/request page/consultationrequestpage.dart';
import 'screens/request page/new_consultation.dart';
import 'screens/splach/splash.dart';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

final dio = Dio();
Future<void> main() async {
  await Supabase.initialize(
    url: 'https://gkgupdxpofpowtfwcufj.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdrZ3VwZHhwb2Zwb3d0ZndjdWZqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTMxMzM2NDcsImV4cCI6MjAyODcwOTY0N30.YQ1gz3dYcCVoA874jZDQ8-YPh02ib1wl1AWxZwQyXtE',
  );
  final supabase = Supabase.instance.client;

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  

  runApp(
    MultiProvider( 
      providers: [ 
        ChangeNotifierProvider<Request>(
          create: (context) => Request(),
        ),
      ],
    child: const MyApp()
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      debugShowCheckedModeBanner: false, 
      routes: { 
      '/home'     : (context) => ConsultationPage(), 
      '/request'  : (context) => ConsultationRequestPage(), 
      '/profile'   : (context) => MyProfile(), 
      '/New Consultation' : (context) => NewConsultation(),
      },
      home: SplashScreen(),
    );
  }
}
