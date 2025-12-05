import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OTPPage extends StatefulWidget {
  // 1. Accept verificationId
  final String verificationId;
  const OTPPage({super.key, required this.verificationId});

  @override
  State<OTPPage> createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  final int otpLength = 6;
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < otpLength; i++) {
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    }
  }

  @override
  void dispose() {
    for (var ctrl in _controllers) ctrl.dispose();
    for (var node in _focusNodes) node.dispose();
    super.dispose();
  }

  Future<void> _verifyOTP() async {
    String otp = _controllers.map((c) => c.text).join();

    if (otp.length != otpLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the complete 6-digit OTP")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      // Create a PhoneAuthCredential with the verificationId and OTP
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId, // Use the received verificationId
        smsCode: otp,
      );

      // Sign the user in with the credential
      await FirebaseAuth.instance.signInWithCredential(credential);

      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login Successful!")),
      );
      
      // Clear the navigation stack and go to the start (or a new home screen)
      Navigator.of(context).popUntil((route) => route.isFirst);

    } on FirebaseAuthException catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "OTP verification failed.")),
      );
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    // REMOVED MaterialApp wrapper here
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 209, 125),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 209, 125),
        foregroundColor: Colors.black,
        elevation: 0,
        leading: BackButton(
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          reverse: true,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top content
              Column(
                children: [
                  const SizedBox(height: 20),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'OTP Login',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: screenWidth * 0.15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),

                  // OTP boxes (rounded corners)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(otpLength, (index) {
                      return SizedBox(
                        width: 50,
                        height: 50,
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            counterText: "",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(
                                  color: Colors.orange, width: 2),
                            ),
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty && index < otpLength - 1) {
                              _focusNodes[index + 1].requestFocus();
                            }
                            if (value.isEmpty && index > 0) {
                              _focusNodes[index - 1].requestFocus();
                            }
                          },
                        ),
                      );
                    }),
                  ),
                  
                  // Removed the redundant "Send OTP" button area
                  const SizedBox(height: 20),
                  
                  // Resend button (needs implementation for resending OTP)
                  TextButton(
                    onPressed: loading ? null : () {
                      // TODO: Implement OTP resend logic here
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Resend OTP functionality not yet implemented.")),
                      );
                    }, 
                    child: const Text(
                      "Resend OTP", 
                      style: TextStyle(color: Colors.black54)
                    )
                  )

                ],
              ),

              // Bottom verify button
              Padding(
                padding: const EdgeInsets.only(bottom: 20, top: 30),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: loading ? null : _verifyOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0), // rounded button
                      ),
                    ),
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Verify OTP',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}