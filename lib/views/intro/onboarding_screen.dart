/*import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'image': 'assets/images/onboarding/onboarding1.jpg', // Download from Undraw or Storyset
      'title': 'Welcome to Student Sahara!',
      'description': 'Empowering students to continue their education without financial worries.',
    },
    {
    'image': 'assets/images/onboarding/onboarding1.jpg',
      'title': 'Financial Support & Guidance',
      'description': 'Get scholarships, mentorship, and resources to achieve your dreams.',
    },
    {
    'image': 'assets/images/onboarding/onboarding1.jpg',
      'title': 'Your Journey Begins Here!',
      'description': 'Let’s help you take the next step toward success and a brighter future.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _controller,
        itemCount: _onboardingData.length,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemBuilder: (context, index) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(_onboardingData[index]['image']!, height: 250),
            const SizedBox(height: 30),
            Text(
              _onboardingData[index]['title']!,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _onboardingData[index]['description']!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _onboardingData.length,
                    (dotIndex) => Container(
                  margin: const EdgeInsets.only(right: 8),
                  height: 10,
                  width: _currentPage == dotIndex ? 12 : 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == dotIndex ? Colors.blueAccent : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),
            if (_currentPage == _onboardingData.length - 1)
              ElevatedButton(
                onPressed: () {
                  // Navigate to login/registration screen
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text('Get Started'),
              ),
          ],
        ),
      ),
    );
  }
}

 */
/*
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';


class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: 'Welcome to Student Sahara!',
          body: 'Empowering students to continue their education without financial worries.',
          image: Center(
            child:Image.asset(
                'assets/images/onboarding/onboarding1.png'
            ),
          ),
        ),
        PageViewModel(
          title: 'Financial Support & Guidance',
          body: 'Get scholarships, loans, and mentorship to achieve your dreams.',
          image: Center(
            child:Image.asset(
                'assets/images/onboarding/donation.jpg'
            ),
          ),
        ),
        PageViewModel(
          title: 'Your Journey Begins Here!',
          body: 'Let’s help you take the next step toward success and a brighter future.',
          image: Center(
            child:Image.asset(
                'assets/images/onboarding/welcome.png'
            ),
          ),
        ),
      ],
      onDone: () => Navigator.of(context).pushReplacementNamed('/home'),
      showBackButton: true,
      back: Icon(Icons.arrow_back, color: Colors.blue),
      showSkipButton: true,
      skip: Text('Skip', style: TextStyle(color: Colors.blueGrey,letterSpacing: 0.25, )),
      next: Container(
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blue,
        ),
        child: Icon(Icons.arrow_forward, color: Colors.white, size: 28),
      ),
      done: Text('Done', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blue)),
      dotsDecorator: DotsDecorator(
        size: Size(10.0, 10.0),
        color: Colors.grey,
        activeSize: Size(22.0, 10.0),
        activeColor: Colors.blue,
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        spacing: EdgeInsets.symmetric(horizontal: 2.0),
      ),
      showNextButton: true,
    );
  }
}




class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home Screen')),
      body: Center(child: Text('Welcome Home!')),
    );
  }
}

 */
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        PageViewModel(
          titleWidget: Column(
            children: [
              Text(
                'Welcome to Student Sahara!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 28, // Increase font size
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,

                ),

              ),
              const SizedBox(height: 10),
            ],
          ),
          bodyWidget: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Empowering students to continue their education without financial worries.',
              textAlign: TextAlign.center,
              style: GoogleFonts.aBeeZee(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,

              ),
            ),
          ),
          image: Padding(
            padding: const EdgeInsets.only(top: 40), // Adjust spacing
            child: Center(
              child: Image.asset(
                'assets/images/onboarding/onboarding1_2.png',
                height: 260, // Adjust size
                opacity: AlwaysStoppedAnimation(0.9), // Adjust opacity
              ),
            ),
          ),
        ),
        PageViewModel(
          titleWidget: Column(
            children: [
              Text(
                'Financial Support & Guidance',
                textAlign: TextAlign.center,
                style:  GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
          bodyWidget: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Get scholarships, loans, and mentorship to achieve your dreams.',
              textAlign: TextAlign.center,
              style:  GoogleFonts.aBeeZee(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          image: Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Center(
              child: Image.asset(
                'assets/images/onboarding/loan.jpg',
                height: 260,
                opacity: AlwaysStoppedAnimation(0.9),
              ),
            ),
          ),
        ),
        PageViewModel(
          titleWidget: Column(
            children: [
              Text(
                'Your Journey Begins Here!',
                textAlign: TextAlign.center,
                style:  GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
          bodyWidget: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Let’s help you take the next step toward success and a brighter future.',
              textAlign: TextAlign.center,
              style:  GoogleFonts.aBeeZee(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          image: Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Center(
              child: Image.asset(
                'assets/images/onboarding/classroom.jpg',
                height: 260,
                opacity: AlwaysStoppedAnimation(0.9),
              ),
            ),
          ),
        ),
      ],

      /// 👉 Navigating to **Welcome Screen** after Onboarding
      onDone: () => Navigator.of(context).pushReplacementNamed('/welcome'),
      showBackButton: true,
      back: Icon(Icons.arrow_back, color: Colors.blue,size: 28,),
      showSkipButton: true,
      skip: Text('Skip', style: TextStyle(color: Colors.grey.shade600, letterSpacing: 0.25)),
      next: Container(
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blue,
        ),
        child: Icon(Icons.arrow_forward, color: Colors.white, size: 28),
      ),
      done: Text('Done', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blue)),
      dotsDecorator: DotsDecorator(
        size: Size(10.0, 10.0),
        activeSize: Size(22.0, 10.0),
        activeColor: Colors.blue,
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        spacing: EdgeInsets.symmetric(horizontal: 3.0),
      ),
      showNextButton: true,
    );
  }
}



