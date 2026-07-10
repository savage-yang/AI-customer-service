import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/chat_provider.dart';
import 'providers/video_provider.dart';
import 'screens/chat_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VideoServiceProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Support',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'PingFang SC',
        scaffoldBackgroundColor: const Color(0xFF0B1628),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF71A7FF),
          brightness: Brightness.dark,
        ).copyWith(
          background: const Color(0xFF0B1628),
          surface: const Color(0xFF18253A),
          primary: const Color(0xFF75F6D1),
          secondary: const Color(0xFF71A7FF),
          tertiary: const Color(0xFF31456B),
          onPrimary: const Color(0xFF041320),
          onSecondary: const Color(0xFFECF3FF),
          onSurface: const Color(0xFFECF3FF),
        ),
        cardColor: const Color(0xD918253A),
        dividerColor: const Color(0x2EFFFFFF),
        shadowColor: const Color(0x66000000),
        splashColor: const Color(0x2275F6D1),
        highlightColor: Colors.transparent,
        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(0xE0182740),
          contentTextStyle: const TextStyle(color: Color(0xFFECF3FF)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0x1FFFFFFF)),
          ),
          behavior: SnackBarBehavior.floating,
        ),
        textTheme: ThemeData.dark().textTheme.apply(
              bodyColor: const Color(0xFFECF3FF),
              displayColor: const Color(0xFFECF3FF),
            ),
      ),
      home: const ChatScreen(),
    );
  }
}
