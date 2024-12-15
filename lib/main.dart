import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'package:steve_mobile/main/screens/welcome_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Provider(
        create: (_) {
          CookieRequest request = CookieRequest();
          return request;
        },
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
        ));
  }
}
