import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'otp_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _idController = TextEditingController();
  bool loading = false;

  // IMPORTANT: The function now takes the BuildContext from the Builder widget
  // (We'll wrap the button in the build method below)
  Future<void> handleLogin(BuildContext innerContext) async {
    String id = _idController.text.trim();

    if (id.isEmpty) {
      ScaffoldMessenger.of(innerContext).showSnackBar(
        const SnackBar(content: Text("Please enter your Unique ID")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      // 1. Fetch Phone Number from Firestore using a QUERY
      // 🛑 FIX: Changed from .doc(id).get() to a .where('id', isEqualTo: id) query
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("users")
          .where('id', isEqualTo: id) // Searches the field 'id' for the input value
          .limit(1)
          .get();

      // Check if any document was returned
      if (querySnapshot.docs.isEmpty) {
        setState(() => loading = false);
        ScaffoldMessenger.of(innerContext).showSnackBar(
          const SnackBar(content: Text("User not found")),
        );
        return;
      }

      // Get the first (and only) document found
      DocumentSnapshot doc = querySnapshot.docs.first;

      // 2. Retrieve the phone number. We verified the key is "mobile".
      // NOTE: Firestore keys are case-sensitive. "mobile" must match exactly.
      // We are also assuming the number in Firestore is correctly formatted (e.g., +15551234567)
      String phoneNumber = doc["mobile"];

      // 3. Send OTP using Firebase Auth
      FirebaseAuth auth = FirebaseAuth.instance;

      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await auth.signInWithCredential(credential);
          setState(() => loading = false);
          
          // Auto-login successful
          ScaffoldMessenger.of(innerContext).showSnackBar(
            const SnackBar(content: Text("Auto-verification successful! (TODO: Navigate Home)")),
          );
          // Clear navigation history and go to the start (or a new home screen)
          Navigator.of(innerContext).popUntil((route) => route.isFirst);
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() => loading = false);
          ScaffoldMessenger.of(innerContext).showSnackBar(
            SnackBar(content: Text(e.message ?? "Verification Failed")),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() => loading = false);

          // Navigate to OTP Page, passing the verificationId
          Navigator.push(
            innerContext, // Use innerContext for navigation
            MaterialPageRoute(
              builder: (context) => OTPPage(verificationId: verificationId),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      setState(() => loading = false);
      // Use innerContext for SnackBar call
      ScaffoldMessenger.of(innerContext).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 209, 125),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 209, 125),
        foregroundColor: Colors.black,
        elevation: 0,
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          reverse: true,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  const SizedBox(height: 20),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'Login',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: screenWidth * 0.25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  SizedBox(
                    width: screenWidth * 0.8,
                    child: TextField(
                      controller: _idController,
                      keyboardType: TextInputType.text,
                      maxLength: 10,
                      decoration: InputDecoration(
                        labelText: 'Enter your Unique ID',
                        prefixIcon: const Icon(Icons.person),
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
                            color: Colors.white,
                            width: 2.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20, top: 30),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  // 🛑 FIX: Wrap with Builder to get a context for the button callback
                  child: Builder(
                    builder: (innerContext) {
                      return ElevatedButton(
                        // 🛑 FIX: Pass the innerContext to handleLogin
                        onPressed: loading ? null : () => handleLogin(innerContext), 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        child: loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Login',
                                style:
                                    TextStyle(fontSize: 18, color: Colors.white),
                              ),
                      );
                    }
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