import 'package:flutter/material.dart';
import 'package:docnest/screens/login_screen.dart';
import 'package:docnest/screens/signup_screen.dart';
import 'package:docnest/screens/dashboard_screen.dart';
import 'package:docnest/screens/documents_screen.dart';
import 'package:docnest/screens/notes_screen.dart';
import 'package:docnest/screens/password_vault_screen.dart';
import 'package:docnest/screens/profile_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:docnest/api/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await apiService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context , child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'DocNest',
          theme: ThemeData(
            primarySwatch: Colors.deepPurple,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            textTheme: GoogleFonts.latoTextTheme(
              Theme.of(context).textTheme,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.deepPurple,
            ),
            cardTheme: CardThemeData(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              selectedItemColor: Colors.deepPurple,
              unselectedItemColor: Colors.grey,
              showUnselectedLabels: true,
            ),
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              },
            ),
          ),
          initialRoute: '/login',
          routes: {
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignupScreen(),
            '/dashboard': (context) => const DashboardScreen(),
            '/documents': (context) => const DocumentsScreen(),
            '/notes': (context) => const NotesScreen(),
            '/password-vault': (context) => const PasswordVaultScreen(),
            '/profile': (context) => const ProfileScreen(),
          },
        );
      }
    );
  }
}