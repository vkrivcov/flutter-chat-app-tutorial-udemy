import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app_tutorial_udemy/screens/auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_chat_app_tutorial_udemy/screens/chat.dart';
import 'package:flutter_chat_app_tutorial_udemy/screens/splash.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterChat',
      theme: ThemeData().copyWith(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 63, 17, 177)),
      ),
      // we show Auth screen if user is not logged in or registered i.e. no
      // token stored or Chat screen instead
      // IMPORTANT: similar to FutureBuilder that was used to listen to the future and
      // render different screens based on the state of that Future, StreamBuilder
      // is very similar, but the difference is that Future will be done when
      // its resolved (i.e. produce one value or error) BUT StreamBuilder is
      // capable producing multiple results over the time AND in this case
      // steam is FirebaseAuth.instance.authStateChanges() i.e. any changes
      // that are related to auth state change with firebase that we essentially
      // embedded in this project
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot) {
          // check if the data is still loading and if so add the Splash screen
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }

          // there would not be any data if user is not logged in therefore that
          // statement should be true for logged in users
          if (snapshot.hasData) {
            return const ChatScreen();
          }
          // otherwise redirect them Auth page to login or register
          return const AuthScreen();
        },
      ),
    );
  }
}
