import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

// Screens
import 'package:steve_mobile/main/screens/welcome_page.dart';

// Providers
import 'package:steve_mobile/main/providers/user_provider.dart';

void main() {
  runApp(const SteveApp());
}

class SteveApp extends StatelessWidget {
  const SteveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provides CookieRequest for handling Django authentication
        Provider<CookieRequest>(
          create: (_) => CookieRequest(),
        ),
        // Provides UserProvider for managing user-specific state
        ChangeNotifierProvider<UserProvider>(
          create: (_) => UserProvider(),
        ),
      ],
      child: MaterialApp(
        title: "Steve Mobile",
        theme: ThemeData(
          primarySwatch: Colors.red,
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: Colors.red,
            secondary: Colors.redAccent,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

