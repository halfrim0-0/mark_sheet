import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'mark_sheet_user.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  String userName = "";
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
                // ユーザ名
                TextField(
                    decoration: InputDecoration(labelText: "ユーザ名"),
                    onChanged: (String value) {
                      setState(() {
                        userName = value;
                      });
                    }),
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
                      child: Text("登録"),
                      onPressed: () async {
                        try {
                          final FirebaseAuth auth = FirebaseAuth.instance;
                          await auth.createUserWithEmailAndPassword(
                              email: email, password: password);
                          final user = auth.currentUser;
                          if (user != null) {
                            int markSheetNum = 0;
                            final userId = user.uid;
                            await FirebaseFirestore.instance
                                .collection("users")
                                .doc(userId)
                                .set({
                              "markSheetNum": markSheetNum,
                              "userName": userName,
                              "userId": userId
                            });
                          }

                          // データベースからデータを取得
                          MarkSheetUser markSheetUser = MarkSheetUser();
                          await markSheetUser.getUserIdFromFirebase();
                          await markSheetUser.getUserNameFromFirebase();
                          await markSheetUser.getMarkSheetNumFromFirebase();
                          await markSheetUser.getMarkSheetListFromFirebase();

                          await Navigator.pushNamed(context, "/home");
                        } catch (e) {
                          setState(() {
                            alert = "登録に失敗しました。";
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
