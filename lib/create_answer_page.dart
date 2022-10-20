import 'package:flutter/material.dart';
import 'package:mark_sheet/mark_sheet_user.dart';

class CreateAnswerPage extends StatefulWidget {
  const CreateAnswerPage({super.key});
  @override
  _CreateAnswerPageState createState() => _CreateAnswerPageState();
}

class _CreateAnswerPageState extends State<CreateAnswerPage> {
  MarkSheetUser markSheetUser = MarkSheetUser();

  late String markSheetName; // マークシートの名前
  late int questionNum; // 問題数
  late int choiceNum; // 選択肢数
  late String createDate; // 作成日
  late List<int> answerList; // answerList[i] : i問目の答え
  late List<int> answerGroupValue; // answerGroupValue[i] : i問目のgroupValue

  String alert = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    List<Object> argumentsFromCreatePage =
        ModalRoute.of(context)?.settings.arguments as List<Object>;
    markSheetName = argumentsFromCreatePage[0] as String;
    questionNum = argumentsFromCreatePage[1] as int;
    choiceNum = argumentsFromCreatePage[2] as int;
    createDate = argumentsFromCreatePage[3] as String;

    answerList = List.generate(questionNum, (index) => 0);
    answerGroupValue = List.generate(questionNum, (index) => 0);
  }

  @override
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
                                  title: Text((j + 1).toString()),
                                  value: j + 1,
                                  groupValue: answerGroupValue[i],
                                  onChanged: (value) {
                                    setState(() {
                                      answerGroupValue[i] = j + 1;
                                      answerList[i] = j + 1;
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
              // 作成完了ボタン
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
                      child: Text("作成完了"),
                      onPressed: () async {
                        try {
                          // マークシートを登録する
                          String createDate = markSheetUser.getDate();
                          await markSheetUser.registerMarkSheetToFirebase(
                              markSheetName,
                              questionNum,
                              choiceNum,
                              answerList,
                              createDate);

                          // ユーザのドキュメント数を更新する
                          await markSheetUser.updateMarkSheetNumOnFirebase();

                          Navigator.pushNamed(context, "/home");
                        } catch (e) {
                          setState(() {
                            alert = "作成に失敗しました。";
                          });
                        }
                      }),
                ),
              ),
              Container(
                child: Text(alert),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
