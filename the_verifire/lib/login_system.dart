import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data_input.dart';

// 🛑 NEW: Widget to preload the asset image
class PreloadLoginSystem extends StatelessWidget {
  const PreloadLoginSystem({super.key});

  @override
  Widget build(BuildContext context) {
    // We use a FutureBuilder to check if the image is ready
    return FutureBuilder(
      future: _preloadAssets(context),
      builder: (context, snapshot) {
        // If snapshot is not done (loading), show a simple colored container
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: Color.fromARGB(255, 255, 209, 125),
            body: Center(
              child: CircularProgressIndicator(color: Colors.orange),
            ),
          );
        }
        // If ready, show the actual LoginSystem
        return const LoginSystem();
      },
    );
  }

  // Function to initiate image caching
  Future<void> _preloadAssets(BuildContext context) async {
    // Pre-cache the image asset so it's instantly available when LoginSystem builds
    await precacheImage(
      const AssetImage('lib/images/VeriFIRE_logo.png'),
      context,
    );
  }
}


class LoginSystem extends StatelessWidget {
  const LoginSystem({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 209, 125),
      appBar: AppBar(
        // Removed leading CloseButton and SystemNavigator.pop() call.
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

                // Centered Image (now pre-cached)
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