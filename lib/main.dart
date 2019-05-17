import 'package:flutter/material.dart';
import 'package:meme/screen/auth/auth.dart';
import 'package:meme/screen/auth/auth_provider.dart';
import 'routes.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AuthProvider(
      auth: Auth(),
      child: MaterialApp(
        title: 'Meme Wallet',
        theme: ThemeData(
          primaryColor: Colors.grey[850],
        ),
        home: Routes(),
      ),
    );
  }
}