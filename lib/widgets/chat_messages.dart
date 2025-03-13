import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app_tutorial_udemy/widgets/message_bubble.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    // get currently logged in user
    final authenticatedUser = FirebaseAuth.instance.currentUser;

    // we want to listen to the stream of messages here
    // NOTE: we used stream builder in main function where we constantly
    // listened to authentication changes
    // NOTE 2: in this case we will be listening to the stream of messages
    // so whenever a new message would arrive, its automatically loaded and
    // displayed here (snapshots in this case returns a stream)
    return StreamBuilder(
      // NOTE: by order by we are making sure that we are are ordering messages
      // with a latest one being on the bottom
      // IMPORTANT: originally it would be descending true, but since we are
      // reverting a list in ListView.builder we need to set it in true
      stream: FirebaseFirestore.instance
          .collection("chat")
          .orderBy("createdAt", descending: true)
          .snapshots(),
      builder: (ctx, chatSnapshots) {
        // show spinner while we are waiting for messages to arrive
        if (chatSnapshots.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // if could be that there are no chat messages at all
        if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
          return const Center(
            child: Text("No messages found."),
          );
        }

        // a good idea would be to check for any errors
        if (chatSnapshots.hasError) {
          return const Center(
            child: Text("Something went wrong."),
          );
        }

        // if we pass both checks we know that there is chat messages data
        // and in that case return a scrollable and performance optimised list
        final loadedMessages = chatSnapshots.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.only(
            bottom: 40,
            left: 13,
            right: 13,
          ),
          // IMPORTANT: all messages are pushed to the bottom of the list (but
          // they are reversed so we need to get messages in order as well, see
          // correction and comment above in stream)
          reverse: true,
          itemCount: loadedMessages.length,
          itemBuilder: (ctx, index) {
            // get current message
            final chatMessage = loadedMessages[index].data();

            // we get next message as it will be important for the styling
            final nexChatMessage = index + 1 < loadedMessages.length
                ? loadedMessages[index + 1].data()
                : null;

            // get user ids from current and next message as we want to compare
            // if they came from the same user (again, used for styling)
            final currentMessageUserId = chatMessage["userId"];
            final nextMessageUserId =
                nexChatMessage != null ? nexChatMessage["userId"] : null;

            final nextUserIsSame = nextMessageUserId == currentMessageUserId;

            // current and next messages are from the same user
            if (nextUserIsSame) {
              return MessageBubble.next(
                message: chatMessage["text"],
                isMe: authenticatedUser!.uid == currentMessageUserId,
              );
            } else {
              return MessageBubble.first(
                userImage: chatMessage["userImage"],
                username: chatMessage["userName"],
                message: chatMessage["text"],
                isMe: authenticatedUser!.uid == currentMessageUserId,
              );
            }
          },
        );
      },
    );
  }
}
