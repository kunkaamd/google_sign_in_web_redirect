import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in_web_redirect/google_sign_in_web_redirect.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:http/http.dart' as http;

void main() {
  GoogleSignWeb.getQueryParameters();///make sure add this line
  setPathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google SignIn Web Redirect Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      onGenerateRoute: (settings) {/// fix issue "There was no corresponding route" with query params
        if (settings.name?.contains("/login") ?? false) {
          return MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          );
        }
        return null;
      },
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/main': (context) => const MainScreen(),
      },
      initialRoute: '/welcome',
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome"),
      ),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.teal,
            onPrimary: Colors.white,
            onSurface: Colors.grey,
          ),
          onPressed: () {
            Navigator.pushNamed(context, '/login');
          },
          child: const Text("Go to login screen"),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  final SignInGoogleQueryParameters? queryParameters;

  const LoginScreen({Key? key, this.queryParameters}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  @override
  void initState() {
    super.initState();
    initGoogleSignIn();
  }

  initGoogleSignIn() async {
    if(kIsWeb) {
      GoogleSignWeb.init(
        ///id_token if you only want get user_id
        ///code if you need basic profile, access_token
        responseType: "code",
        scopes: ['email', 'profile'],
      );
      if(GoogleSignWeb.instance?.queryParameters?.idToken != null) {
        final jwt = await GoogleSignWeb.instance!.verifyToken();
        final userId = jwt.sub;
        Navigator.pushNamed(context, '/main',arguments: userId);
      } else if (GoogleSignWeb.instance?.queryParameters?.code != null) {
        ///TODO step 1: send code to Server side to take ID Token & basic profile(name, displayname, picture)
        /// we can't make this api from Client side because you need client_secret.
        /// POST /token HTTP/1.1
        /// Host: oauth2.googleapis.com
        /// Content-Type: application/x-www-form-urlencoded
        ///
        /// code=4/P7q7W91a-oMsCeLvIaQm6bTrgtp7&
        /// client_id=your-client-id&
        /// client_secret=your-client-secret&
        /// redirect_uri=https%3A//oauth2.example.com/code&
        /// grant_type=authorization_code
        /// more details: https://developers.google.com/identity/protocols/oauth2/openid-connect#exchangecode
        ///
        ///TODO step 2: verify token get from response Server side
        ///
        /// GoogleSignWeb.instance.token = "YOUR_ID_TOKEN_RESPONSE_FROM_SERVER";
        /// GoogleSignWeb.instance.verifyToken();

        try {
          final response = await http.post(Uri.parse("https://six-colts-rhyme-116-110-109-131.loca.lt/auth/idToken"),body: {
            "code":  GoogleSignWeb.instance!.queryParameters!.code,
          },headers: {
            "Access-Control_Allow_Origin": "*"
          });
          final responseData = jsonDecode(response.body);
          GoogleSignWeb.instance!.token = responseData['id_token'];
          /// final accessToken = responseData['access_token'];
          final jwt = await GoogleSignWeb.instance!.verifyToken();
          Navigator.pushNamed(context, '/main',arguments: jwt.name);
        } catch (_) {
          print(_.toString());
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.teal,
            onPrimary: Colors.white,
            onSurface: Colors.grey,
          ),
          onPressed: () {
            GoogleSignWeb.instance?.signIn();
          },
          child: const Text("Sign In with Google"),
        ),
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userId = ModalRoute.of(context)!.settings.arguments as String? ?? "";
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Text("Hello $userId"),
    );
  }
}
