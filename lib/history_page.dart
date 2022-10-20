import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mark_sheet/mark_sheet_user.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late String markSheetName; // マークシート名

  late String userName; // ユーザ名
  late int questionNum; // 問題数
  late int usedNum; // 使われた回数
  late List<String> usedDateList; // 使われた日付のリスト
  late List<int> scoreList; // 点数のリスト

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    List<Object> argumentsFromHomePage =
        ModalRoute.of(context)?.settings.arguments as List<Object>;
    markSheetName = argumentsFromHomePage[0] as String;
    questionNum = argumentsFromHomePage[1] as int;
    usedNum = argumentsFromHomePage[2] as int;
    usedDateList = argumentsFromHomePage[3] as List<String>;
    scoreList = argumentsFromHomePage[4] as List<int>;

    MarkSheetUser markSheetUser = MarkSheetUser();
    userName = markSheetUser.getUserName();

    for (int i = 0; i < usedNum; i++) {
      List<String> usedDateSplitted = usedDateList[i].split("_");
      String usedDate = usedDateSplitted[0] +
          "/" +
          usedDateSplitted[1] +
          "/" +
          usedDateSplitted[2] +
          " " +
          usedDateSplitted[3] +
          ":" +
          usedDateSplitted[4] +
          ":" +
          usedDateSplitted[5];
      usedDateList[i] = usedDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(markSheetName),
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
          itemCount: usedNum,
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
                    // 利用日
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          usedDateList[index],
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ),
                    ),
                    // 点数
                    Container(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          scoreList[index].toString() +
                              " / " +
                              questionNum.toString() +
                              " 点",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ),
                    ),
                  ]),
            );
          }),
    );
  }
}
