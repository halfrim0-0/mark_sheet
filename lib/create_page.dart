// 変更完了
import 'package:flutter/material.dart';
import 'package:mark_sheet/mark_sheet_user.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});
  @override
  _CreatePageState createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  MarkSheetUser markSheetUser = MarkSheetUser();
  String markSheetName = "";
  String questionNum = "0";
  String choiceNum = "0";

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
            children: <Widget>[
              // タイトル
              Container(
                child: TextFormField(
                  decoration: InputDecoration(labelText: "タイトル"),
                  onChanged: (String value) {
                    setState(() {
                      markSheetName = value;
                    });
                  },
                ),
              ),
              // 問題数
              Container(
                child: Column(
                  children: <Widget>[
                    TextFormField(
                        decoration: InputDecoration(labelText: "問題数"),
                        onChanged: (String value) {
                          setState(() {
                            if (value.isEmpty) {
                              value = "0";
                            }
                            questionNum = value;
                          });
                        }),
                    TextFormField(
                        decoration: InputDecoration(labelText: "選択肢数"),
                        onChanged: (String value) {
                          setState(() {
                            if (value.isEmpty) {
                              value = "0";
                            }
                            choiceNum = value;
                          });
                        }),
                  ],
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
                      child: Text("模範解答を作成"),
                      onPressed: () {
                        String createDate = markSheetUser.getDate();

                        List<Object> arguments = [
                          markSheetName,
                          int.parse(questionNum),
                          int.parse(choiceNum),
                          createDate,
                        ];

                        Navigator.pushNamed(context, "/home/create/answer",
                            arguments: arguments);
                      }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
