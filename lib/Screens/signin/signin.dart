import 'package:flutter/material.dart';
import 'package:alert/Screens/signin/components/signin_body.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SignInPage(),
      ),
    );
  }
}
