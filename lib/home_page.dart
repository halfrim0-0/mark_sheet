import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mark_sheet/mark_sheet_user.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  MarkSheetUser markSheetUser = MarkSheetUser();
  // ユーザ名
  late String userName;
  // ユーザが所持するマークシートの数
  late int markSheetNum;
  // ユーザが所持するマークシートのリスト
  late List<String> markSheetList;

  @override
  void initState() {
    super.initState();

    userName = markSheetUser.getUserName();
    markSheetNum = markSheetUser.getMarkSheetNum();
    markSheetList = markSheetUser.getMarkSheetList();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("mark sheet"),
        actions: [
          Padding(
            padding: EdgeInsets.all(10),
            child: PopupMenuButton<String>(
              icon: Icon(Icons.menu),
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem(
                  child: Text(userName + "でログイン中"),
                  enabled: false,
                ),
                PopupMenuItem(child: Text("ログアウト"), value: "logout"),
              ],
              onSelected: (value) async {
                if (value == "logout") {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushNamed(context, "/");
                }
              },
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: markSheetNum,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      markSheetList[index],
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                ),
                Container(
                  child: Row(
                    children: <Widget>[
                      Container(
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: ElevatedButton(
                              child: Text("利用履歴"),
                              onPressed: () async {
                                String markSheetName = markSheetList[index];
                                int questionNum = await markSheetUser
                                    .getQuestionNumFromFirebase(markSheetName);
                                int usedNum = await markSheetUser
                                    .getUsedNumFromFirebase(markSheetName);
                                List<String> usedDateList = await markSheetUser
                                    .getUsedDateListFromFirebase(
                                        markSheetName, usedNum);
                                List<int> scoreList = await markSheetUser
                                    .getScoreListFromFirebase(
                                        markSheetName, usedNum);

                                List<Object> arguments = [
                                  markSheetName,
                                  questionNum,
                                  usedNum,
                                  usedDateList,
                                  scoreList,
                                ];

                                Navigator.pushNamed(context, "/home/history",
                                    arguments: arguments);
                              }),
                        ),
                      ),
                      Container(
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: ElevatedButton(
                              child: Text("使用する"),
                              onPressed: () async {
                                String markSheetName = markSheetList[index];
                                int questionNum = await markSheetUser
                                    .getQuestionNumFromFirebase(markSheetName);
                                int choiceNum = await markSheetUser
                                    .getChoiceNumFromFirebase(markSheetName);
                                List<int> answerList = await markSheetUser
                                    .getAnswerListFromFirebase(
                                        markSheetName, questionNum);
                                List<Object> arguments = [
                                  markSheetName,
                                  questionNum,
                                  choiceNum,
                                  answerList,
                                ];
                                Navigator.pushNamed(context, "/home/solve",
                                    arguments: arguments);
                              }),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, "/home/create");
        },
        tooltip: 'マークシートを作成',
        child: Icon(Icons.add),
      ),
    );
  }
}
