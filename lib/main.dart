import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'solve_page.dart';
import 'create_answer_page.dart';
import 'create_page.dart';
import 'history_page.dart';
import 'firebase_options.dart';
import 'home_page.dart';
import 'signup_page.dart';
import 'signin_page.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'mark sheet',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        routes: {
          "/": (context) => IndexPage(),
          "/signup": (context) => SignUpPage(),
          "/signin": (context) => SignInPage(),
          "/home": (context) => HomePage(),
          "/home/create": (context) => CreatePage(),
          "/home/create/answer": (context) => CreateAnswerPage(),
          "/home/history": (context) => HistoryPage(),
          "/home/solve": (context) => SolvePage(),
        });
  }
}

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("mark sheet"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(5),
              child: Text(
                "mark sheet にログイン",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  backgroundColor: Colors.white10,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(5),
              child: SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text("ログイン"),
                    onPressed: () {
                      Navigator.pushNamed(context, "/signin");
                    }),
              ),
            ),
            Container(
              margin: EdgeInsets.all(5),
              child: SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text("ユーザ登録"),
                    onPressed: () {
                      Navigator.pushNamed(context, "/signup");
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
