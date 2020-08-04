import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new DynamicTheme(
        defaultBrightness: Brightness.light,
        data: (brightness) => new ThemeData(
              primarySwatch: Colors.deepOrange,
              brightness: brightness,
            ),
        themedWidgetBuilder: (context, theme) {
          return new MaterialApp(
            title: 'Calculator App',
            theme: theme,
            debugShowCheckedModeBanner: false,
            home: SimpleCalculator(),
          );
        });
  }
}

class SimpleCalculator extends StatefulWidget {
  @override
  _SimpleCalculatorState createState() => _SimpleCalculatorState();
}

class _SimpleCalculatorState extends State<SimpleCalculator> {
  Future<SharedPreferences> _prefs =
      SharedPreferences.getInstance(); // shared preferences

  // ! danger
  Future<bool> _darkMode;
  bool dMode = false;
  String equation = "0";
  String result = "0";
  String expression = "0";
  double equationFontSize = 38.0;
  double resultFontSize = 48.0;

  String angleUnit = "deg"; //can be rad or deg

  bool _transitionSA = false; // simple to advaced functions
  // bool _darkMode = false;
  // * to check if string contains numeric or not
  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

// * to check if string is operator or not
  bool isOperator(String s) {
    if ((s == "+") || (s == "-") || (s == "×") || (s == "÷") || (s == "^")) {
      return true;
    }
    return false;
  }

// ! error
  void setBoolToSP(bool boolValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkMode', boolValue);
    // print("inside set bool " + boolValue.toString());
  }

  // ! erroe
  getBoolValuesSP() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // print("inside getboolvaluesf ${prefs.getBool('darkMode')}");

