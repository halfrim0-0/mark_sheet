import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class MarkSheetUser {
  static final MarkSheetUser _user = MarkSheetUser._internal();

  late String _userId; // ユーザID
  late String _userName; // ユーザ名
  late int _markSheetNum; // ユーザが所持するマークシートの数
  late List<String> _markSheetList; // ユーザが所持するマークシートのリスト

  // クラス外で使うコンストラクタ
  factory MarkSheetUser() {
    return _user;
  }

  // クラス内で使う名前付きコンストラクタ
  MarkSheetUser._internal();

  // -----データベース操作に関連したメソッド-----

  Future<String> getUserIdFromFirebase() {
    final FirebaseAuth auth = FirebaseAuth.instance;

    String? userId;
    if (auth.currentUser != null) {
      userId = auth.currentUser?.uid;
    } else {
      userId = "not found";
    }

    _userId = userId!;
    return Future<String>.value(userId);
  }

  Future<String> getUserNameFromFirebase() async {
    String? userName;
    await FirebaseFirestore.instance
        .collection("users")
        .doc(_userId)
        .get()
        .then((DocumentSnapshot snapshot) {
      userName = snapshot.get("userName");
    });

    _userName = userName!;
    return Future<String>.value(userName);
  }

  Future<int> getMarkSheetNumFromFirebase() async {
    int? markSheetNum;
    await FirebaseFirestore.instance
        .collection("users")
        .doc(_userId)
        .get()
        .then((DocumentSnapshot snapshot) {
      markSheetNum = snapshot.get("markSheetNum");
    });

    _markSheetNum = markSheetNum!;
    return Future<int>.value(markSheetNum);
  }

  Future<List<String>> getMarkSheetListFromFirebase() async {
    List<String> markSheetList = [];

    await FirebaseFirestore.instance
        .collection("users")
        .doc(_userId)
        .collection("markSheets")
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach((doc) {
                markSheetList.add(doc.id);
              })
            });

    _markSheetList = markSheetList;
    return Future<List<String>>.value(markSheetList);
  }

  Future<int> getQuestionNumFromFirebase(String markSheetName) async {
    int? questionNum;
    await FirebaseFirestore.instance
        .collection("users")
        .doc(_userId)
        .collection("markSheets")
        .doc(markSheetName)
        .get()
        .then((DocumentSnapshot snapshot) {
      questionNum = snapshot.get("questionNum");
    });

    return Future<int>.value(questionNum!);
  }

  Future<int> getChoiceNumFromFirebase(String markSheetName) async {
    int? choiceNum;
    await FirebaseFirestore.instance
        .collection("users")
        .doc(_userId)
        .collection("markSheets")
        .doc(markSheetName)
        .get()
        .then((DocumentSnapshot snapshot) {
      choiceNum = snapshot.get("choiceNum");
    });

    return Future<int>.value(choiceNum!);
  }

  Future<List<int>> getAnswerListFromFirebase(
      String markSheetName, int questionNum) async {
    List<int> answerList = [];

    for (int i = 0; i < questionNum; i++) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(_userId)
          .collection("markSheets")
          .doc(markSheetName)
          .get()
          .then((DocumentSnapshot snapshot) {
        String key = "answer" + (i + 1).toString();
        int answer = snapshot.get(key);
        answerList.add(answer);
      });
    }

    return Future<List<int>>.value(answerList);
  }

  Future<int> getUsedNumFromFirebase(String markSheetName) async {
    int? usedNum;
    await FirebaseFirestore.instance
        .collection("users")
        .doc(_userId)
        .collection("markSheets")
        .doc(markSheetName)
        .get()
        .then((DocumentSnapshot snapshot) {
      usedNum = snapshot.get("usedNum");
    });

    return Future<int>.value(usedNum!);
  }

  Future<List<String>> getUsedDateListFromFirebase(
      String markSheetName, int usedNum) async {
    List<String> usedDateList = [];
    await FirebaseFirestore.instance
        .collection("users")
        .doc(_userId)
        .collection("markSheets")
        .doc(markSheetName)
        .collection("histories")
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach((doc) {
                String usedDate = doc.get("usedDate");
                usedDateList.add(usedDate);
              })
            });

    return Future<List<String>>.value(usedDateList);
  }

  Future<List<int>> getScoreListFromFirebase(
      String markSheetName, int usedNum) async {
    List<int> scoreList = [];
    await FirebaseFirestore.instance
        .collection("users")
        .doc(_userId)
        .collection("markSheets")
        .doc(markSheetName)
        .collection("histories")
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach((doc) {
                int score = doc.get("score");
                scoreList.add(score);
              })
            });

    return Future<List<int>>.value(scoreList);
  }

  Future<String> registerMarkSheetToFirebase(
      String markSheetName,
      int questionNum,
      int choiceNum,
      List<int> answerList,
      String createDate) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(_userId)
        .collection("markSheets")
        .doc(markSheetName)
        .set({
      "markSheetName": markSheetName,
      "createDate": createDate,
      "questionNum": questionNum,
      "choiceNum": choiceNum,
      "usedNum": 0,
    });

    for (int i = 0; i < questionNum; i++) {
      String key = await "answer" + (i + 1).toString();
      await FirebaseFirestore.instance
          .collection("users")
          .doc(_userId)
          .collection("markSheets")
          .doc(markSheetName)
          .update({key: answerList[i]});
    }

    return Future<String>.value(createDate);
  }

  Future<String> registerSolveResultToFirebase(
      String markSheetName, int score) async {
    String usedDate = getDate();
    await FirebaseFirestore.instance
        .collection("users")
        .doc(_userId)
        .collection("markSheets")
        .doc(markSheetName)
        .collection("histories")
        .doc(usedDate)
        .set({
      "usedDate": usedDate,
      "score": score,
    });

    return Future<String>.value(usedDate);
  }

  Future<List<int>> registerChoiceListToFirebase(String markSheetName,
      int questionNum, String usedDate, List<int> choiceList) async {
    for (int i = 0; i < questionNum; i++) {
      String key = "choice" + (i + 1).toString();
      await FirebaseFirestore.instance
          .collection("users")
          .doc(_userId)
          .collection("markSheets")
          .doc(markSheetName)
          .collection("histories")
          .doc(usedDate)
          .update({key: choiceList[i]});
    }

    return Future<List<int>>.value(choiceList);
  }

  Future<int> updateMarkSheetNumOnFirebase() async {
    _markSheetNum++;
    await FirebaseFirestore.instance
        .collection("users")
        .doc(_userId)
        .update({"markSheetNum": _markSheetNum});

    _markSheetList = await getMarkSheetListFromFirebase();
    return Future<int>.value(_markSheetNum);
  }

  Future<int> updateUsedNumOnFirebase(String markSheetName) async {
    int usedNum = 0;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(_userId)
        .collection("markSheets")
        .doc(markSheetName)
        .get()
        .then((DocumentSnapshot snapshot) {
      usedNum = snapshot.get("usedNum");
    });

    usedNum++;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(_userId)
        .collection("markSheets")
        .doc(markSheetName)
        .update({"usedNum": usedNum});

    return Future<int>.value(usedNum);
  }

  // -----ゲッター-----
  String getUserId() {
    return _userId;
  }

  String getUserName() {
    return _userName;
  }

  int getMarkSheetNum() {
    return _markSheetNum;
  }

  List<String> getMarkSheetList() {
    return _markSheetList;
  }

  String getDate() {
    DateTime now = DateTime.now();
    DateFormat dateFormat = DateFormat("yyyy_MM_dd_HH_mm_ss");
    String date = dateFormat.format(now);

    return date;
  }
}
