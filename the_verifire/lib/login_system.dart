import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data_input.dart';

class LoginSystem extends StatelessWidget {
  const LoginSystem({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    // REMOVED MaterialApp wrapper here
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 209, 125),
      appBar: AppBar(
        // Removed the leading CloseButton and SystemNavigator.pop() call.
        // The AppBar is now clean, allowing the app to stay open.
        backgroundColor: const Color.fromARGB(255, 255, 209, 125),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Empty space at top
            const SizedBox(height: 20),

            // Centered RichText + Image
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Gradient RichText
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      Colors.orange,
                      const Color.fromARGB(255, 230, 26, 11),
                      Colors.orangeAccent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: screenWidth * 0.17,
                      ),
                      children: [
                        const TextSpan(
                          text: 'Welcome',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(
                          text: ' to ',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Colors.white,
                          ),
                        ),
                        const TextSpan(
                          text: '\nVeriFIRE',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Centered Image
                Image.asset(
                  'lib/images/VeriFIRE_logo.png',
                  width: screenWidth * 0.8,
                  height: screenWidth * 0.8,
                ),
              ],
            ),

            // Bottom Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}