import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app_tutorial_udemy/widgets/chat_messages.dart';

import '../widgets/new_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() {
    return _ChatScreenState();
  }
}

class _ChatScreenState extends State<ChatScreen> {
  void setupPushNotifications() async {
    // we need to ask permissions to receive push notifications
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();

    // IMPORTANT: is the address of the device where its currently running and
    // we will need this device address to target it with push notifications
    // i.e. push notifications uses that device address to send push
    // notifications and that token can be used in multiple areas (e.g. stored
    // in the database to target specific users and this is what usually happens
    // in real world applications, right now we will just print, copy/paste it
    // in firebase to send the message)
    // works boith in android and ios
    final token = await fcm.getToken();
    print(token);

    // IMPORTANT: instead of targeting individual devices as was mentioned above
    // it does make sense in this case to target a topic (e.g. chat) and then
    // send push notifications to all devices that are subscribed to that topic
    // we would create a topic in Firebase console and then subscribe to it as
    // we did here
    fcm.subscribeToTopic("chat");
  }

  @override
  void initState() {
    super.initState();

    setupPushNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FlutterChat"),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: Icon(
              Icons.exit_to_app,
              color: Theme.of(context).colorScheme.primary,
            ),
          )
        ],
      ),
      body: Column(
        children: const [
          Expanded(
            child: ChatMessages(),
          ),
          NewMessage(),
        ],
      ),
      // body: const Center(
      //   child: Text("Logged in!"),
      // ),
    );
  }
}
