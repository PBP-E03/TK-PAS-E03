import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'package:steve_mobile/auth/screens/login.dart';

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
          home: const LoginApp(),
        ));
  }
}

class MyHomePage extends StatelessWidget {
  final String title;

  const MyHomePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
          child: Card(
              child: InkWell(
        onTap: () async {
          final response = await request
              .logout("http://127.0.0.1:8000/auth/flutter/logout/");
          String message = response["message"];
          if (context.mounted) {
            if (response['status']) {
              String uname = response["username"];
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("$message Sampai jumpa, $uname."),
              ));
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                ),
              );
            }
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16.0),
          color: Colors.red,
          child: const Text(
            'Logout',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ))),
    );
  }
}
