import 'package:flutter/material.dart';
import 'package:mark_sheet/mark_sheet_user.dart';

class SolvePage extends StatefulWidget {
  const SolvePage({super.key});
  @override
  _SolvePageState createState() => _SolvePageState();
}

class _SolvePageState extends State<SolvePage> {
  MarkSheetUser markSheetUser = MarkSheetUser();
  late String markSheetName; // マークシート名
  late int questionNum; // 問題数
  late int choiceNum; // 選択肢数
  late List<int> answerList; // answerList[i] : i問目の答え

  late List<int> choiceList; // choiceList[i] : i問目に選んだもの
  late List<int> choiceGroupValue; // choiceGroupValue[i] : i問目のgroupValue
  List<List<Color>> choiceTextColor = []; // 選択肢の文字色
  late int score; // 点数
  String result = "未採点"; // 採点結果
  bool isChecked = false; // 採点したかどうか
  bool canRetry = false; // 再挑戦ボタンが有効かどうか

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    List<Object> argumentsFromDetailPage =
        ModalRoute.of(context)?.settings.arguments as List<Object>;
    markSheetName = argumentsFromDetailPage[0] as String;
    questionNum = argumentsFromDetailPage[1] as int;
    choiceNum = argumentsFromDetailPage[2] as int;
    answerList = argumentsFromDetailPage[3] as List<int>;

    choiceList = List.generate(questionNum, (index) => 0);
    choiceGroupValue = List.generate(questionNum, (index) => 0);

    for (int i = 0; i < questionNum; i++) {
      List<Color> tmp = [];
      for (int j = 0; j < choiceNum; j++) {
        tmp.add(Colors.black);
      }
      choiceTextColor.add(tmp);
    }

    score = questionNum;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("mark sheet"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(bottom: 10),
                child: Text(
                  markSheetName,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
                ),
              ),
              Container(
                child: Text(result, style: TextStyle(fontSize: 20)),
              ),
              Container(
                child: Column(
                  children: <Widget>[
                    for (int i = 0; i < questionNum; i++) ...{
                      Container(
                        child: Row(
                          children: <Widget>[
                            Text((i + 1).toString() + "問目"),
                            for (int j = 0; j < choiceNum; j++) ...{
                              Expanded(
                                child: RadioListTile(
                                  title: Text((j + 1).toString(),
                                      style: TextStyle(
                                          color: choiceTextColor[i][j])),
                                  value: j + 1,
                                  groupValue: choiceGroupValue[i],
                                  onChanged: (value) {
                                    setState(() {
                                      if (!isChecked) {
                                        choiceGroupValue[i] = j + 1;
                                        choiceList[i] = j + 1;
                                      }
                                    });
                                  },
                                ),
                              ),
                            }
                          ],
                        ),
                      ),
                    }
                  ],
                ),
              ),
              // ボタン
              Container(
                margin: EdgeInsets.all(5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 100,
                      height: 50,
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text("採点"),
                            onPressed: () async {
                              // 採点する
                              for (int i = 0; i < questionNum; i++) {
                                for (int j = 0; j < choiceNum; j++) {
                                  if (answerList[i] == (j + 1)) {
                                    setState(() {
                                      choiceTextColor[i][j] = Colors.blue;
                                    });
                                  } else if (choiceList[i] == (j + 1)) {
                                    setState(() {
                                      choiceTextColor[i][j] = Colors.red;
                                      score--;
                                    });
                                  }
                                }
                              }
                              isChecked = true;
                              canRetry = true;
                              setState(() {
                                result = score.toString() +
                                    " / " +
                                    questionNum.toString();
                              });

                              String usedDate = await markSheetUser
                                  .registerSolveResultToFirebase(
                                      markSheetName, score);

                              await markSheetUser
                                  .updateUsedNumOnFirebase(markSheetName);

                              await markSheetUser.registerChoiceListToFirebase(
                                  markSheetName,
                                  questionNum,
                                  usedDate,
                                  choiceList);
                            }),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      height: 50,
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text("再挑戦"),
                            onPressed: () async {
                              if (canRetry) {
                                setState(() {
                                  result = "未採点";
                                  isChecked = false;
                                  canRetry = false;
                                  score = questionNum;

                                  for (int i = 0; i < questionNum; i++) {
                                    choiceList[i] = 0;
                                    choiceGroupValue[i] = 0;
                                    for (int j = 0; j < choiceNum; j++) {
                                      choiceTextColor[i][j] = Colors.black;
                                    }
                                  }
                                });
                              }
                            }),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      height: 50,
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text("ホームへ"),
                            onPressed: () async {
                              Navigator.pushNamed(context, "/home");
                            }),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
