import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// a reusable instance of auth for the whole class
final _fireBase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AuthScreen();
  }
}

class _AuthScreen extends State<AuthScreen> {
  // form key that deals with all form state + access to the form
  final _formKey = GlobalKey<FormState>();

  // default mode is login
  bool _isLogin = true;

  String _enteredEmail = "";
  String _enteredPassword = "";

  void _submit() async {
    // by ! we are telling Flutter that it will be initialised and ready to use
    final isValid = _formKey.currentState!.validate();

    // get values of the form
    if (!isValid) {
      return;
    }

    // IMPORTANT: .save() will trigger form's onSaved() build it function and
    // that will in turn will allows to save form variables and make them
    // available for usage
    _formKey.currentState!.save();

    // depending on current screen (whether we are about to login or register)
    // we need to handle scenarios differently
    // NOTE: for simplicity we are just having one try catch block here
    try {
      if (_isLogin) {
        final userCredentials = await _fireBase.signInWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );

      } else {
        final userCredentials = await _fireBase.createUserWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
      }

    } on FirebaseAuthException catch (error) {
      // handle any specific exceptions but for simplicity we just show msg
      // if (error.code == "email-already-in-use") {
      //   // ...
      // }

      // Check if the widget is still mounted before using the context
      if (!mounted) return;

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message.toString() ?? "Authentication failed"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,

      // we all want to be centered
      body: Center(
        // form might be large and especially when a keyboard will be open we
        // want to reach out to all form elements
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 200,
                width: 200,
                // we want to position it exactly as we really want to
                margin:
                    EdgeInsets.only(top: 30, bottom: 20, left: 20, right: 20),
                child: Image.asset("assets/images/chat.png"),
              ),

              // adding a nice looking card element
              Card(
                margin: EdgeInsets.all(20),
                child: SingleChildScrollView(
                  // adding some spacing between the edges of the card and all
                  // main elements
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        // setting as LESS space as possible as it has no
                        // boundaries on a vertical axis
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            decoration:
                                InputDecoration(labelText: "Email Address"),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains("@")) {
                                return "Please enter a valid email address";
                              }
                              return null;
                            },
                            onSaved: (value) {
                              // we know that at this point it won't be null
                              _enteredEmail = value!;
                            },
                          ),
                          TextFormField(
                            decoration: InputDecoration(labelText: "Password"),
                            // hides characters
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.trim().length <= 6) {
                                return "Password must be at least 6 characters long";
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredPassword = value!;
                            },
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer),
                            child: Text(
                              _isLogin ? "Login" : "Signup",
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = !_isLogin;
                              });
                            },
                            child: Text(
                              _isLogin
                                  ? "Create an account"
                                  : "I already have an account",
                            ),
                          )
                        ],
                      ),
                    ),
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
