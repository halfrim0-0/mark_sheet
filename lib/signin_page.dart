import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mark_sheet/mark_sheet_user.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  String email = "";
  String password = "";

  String alert = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("mark sheet"),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // メールアドレス
                TextField(
                    decoration: InputDecoration(labelText: "メールアドレス"),
                    onChanged: (String value) {
                      setState(() {
                        email = value;
                      });
                    }),
                // パスワード
                TextField(
                    decoration: InputDecoration(labelText: "パスワード"),
                    obscureText: true,
                    onChanged: (String value) {
                      setState(() {
                        password = value;
                      });
                    }),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                      child: Text("ログイン"),
                      onPressed: () async {
                        try {
                          // 認証
                          final FirebaseAuth auth = FirebaseAuth.instance;
                          await auth.signInWithEmailAndPassword(
                            email: email,
                            password: password,
                          );

                          // データベースからデータを取得
                          MarkSheetUser markSheetUser = MarkSheetUser();
                          await markSheetUser.getUserIdFromFirebase();
                          await markSheetUser.getUserNameFromFirebase();
                          await markSheetUser.getMarkSheetNumFromFirebase();
                          await markSheetUser.getMarkSheetListFromFirebase();

                          await Navigator.pushNamed(context, "/home");
                        } catch (e) {
                          setState(() {
                            alert = "ログインに失敗しました。";
                          });
                        }
                      }),
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  child: Text(alert),
                ),
              ]),
        ),
      ),
    );
  }
}
