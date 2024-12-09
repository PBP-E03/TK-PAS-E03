import 'package:flutter/material.dart';
import 'package:steve_mobile/review/review_page.dart';

class SteakhousePage extends StatelessWidget {
  final String title;

  const SteakhousePage({Key? key, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReviewsPage(steakhouseName: title),
              ),
            );
          },
          child: const Text("View Reviews"),
        ),
      ),
    );
  }
}