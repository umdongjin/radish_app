import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:radish_app/screens/start/address_page.dart';
import 'package:radish_app/screens/start/auth_page.dart';
import 'package:radish_app/screens/start/intro_page.dart';

// 비머가드 false 리턴화면
class StartScreen extends StatelessWidget {
  // 페이지 컨트롤러 인스턴스
  PageController _pageController = PageController();

  StartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider<PageController>.value(
      value: _pageController,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: PageView(
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
          children: [
            IntroPage(),
            AddressPage(),
            AuthPage(),
          ],
        ),
      ),
    );
  }
}