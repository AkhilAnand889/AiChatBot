import 'package:aibot/Screens/Auth.dart';
import 'package:flutter/material.dart';





class IntroPage extends StatefulWidget {
  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  List<Map<String, String>> _introData = [
    {
      'image': 'Assets/images/2156652.png',
      'title': 'Welcome to AI Chatbot',
      'description': 'Chat with our intelligent AI bot!'
    },
    {
      'image': 'Assets/images/2002.i039.010_chatbot_messenger_ai_isometric_set-05.png',
      'title': 'Get Answers Fast',
      'description': 'Ask questions and get instant responses.'
    },
    {
      'image': 'Assets/images/sysadmin_03.png',
      'title': 'Easy to Use',
      'description': 'User-friendly interface for seamless communication.'
    },
  ];

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _startButtonPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _introData.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              return _buildIntroPage(_introData[index]);
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildPageIndicator(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _currentPage == _introData.length - 1
          ? FloatingActionButton(
              onPressed: _startButtonPressed,
              child: Icon(Icons.arrow_forward),
            )
          : null,
    );
  }

  Widget _buildIntroPage(Map<String, String> data) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.0),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(data['image']!, height: 300),
          SizedBox(height: 32.0),
          Text(
            data['title']!,
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.0),
          Text(
            data['description']!,
            style: TextStyle(fontSize: 16.0),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageIndicator() {
    List<Widget> indicators = [];
    for (int i = 0; i < _introData.length; i++) {
      indicators.add(
        i == _currentPage
            ? _buildIndicator(true)
            : _buildIndicator(false),
      );
    }
    return indicators;
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      height: 8.0,
      width: isActive ? 24.0 : 16.0,
      decoration: BoxDecoration(
        color: isActive ? Colors.blue : Colors.grey,
        borderRadius: BorderRadius.circular(12.0),
      ),
    );
  }
}
