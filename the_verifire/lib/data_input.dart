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

  Future<void> handleLogin(BuildContext innerContext) async {
    String id = _idController.text.trim();

    if (id.isEmpty) {
      ScaffoldMessenger.of(innerContext)
          .showSnackBar(const SnackBar(content: Text("Please enter your Unique ID")));
      return;
    }

    setState(() => loading = true);

    try {
      // Query Firestore
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("users")
          .where('id', isEqualTo: id)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        setState(() => loading = false);
        ScaffoldMessenger.of(innerContext)
            .showSnackBar(const SnackBar(content: Text("User not found")));
        return;
      }

      DocumentSnapshot doc = querySnapshot.docs.first;
      Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;

      String? phoneNumber = userData["mobile"];

      if (phoneNumber == null || phoneNumber.isEmpty) {
        setState(() => loading = false);
        ScaffoldMessenger.of(innerContext)
            .showSnackBar(const SnackBar(content: Text("Mobile number missing.")));
        return;
      }

      FirebaseAuth auth = FirebaseAuth.instance;

      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await auth.signInWithCredential(credential);
          setState(() => loading = false);
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() => loading = false);
          ScaffoldMessenger.of(innerContext)
              .showSnackBar(SnackBar(content: Text(e.message ?? "Error")));
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() => loading = false);

          Navigator.push(
            innerContext,
            MaterialPageRoute(
              builder: (context) => OTPPage(
                verificationId: verificationId,
                userData: userData,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(innerContext)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
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
        leading: BackButton(onPressed: () => Navigator.pop(context)),
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

                  // BIG “Login”
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

                  // White rounded text field
                  SizedBox(
                    width: screenWidth * 0.8,
                    child: TextField(
                      controller: _idController,
                      maxLength: 10,
                      decoration: InputDecoration(
                        labelText: "Enter your Unique ID",
                        prefixIcon: const Icon(Icons.person),
                        filled: true,
                        fillColor: Colors.white,
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // BUTTON
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: Builder(
                    builder: (innerContext) {
                      return ElevatedButton(
                        onPressed: loading ? null : () => handleLogin(innerContext),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Login',
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
