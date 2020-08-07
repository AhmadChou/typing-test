import 'dart:math';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

bool timerStart = false;
Stopwatch stopwatch = new Stopwatch();
Random random = new Random();

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
  final Key key = UniqueKey();
  Color tfColor = Colors.white;
  int amountTyped = 0;
  double secondsTyped;
  String displaySeconds = '';
  int wpmAlpha = 0;
  double wpm = 0;
  int cIndex = 0;

  //Theme related
  bool darkTheme = true;
  bool lightTheme = false;
  bool oceanTheme = false;
  Color bodyColor = Colors.grey[900];
  Color appBarColor = Colors.grey[800];
  Color textColor = Colors.white;
  Color borderColor = Colors.white;
  Color iconColor = Colors.white;
  int wpmColorR = 255;
  int wpmColorG = 255;
  int wpmColorB = 255;
  int containerAlpha = 50;

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
                color: Color.fromARGB(containerAlpha, 0, 0, 0),
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
                  style: GoogleFonts.dosis(color: textColor, fontSize: 22.0),
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
                    color: Color.fromARGB(containerAlpha, 0, 0, 0),
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
                        color: textColor,
                        fontSize: 18.0,
                      ),
                      onChanged: (value) {
                        //starting timer only after text field has been edited
                        if (amountTyped < 20) {
                          setState(() {
                            timerStart = true;
                            stopwatch.start();
                          });
                        }

                        //keeping track of text field input using cIndex to determine correctly typed characters
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
                          //setting text field border to red if user input exceeds current word length
                          setState(() {
                            tfColor = Colors.red;
                          });
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(
                  width: 10.0,
                ),
                Container(
                  height: 70.0,
                  width: 70.0,
                  decoration: ShapeDecoration(
                    color: Color.fromARGB(containerAlpha, 0, 0, 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: BorderSide(
                        color: Colors.blue[300],
                        width: 4.0,
                      ),
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.redo),
                    color: iconColor,
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
                  color: textColor,
                  fontSize: 20.0,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: word,
                    style: GoogleFonts.dosis(
                      color: Colors.blue[300],
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
                  color: textColor,
                  fontSize: 20.0,
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Container(
              child: Text(
                'WPM: ' + rounding(wpm).toString(),
                style: GoogleFonts.dosis(
                  color:
                      Color.fromARGB(wpmAlpha, wpmColorR, wpmColorG, wpmColorB),
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
        foregroundColor: iconColor,
        elevation: 0.0,
        hoverElevation: 1.0,
        onPressed: () {
          changeTheme();
        },
      ),
    );
  }

  //function for converting milliseconds to seconds (makes the wpm calculations simpler)
  static double mToS(int mill) {
    double seconds = mill.toDouble();
    return seconds / 1000;
  }

  void handleKeyEvent(RawKeyEvent event) {
    setState(() {
      if (event.logicalKey == LogicalKeyboardKey.space) {
        if (event.runtimeType.toString() == 'RawKeyDownEvent') {
          if (Text(myController.text).data == word) {
            //switching to next word once space is pressed only if the correct word is typed in the text field
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

          //stopping timer once 20 word have been successfully typed
          if (amountTyped >= 20) {
            setState(() {
              timerStart = false;
              stopwatch.stop();
              //calculating and dispalying WPM, calculations are: (total characters/5) * (60/seconds), -19 is to account for an extra space added after each word in the word bank
              wpm = ((modifiedList.length - 19) / 5) *
                  (60.0 / mToS(stopwatch.elapsedMilliseconds));
              wpmAlpha = 255;
            });
          }
        }
      }

      //accounting for user backspacing a correctly typed character to keep the live feedback accurate
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

      //alowing user to reset wordbank, timer and, textfield by pressing the escape key
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        if (event.runtimeType.toString() == 'RawKeyDownEvent') {
          resetApp();
        }
      }
    });
  }

  //function for resetting app, called when pressing the escape key or redo button
  void resetApp() {
    setState(() {
      new RandomWords();
      wordList = generateWordList();
      modifiedList = modifedWordList(wordList);
      wordIndex = 0;
      word = wordList[wordIndex];
      myController.clear();
      cIndex = 0;
      stopwatch.stop();
      stopwatch.reset();
      amountTyped = 0;

      //resetting base text field border color in case it is green or red once user resets
      if (lightTheme) {
        tfColor = Colors.grey[600];
      } else {
        tfColor = Colors.white;
      }
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
      //ensuring the same word does not show up twice in word list
      if (!words.contains(tempWord)) {
        words.add(tempWord);
      } else {
        i -= 1;
      }
    }
    return words;
  }

  //removing unnessecary .toString() stuff and adding an extra space for visual clarity
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
        bodyColor = Colors.blueGrey[900];
        appBarColor = Colors.blueGrey[800];
        textColor = Colors.white;
        borderColor = Colors.white;
        wpmColorR = 255;
        wpmColorG = 255;
        wpmColorB = 255;
        containerAlpha = 50;
        iconColor = Colors.white;
        if (tfColor == Colors.grey[600]) {
          tfColor = Colors.white;
        }
        darkTheme = false;
        oceanTheme = true;
      });
    } else if (lightTheme) {
      setState(() {
        bodyColor = Colors.grey[900];
        appBarColor = Colors.grey[800];
        textColor = Colors.white;
        borderColor = Colors.white;
        wpmColorR = 255;
        wpmColorG = 255;
        wpmColorB = 255;
        containerAlpha = 50;
        iconColor = Colors.white;
        if (tfColor == Colors.grey[600]) {
          tfColor = Colors.white;
        }
        lightTheme = false;
        darkTheme = true;
      });
    } else if (oceanTheme) {
      setState(() {
        bodyColor = Colors.white;
        appBarColor = Colors.grey[300];
        textColor = Colors.black;
        borderColor = Colors.grey[600];
        wpmColorR = 0;
        wpmColorG = 0;
        wpmColorB = 0;
        containerAlpha = 25;
        iconColor = Colors.grey[700];
        if (tfColor == Colors.white) {
          tfColor = Colors.grey[600];
        }
        oceanTheme = false;
        lightTheme = true;
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
