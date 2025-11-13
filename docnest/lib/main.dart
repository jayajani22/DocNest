import 'package:docnest/providers/theme_provider.dart';
import 'package:docnest/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:docnest/screens/login_screen.dart';
import 'package:docnest/screens/signup_screen.dart';
import 'package:docnest/screens/dashboard_screen.dart';
import 'package:docnest/screens/documents_screen.dart';
import 'package:docnest/screens/notes_screen.dart';
import 'package:docnest/screens/password_vault_screen.dart';
import 'package:docnest/screens/profile_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:docnest/api/api_service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await apiService.init();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'DocNest',
                theme: AppTheme.lightTheme(context),
                darkTheme: AppTheme.darkTheme(context),
                themeMode: themeProvider.themeMode,
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
            },
          );
        });
  }
}