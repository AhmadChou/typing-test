import 'dart:math';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

Random random = new Random();
bool timerStart = false;
Stopwatch stopwatch = new Stopwatch();
RawKeyboardListener rawKeyboardListener;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Typist',
      home: TypingBuild(),
    );
  }
}

class TypingBuild extends StatefulWidget {
  @override
  _TypingBuildState createState() => _TypingBuildState();
}

class _TypingBuildState extends State<TypingBuild> {
  final myController = TextEditingController();

  @override
  void dispose() {
    myController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  final FocusNode focusNode = FocusNode();
  static List<String> wordList = generateWordList();
  static String modifiedList = modifedWordList(wordList);
  static String word = wordList[wordIndex];
  static int wordIndex = 0;
  Key key = UniqueKey();
  Color tfColor = Colors.white;
  int amountTyped = 0;
  double secondsTyped;
  String displaySeconds = '';
  int wpmAlpha = 0;
  double wpm = 0;
  int cIndex = 0;
  bool darkTheme = true;
  Color bodyColor = Colors.black87;
  Color appBarColor = Colors.black45;
  Color textColor = Colors.white;
  Color borderColor = Colors.white;
  Color textCompleteColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      backgroundColor: bodyColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Typist',
          style: GoogleFonts.comfortaa(
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        backgroundColor: appBarColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 100),
            Container(
              width: 700,
              padding: EdgeInsets.all(20.0),
              decoration: ShapeDecoration(
                color: Color.fromARGB(50, 0, 0, 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  side: BorderSide(
                    width: 4.0,
                    color: borderColor,
                  ),
                ),
              ),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: modifiedList,
                  style: GoogleFonts.dosis(
                      color: textCompleteColor, fontSize: 22.0),
                ),
              ),
            ),
            SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 50.0,
                ),
                Container(
                  height: 70.0,
                  width: 500.0,
                  padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
                  decoration: ShapeDecoration(
                    color: Color.fromARGB(50, 0, 0, 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: BorderSide(
                        width: 4.0,
                        color: tfColor,
                      ),
                    ),
                  ),
                  child: RawKeyboardListener(
                    onKey: handleKeyEvent,
                    focusNode: focusNode,
                    child: TextField(
                      controller: myController,
                      enableSuggestions: false,
                      autocorrect: false,
                      textAlign: TextAlign.center,
                      inputFormatters: [
                        new FilteringTextInputFormatter.deny(' '),
                      ],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                      ),
                      onChanged: (value) {
                        if (amountTyped < 20) {
                          setState(() {
                            timerStart = true;
                            stopwatch.start();
                          });
                        }

                        if (Text(myController.text).data.length <=
                            word.length) {
                          if (Text(myController.text)
                                  .data
                                  .characters
                                  .elementAt(cIndex) ==
                              word.characters.elementAt(cIndex)) {
                            setState(() {
                              tfColor = Colors.green;
                              cIndex += 1;
                            });
                          } else {
                            setState(() {
                              tfColor = Colors.red;
                            });
                          }
                        } else {
                          setState(() {
                            tfColor = Colors.red;
                          });
                        }
                      },
                    ),
                  ),
                ),
                Container(
                  height: 70.0,
                  width: 70.0,
                  decoration: ShapeDecoration(
                    color: Color.fromARGB(50, 0, 0, 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: BorderSide(
                        color: Colors.blue,
                        width: 4.0,
                      ),
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.redo),
                    color: Colors.white,
                    onPressed: () {
                      setState(() {
                        resetApp();
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20.0,
            ),
            RichText(
              text: TextSpan(
                text: 'Current Word: ',
                style: GoogleFonts.dosis(
                  color: Colors.white,
                  fontSize: 20.0,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: word,
                    style: GoogleFonts.dosis(
                      color: Colors.blue,
                      fontSize: 20.0,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Container(
              child: Text(
                'Successfully typed words: $amountTyped/20',
                style: GoogleFonts.dosis(
                  color: Colors.white,
                  fontSize: 20.0,
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Container(
              child: Text(
                'WPM: ' + rounding(wpm).toString(),
                style: GoogleFonts.dosis(
                  color: Color.fromARGB(wpmAlpha, 255, 255, 255),
                  fontSize: 20.0,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.lightbulb_outline),
        backgroundColor: Color.fromARGB(0, 0, 0, 0),
        elevation: 0.0,
        hoverElevation: 3.0,
        onPressed: () {
          changeTheme();
        },
      ),
    );
  }

  static double mToS(int mill) {
    double seconds = mill.toDouble();
    return seconds / 1000;
  }

  void handleKeyEvent(RawKeyEvent event) {
    setState(() {
      if (event.logicalKey == LogicalKeyboardKey.space) {
        if (event.runtimeType.toString() == 'RawKeyDownEvent') {
          if (Text(myController.text).data == word) {
            setState(() {
              if (wordIndex < 19) {
                wordIndex += 1;
              }
              word = wordList[wordIndex];
              amountTyped += 1;
              cIndex = 0;
              myController.clear();
            });
          }

          if (amountTyped >= 20) {
            setState(() {
              timerStart = false;
              stopwatch.stop();
              wpm = ((modifiedList.length - 19) / 5) *
                  (60.0 / mToS(stopwatch.elapsedMilliseconds));
              wpmAlpha = 255;
            });
          }
        }
      }

      if (event.logicalKey == LogicalKeyboardKey.backspace) {
        if (event.runtimeType.toString() == 'RawKeyDownEvent') {
          if (cIndex >= Text(myController.text).data.length &&
              Text(myController.text).data.length > 0) {
            setState(() {
              cIndex -= 1;
            });
          }
        }

        if (Text(myController.text).data == word) {
          setState(() {
            tfColor = Colors.green;
          });
        }
      }

      if (event.logicalKey == LogicalKeyboardKey.escape) {
        if (event.runtimeType.toString() == 'RawKeyDownEvent') {
          resetApp();
          if (wordList.length != 20) {
            print('NOT 20!!!!!');
          }
        }
      }
    });
  }

  void resetApp() {
    setState(() {
      new RandomWords();
      wordList = generateWordList();
      modifiedList = modifedWordList(wordList);
      wordIndex = 0;
      word = wordList[wordIndex];
      myController.clear();
      cIndex = 0;
      tfColor = Colors.white;
      stopwatch.stop();
      stopwatch.reset();
      amountTyped = 0;
    });
  }

  int rounding(double seconds) {
    return seconds.toInt();
  }

  static List<String> generateWordList() {
    List<String> words = new List<String>();
    for (int i = 0; i < 20; i++) {
      RandomWords randomWords = new RandomWords();
      String tempWord = randomWords.getRandomWord();
      if (!words.contains(tempWord)) {
        words.add(tempWord);
      } else {
        i -= 1;
      }
    }

    return words;
  }

  static String modifedWordList(List<String> text) {
    String result = text.toString();
    result = result.replaceAll('[', '');
    result = result.replaceAll(']', '');
    result = result.replaceAll(',', '');
    result = result.replaceAll(' ', '  ');
    return result;
  }

  void changeTheme() {
    if (darkTheme) {
      setState(() {
        bodyColor = Colors.grey[400];
        appBarColor = Colors.grey;
        textColor = Colors.black87;
        darkTheme = false;
      });
    } else {
      setState(() {
        bodyColor = Colors.black87;
        appBarColor = Colors.black45;
        textColor = Colors.white;
        darkTheme = true;
      });
    }
  }
}

class RandomWords {
  int randomNumber;
  String word;

  RandomWords() {
    randomNumber = random.nextInt(250);
    word = all[randomNumber];
  }

  String getRandomWord() {
    return word;
  }
}
