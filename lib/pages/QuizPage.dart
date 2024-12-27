import 'dart:async';

import 'package:civils_gpt/models/QuesModel.dart';
import 'package:flutter/material.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});
  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  // List<bool> tile_state = [false, false, false, false];
  // int? usr_answr;
  var butn_color = Color(0xFFBABABA);
  int ques_nmbr = 0;
  Timer? countdownTimer;
  Duration myDuration = Duration(minutes: 2);
  QuesModel? list_main;
  int? usr_answr;

  void startTimer() {
    countdownTimer?.cancel();
    countdownTimer = Timer(const Duration(seconds: 1), () => setCountDown());
  }

  void setCountDown() {
    final reduceSecondsBy = 1;
    setState(() {
      var seconds = myDuration.inSeconds - reduceSecondsBy;
      if (seconds < 0) {
        countdownTimer!.cancel();
        //handle Result for quiz
      } else {
        myDuration = Duration(seconds: seconds);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    startTimer();
    String strDigits(int n) => n.toString().padLeft(2, '0');
    var hours = strDigits(myDuration.inHours.remainder(60));
    var minutes = strDigits(myDuration.inMinutes.remainder(60));
    var seconds = strDigits(myDuration.inSeconds.remainder(60));

    return list_main == null
        ? Scaffold(
            body: Container(
              color: Color(0xFFFAFAFF),
              child: Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 50,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(20, 20, 30, 20),
                        child: Card(
                          child: Row(
                            children: [
                              Icon(
                                Icons.star_border_rounded,
                                size: 30,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: Text(
                          '$hours:$minutes:$seconds',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 40),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(Icons.cancel)),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: LinearProgressIndicator(
                      minHeight: 20,
                      backgroundColor: Color(0xFFF4F3F6),
                      color: Color(0xFF376996),
                      value: ((ques_nmbr + 1) / list_main!.ques_lst!.length),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        "${ques_nmbr + 1}/${list_main!.ques_lst!.length}",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Align(
                          child: Container(
                            margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                            child: const Text(
                              "Format: +4 for correct answer,-1 for incorrect",
                              softWrap: true,
                              maxLines: 3,
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  Card(
                    color: Colors.white,
                    margin: EdgeInsets.fromLTRB(15, 20, 15, 20),
                    elevation: 2,
                    child: Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            child: Text(
                              list_main!.ques_lst![ques_nmbr].question,
                              style: TextStyle(
                                  fontSize: 22,
                                  color: Color(0xFF191D63),
                                  fontWeight: FontWeight.bold),
                            ),
                            margin: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 20),
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          Column(
                            children: [
                              for (int i = 0;
                                  i <
                                      list_main!
                                          .ques_lst![ques_nmbr].choices.length;
                                  i++)
                                Padding(
                                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                  child: FloatingActionButton.extended(
                                    onPressed: () {
                                      setState(() {
                                        usr_answr = i;
                                        butn_color = const Color(0xFF1F487E);
                                      });
                                    },
                                    backgroundColor: usr_answr == i
                                        ? butn_color
                                        : const Color(0xFFFAFAFF),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    label: Text(
                                      list_main!
                                          .ques_lst![ques_nmbr].choices[i],
                                      style: TextStyle(
                                        color: usr_answr == i
                                            ? Colors.white
                                            : Color(0xFF191D63),
                                        fontSize: 18,
                                      ),
                                    ),
                                    icon: CircleAvatar(
                                      backgroundColor: Color(0xFFEDE8E3),
                                      child: usr_answr == i
                                          ? Icon(
                                              Icons.check,
                                              color: Color(0xFF191D63),
                                            )
                                          : Text(
                                              '${i + 1}',
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
                            child: FloatingActionButton.extended(
                              onPressed: () {
                                if (usr_answr != null) {
                                  //calculate score and proceed to next question
                                }
                              },
                              label:
                                  ques_nmbr == list_main!.ques_lst!.length - 1
                                      ? Text("FINISH")
                                      : Text("CONTINUE"),
                              backgroundColor: usr_answr == null
                                  ? Color(0xFFBABABA)
                                  : Color(0xFF1F487E),
                              shape: BeveledRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4))),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        : CircularProgressIndicator();
  }
}
