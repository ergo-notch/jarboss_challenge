import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jarboss_challenge/core/ui/app_images.dart';

import 'features/characters/presentation/characters_page.dart';

class SplashScreen extends StatefulWidget {
  static const String path = '/';
  static const String name = 'splash-screen';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    loadAnimation();
  }

  void loadAnimation() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        context.goNamed(CharactersPage.name);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        height: double.infinity,
        child: Image.asset(AppImages.splashScreen, fit: BoxFit.cover),
      ),
    );
  }
}