      return prefs.getBool('darkMode');
    } catch (e) {
      print("getbool" + e);
    }
  }

  // ? init state for loading the shared preferences data initially
  @override
  void initState() {
    // ! check
    super.initState();
    _darkMode = _prefs.then((SharedPreferences prefs) {
      dMode = prefs.getBool('darkMode') ?? false;
      print("inside init>$dMode");
      // setBoolToSP(test);
      return (dMode);
    });
    print("inside init ${_darkMode}");
  }

  // * button pressed logic
  buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == "C") {
        equation = "0";
        result = "0";

        equationFontSize = 38.0;
        resultFontSize = 48.0;
      } else if (buttonText == "⌫") {
        equationFontSize = 48.0;
        resultFontSize = 38.0;
        equation = equation.substring(0, equation.length - 1);
        if (equation == "") {
          equation = "0";
        }
      } else if (buttonText == '%') {
        if ((equation.isNotEmpty || equation != "0")) {
          result = (double.parse(equation) / 100).toString();

          // ? testingr
          equation = result;
        }
      }
      // ** transition button condition
      else if (buttonText == "⌘") {
        setState(() {
          _transitionSA = !_transitionSA;
        });
      } else if (buttonText == "deg" || buttonText == "rad") {
        if (angleUnit == "rad") {
          angleUnit = "deg";
        } else {
          angleUnit = "rad";
        }
      } else if (buttonText == "=") {
        equationFontSize = 38.0;
        resultFontSize = 48.0;

        expression = equation;
        expression = expression.replaceAll('×', '*');
        expression = expression.replaceAll('÷', '/');
        expression = expression.replaceAll('e', '2.71828183 * 1');

        if ((angleUnit == "deg" && expression.contains('sin')) ||
            (angleUnit == "deg" && expression.contains('cos'))) {
          expression = expression.replaceAll(')', ' * 0.01745329251 )');
        }

        // for debug the expression
        print(expression);
        try {
          Parser p = new Parser();
          Expression exp = p.parse(expression);

          ContextModel cm = ContextModel();

          result = '${exp.evaluate(EvaluationType.REAL, cm)}';
          result = (double.parse(result)).toStringAsFixed(4);

          equation = result;
        } catch (e) {
          result = "Error";
        }
      } else {
        equationFontSize = 48.0;
        resultFontSize = 38.0;
        if (equation == "0") {
          equation = buttonText;
        } else {
          if (buttonText == "xʸ") {
            equation = equation + buttonText.replaceAll("xʸ", "^");
          } else if (buttonText == "√x") {
            equation = equation + buttonText.replaceAll("√x", "^(1/2)");
          } else if (buttonText == "1/x") {
            equation = buttonText.replaceAll("1/x", "1/${equation}");
          } else {
            // ! working here
            if ((equation.length >= 2) &&
                (equation[equation.length - 1] == buttonText) &&
                (!isNumeric(equation[equation.length - 1]))) {
              equation = equation;

              print(equation);
            } else {
              equation = equation + buttonText;
            }
          }
        }
      }
    });
  }

  // * button builder widget
  Widget buildButton(String buttonText, double buttonHeight, Color buttonColor,
      Color textColor, bool dMode) {
    return Container(
      height: MediaQuery.of(context).size.height * buttonHeight,
      child: FlatButton(
        // ! here
        color: dMode
            ? (buttonColor != Colors.white ? buttonColor : Colors.black54)
            : buttonColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0.0),
          side: BorderSide(
              // !here
              color: dMode ? Colors.black26 : Colors.white,
              width: 1.0,
              style: BorderStyle.solid),
        ),
        // todo padding logic
        padding: EdgeInsets.all(12.0),
        onPressed: () => buttonPressed(buttonText),
        child: Text(
          buttonText,
          style: TextStyle(
              fontSize: 26.0,
              fontWeight: FontWeight.w400,
              // !here
              color: dMode
                  ? (textColor == Colors.black ? Colors.white : textColor)
                  : textColor),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_transitionSA == true) {
      // * return advanced calc options
      return Scaffold(
        appBar: AppBar(
          title: Text("Advanced Calculator"),
          leading: GestureDetector(
            onTap: () {/* Write listener code here */},
            child: Icon(
              Icons.menu, // add custom icons also
            ),
          ),
          actions: <Widget>[
            FutureBuilder(
              future: getBoolValuesSP(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  dMode = snapshot.data;
                  // print("inside fb $dMode");
                  return Padding(
                      padding: EdgeInsets.only(right: 20.0),
                      child: Switch(
                          activeColor: Colors.orange,
                          inactiveThumbColor: Colors.black,
                          value: dMode, // !
                          onChanged: (value) {
                            setState(() {
                              DynamicTheme.of(context).setBrightness(
                                  Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Brightness.light
                                      : Brightness.dark);
                              // !
                              dMode = !dMode;
                              setBoolToSP(dMode);
                              print("inside switch $dMode");
                            });
                          }));
                }
                return CircularProgressIndicator();
              },
            ),
          ],
        ),
        body: new Column(
          children: <Widget>[
            new Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
              child: FittedBox(
                child: Text(
                  equation,
                  style: TextStyle(fontSize: equationFontSize),
                ),
              ),
            ),
            new Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
              child: Text(
                result,
                style: TextStyle(fontSize: resultFontSize),
              ),
            ),
            Expanded(child: Divider()),
            new Row(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.2,
                  child: Table(
                    children: [
                      TableRow(children: [
                        // ! row
                        buildButton(angleUnit, 1 * 0.095, Colors.white,
                            Colors.red, dMode),
                      ]),
                      TableRow(children: [
                        // ! row
                        buildButton(
                            "xʸ", 1 * 0.095, Colors.white, Colors.red, dMode),
                      ]),
                      TableRow(children: [
                        // ! row
                        buildButton(
                            "√x", 1 * 0.095, Colors.white, Colors.red, dMode),
                      ]),
                      TableRow(children: [
                        // ! row
                        buildButton(
                            "ln", 1 * 0.095, Colors.white, Colors.red, dMode),
                      ]),
                      TableRow(children: [
                        // ! row
                        buildButton(
                            "1/x", 1 * 0.095, Colors.white, Colors.red, dMode),
                      ]),
                      TableRow(children: [
                        // * transition button
                        buildButton("⌘", 1 * 0.095, Colors.deepOrange,
                            Colors.white, dMode),
                      ]),
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.60,
                  child: Table(
                    children: [
                      TableRow(children: [
                        // ! row
                        buildButton(
                            "sin", 1 * 0.095, Colors.white, Colors.blue, dMode),
                        buildButton(
                            "cos", 1 * 0.095, Colors.white, Colors.blue, dMode),
                        buildButton(
                            "(", 1 * 0.095, Colors.white, Colors.blue, dMode),
                      ]),
                      TableRow(children: [
                        // ! row
                        buildButton("C", 1 * 0.095, Colors.deepOrange,
                            Colors.white, dMode),
                        buildButton(
                            "⌫", 1 * 0.095, Colors.white, Colors.blue, dMode),
                        buildButton(
                            "%", 1 * 0.095, Colors.white, Colors.blue, dMode),
                      ]),
                      TableRow(children: [
                        // ! row
                        buildButton(
                            "7", 1 * 0.095, Colors.white, Colors.black, dMode),
                        buildButton(
                            "8", 1 * 0.095, Colors.white, Colors.black, dMode),
                        buildButton(
                            "9", 1 * 0.095, Colors.white, Colors.black, dMode),
                      ]),
                      TableRow(children: [
                        // ! row
                        buildButton(
                            "4", 1 * 0.095, Colors.white, Colors.black, dMode),
                        buildButton(
                            "5", 1 * 0.095, Colors.white, Colors.black, dMode),
                        buildButton(
                            "6", 1 * 0.095, Colors.white, Colors.black, dMode),
                      ]),
                      TableRow(children: [
                        // ! row
                        buildButton(
                            "1", 1 * 0.095, Colors.white, Colors.black, dMode),
                        buildButton(
                            "2", 1 * 0.095, Colors.white, Colors.black, dMode),
                        buildButton(
                            "3", 1 * 0.095, Colors.white, Colors.black, dMode),
                      ]),
                      TableRow(children: [
                        // ! row
                        buildButton(
                            "e", 1 * 0.095, Colors.white, Colors.red, dMode),

                        buildButton(
                            ".", 1 * 0.095, Colors.white, Colors.black, dMode),
                        buildButton(
                            "0", 1 * 0.095, Colors.white, Colors.black, dMode),
                      ]),
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.2,
                  child: Table(
                    children: [
                      TableRow(children: [
                        buildButton(
                            ")", 1 * 0.095, Colors.white, Colors.blue, dMode),
                      ]),
                      TableRow(children: [
                        buildButton(
                            "+", 1 * 0.095, Colors.white, Colors.blue, dMode),
                      ]),
                      TableRow(children: [
                        buildButton(
                            "-", 1 * 0.095, Colors.white, Colors.blue, dMode),
                      ]),
                      TableRow(children: [
                        buildButton(
                            "×", 1 * 0.095, Colors.white, Colors.blue, dMode),
                      ]),
                      TableRow(children: [
                        buildButton(
                            "÷", 1 * 0.095, Colors.white, Colors.blue, dMode),
                      ]),
                      TableRow(children: [
                        buildButton("=", 1 * 0.095, Colors.deepOrange,
                            Colors.white, dMode),
                      ]),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      );
    }
    // ** important else return normal calc
    else {
      return Scaffold(
        appBar: AppBar(
          title: Text("Simple Calculator"),
          leading: GestureDetector(
            onTap: () {/* Write listener code here */},
            child: Icon(
              Icons.menu, // add custom icons also
            ),
          ),
          actions: <Widget>[
            FutureBuilder(
              future: getBoolValuesSP(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  dMode = snapshot.data;
                  // print("inside fb $dMode");
                  return Padding(
                      padding: EdgeInsets.only(right: 20.0),
                      child: Switch(
                          activeColor: Colors.deepOrange,
                          inactiveThumbColor: Colors.black,
                          value: dMode, //!
                          onChanged: (value) {
                            // * here is dark mode logic using package
                            setState(() {
                              DynamicTheme.of(context).setBrightness(
                                  Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Brightness.light
                                      : Brightness.dark);
                              // !
                              dMode = !dMode;
                              setBoolToSP(dMode);
                              // print("inside switch $dMode");
                            });
                          }));
                }
                return CircularProgressIndicator();
              },
            ),
          ],
        ),
        body: new Column(
          children: <Widget>[
            new Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
              child: FittedBox(
                child: Text(
                  equation,
                  style: TextStyle(fontSize: equationFontSize),
                ),
              ),
            ),
            new Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
              child: Text(
                result,
                style: TextStyle(fontSize: resultFontSize),
              ),
            ),
            Expanded(child: Divider()),
            new Row(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  child: Table(
                    children: [
                      TableRow(children: [
                        // ! row
                        buildButton(
                            "C", 0.1, Colors.deepOrange, Colors.white, dMode),
                        buildButton("⌫", 0.1, Colors.white, Colors.blue, dMode),
                        buildButton("%", 0.1, Colors.white, Colors.blue, dMode),
                      ]),
                      TableRow(children: [
                        // ! row
                        buildButton(
                            "7", 0.1, Colors.white, Colors.black, dMode),
                        buildButton(
                            "8", 0.1, Colors.white, Colors.black, dMode),
                        buildButton(
                            "9", 0.1, Colors.white, Colors.black, dMode),
                      ]),
                      TableRow(children: [
                        // ! row
                        buildButton(
                            "4", 0.1, Colors.white, Colors.black, dMode),
                        buildButton(
                            "5", 0.1, Colors.white, Colors.black, dMode),
                        buildButton(
                            "6", 0.1, Colors.white, Colors.black, dMode),
                      ]),
                      TableRow(children: [
                        // ! row
                        buildButton(
                            "1", 0.1, Colors.white, Colors.black, dMode),
                        buildButton(
                            "2", 0.1, Colors.white, Colors.black, dMode),
                        buildButton(
                            "3", 0.1, Colors.white, Colors.black, dMode),
                      ]),
                      TableRow(children: [
                        // ! row
                        buildButton(
                            "⌘", 0.1, Colors.deepOrange, Colors.white, dMode),
                        buildButton(
                            ".", 0.1, Colors.white, Colors.black, dMode),
                        buildButton(
                            "0", 0.1, Colors.white, Colors.black, dMode),
                      ]),
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.25,
                  child: Table(
                    children: [
                      TableRow(children: [
                        buildButton("+", 0.1, Colors.white, Colors.blue, dMode),
                      ]),
                      TableRow(children: [
                        buildButton("-", 0.1, Colors.white, Colors.blue, dMode),
                      ]),
                      TableRow(children: [
                        buildButton("×", 0.1, Colors.white, Colors.blue, dMode),
                      ]),
                      TableRow(children: [
                        buildButton("÷", 0.1, Colors.white, Colors.blue, dMode),
                      ]),
                      TableRow(children: [
                        buildButton(
                            "=", 0.1, Colors.deepOrange, Colors.white, dMode),
                      ])
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      );
    }
  }
}

// ⁰ ¹ ² ³ ⁴ ⁵ ⁶ ⁷ ⁸ ⁹ ⁺ ⁻ ⁼ 	√
