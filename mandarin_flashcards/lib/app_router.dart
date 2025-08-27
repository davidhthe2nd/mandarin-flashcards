import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


import 'ui/screens/menu_screen.dart';
import 'ui/screens/learn_screen.dart';
import 'ui/screens/options_screen.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const MainMenuScreen()),
    GoRoute(path: '/learn', builder: (context, state) => const LearnScreen()),
    GoRoute(path: '/options', builder: (context, state) => const OptionsScreen()),
  ],
);


// keep your Options screen stub or real one if you have it
class OptionsScreenStub extends StatelessWidget {
  const OptionsScreenStub({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Options (stub)')),
  );
}