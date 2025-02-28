import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_app_tutorial_udemy/widgets/user_image_picker.dart';

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
  String _enteredUserName = "";

  // avatar image
  File? _selectedImage;

  // flag to say whether we are uploading an image
  bool _isAuthenticating = false;

  void _submit() async {
    // by ! we are telling Flutter that it will be initialised and ready to use
    final isValid = _formKey.currentState!.validate();

    // get values of the form
    if (!isValid) {
      return;
    }

    // check image only if sign up mode, in login mode image is not required
    if (!_isLogin && _selectedImage == null) {
      // show error message...
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
      setState(() {
        _isAuthenticating = true;
      });

      if (_isLogin) {
        final userCredentials = await _fireBase.signInWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
      } else {
        // create new user
        final userCredentials = await _fireBase.createUserWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);

        // store user uploaded image
        // NOTE: ref gives us a reference to the project's cloud storage, child
        // is just a path to the folder (created automatically if does not exist
        // inside the storage)
        final storageRef = FirebaseStorage.instance
            .ref()
            .child("user_images")
            .child("${userCredentials.user!.uid}.jpg");
        await storageRef.putFile(_selectedImage!);
        final imageUrl = await storageRef.getDownloadURL();

        // we can send all via HTTP, but instead again we will use Firebase
        // package (cloud_firebase)
        // NOTE: Firestore works with "collections" (so called folders), and
        // collection will be created if not exists, and collections contain
        // documents
        // GENERALLY: by the looks of it its a document store
        await FirebaseFirestore.instance
            .collection("users")
            .doc(userCredentials.user!.uid)
            .set({
              "username": _enteredUserName,
              "email": _enteredEmail,
              "image_url": imageUrl
            });
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

      // NOTE: we need to make sure that we reset any spinners in case if
      // there will be a failure, otherwise it will be just stuck in spinning
      // state
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme
          .of(context)
          .colorScheme
          .primary,

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
                          if (!_isLogin)
                            UserImagePicker(onPickedImage: (pickedImage) {
                              _selectedImage = pickedImage;
                            }),

                          // email form
                          TextFormField(
                            decoration:
                            InputDecoration(labelText: "Email Address"),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null ||
                                  value
                                      .trim()
                                      .isEmpty ||
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

                          // username
                          if (!_isLogin)
                            TextFormField(
                              decoration: InputDecoration(labelText: "Username"),
                              enableSuggestions: false,
                              validator: (value) {
                                if (value == null || value.isEmpty || value.trim().length <=4) {
                                  return "Please enter at least 4 characters.";
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _enteredUserName = value!;
                              },
                            ),

                          // password form
                          TextFormField(
                            decoration: InputDecoration(labelText: "Password"),
                            // hides characters
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value
                                  .trim()
                                  .length <= 6) {
                                return "Password must be at least 6 characters long";
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredPassword = value!;
                            },
                          ),
                          const SizedBox(height: 12),
                          if (_isAuthenticating)
                            const CircularProgressIndicator(),

                          if (!_isAuthenticating)
                            ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme
                                      .of(context)
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
