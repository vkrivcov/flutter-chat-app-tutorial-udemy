import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() {
    return _NewMessage();
  }
}

class _NewMessage extends State<NewMessage> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _submitMessage() async {
    final enteredMessage = _messageController.text;

    if (enteredMessage.trim().isEmpty) {
      return;
    }

    // automatically close the keyboard
    FocusScope.of(context).unfocus();

    // reset text to empty
    _messageController.clear();

    // send to firebase
    // get currently logged-in user (available globally as soon as we add
    // FirebaseAuth package and use it elsewhere)
    final user = FirebaseAuth.instance.currentUser!;

    // note: user name and image url were not stored as a part of auth so we
    // need to retrieve it from firestore and it will be based on the id.
    // IMPORTANT: to save unnecessary HTTP requests its possible to store data
    // locally, but here for example purposes we are using http requests to
    // FireStore
    final userData = await FirebaseFirestore.instance.collection("users").doc(user.uid).get();

    // NOTE: add will create a unique id (before we used .doc where we give its
    // name ourselves)
    FirebaseFirestore.instance.collection("chat").add({
      "text": enteredMessage,
      "createdAt": Timestamp.now(),
      "userId": user.uid,
      "userName": userData.data()!["username"],
      "userImage": userData.data()!["image_url"]
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 1, bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              decoration: const InputDecoration(labelText: "Send a message..."),
              controller: _messageController,
            ),
          ),
          IconButton(
            color: Theme.of(context).colorScheme.primary,
            onPressed: _submitMessage,
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
