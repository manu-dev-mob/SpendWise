import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/providers.dart';
import 'app/router.dart';
import 'features/auth/presentation/auth_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  runApp(MultiProvider(providers: appProviders, child: const ExpenseWebApp()));
}

class ExpenseWebApp extends StatelessWidget {
  const ExpenseWebApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
      ),
      routerConfig: appRouter,
    );
  }}
  // @override
  // Widget build(BuildContext context) {
  //   return MaterialApp.router(
  //     title: 'Expense Tracker',
  //     debugShowCheckedModeBanner: false,
  //     theme: ThemeData(
  //       useMaterial3: true,
  //       scaffoldBackgroundColor: const Color(0xFFF5F6FA),
  //     ),
  //     routerConfig: appRouter,
  //     builder: (context, child) {
  //       return StreamBuilder<User?>(
  //         stream: FirebaseAuth.instance.authStateChanges(),
  //         builder: (context, snapshot) {
  //           if (snapshot.connectionState == ConnectionState.waiting) {
  //             return const Center(child: CircularProgressIndicator());
  //           }
  //           final user = snapshot.data;
  //           if (user == null) {
  //             // User not logged in → show AuthScreen
  //             return const AuthScreen();
  //           } else {
  //             // User is logged in → show normal routed app
  //             return child!;
  //           }
  //         },
  //       );
  //     },
  //   );
  // }

