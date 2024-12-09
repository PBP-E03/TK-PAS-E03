import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'package:steve_mobile/auth/screens/login.dart';
import 'package:steve_mobile/steakhouse_page.dart';

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

class HomePage extends StatelessWidget {
  final String? title;

  const HomePage({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? "Steve Mobile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final request = context.read<CookieRequest>();
              final response = await request.logout(
                  "http://127.0.0.1:8000/auth/flutter/logout/");
              if (response['status'] && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("${response['message']}")),
                );
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              }
            },
          )
        ],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate to a single SteakhousePage
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SteakhousePage(
                  title: "Steakhouse Details",
                ),
              ),
            );
          },
          child: const Text("Go to Steakhouse Page"),
        ),
      ),
    );
  }
}

