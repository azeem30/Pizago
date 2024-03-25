import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import './signup.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
            options: FirebaseOptions(
                apiKey: "AIzaSyDcHaOwW07Td3wADrgVdKNPLpuIHuTrWiQ",
                appId: "1:33948675983:android:ff41586d9814bd910525fa",
                messagingSenderId: "33948675983",
                projectId: "flutterbase-9253d"))
        .then((value) => print(value));
  } catch (error) {
    print("Error Initializing Firebase, $error");
  } finally {
    runApp(const MyApp());
  }
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
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Delay for 2 seconds and then navigate to Signup page
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Signup()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('assets/images/icon.png'),
      ),
    );
  }
}
