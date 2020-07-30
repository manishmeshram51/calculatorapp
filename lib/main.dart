import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        brightness: Brightness.light,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SimpleCalculator(),
    );
  }
}

class SimpleCalculator extends StatefulWidget {
  @override
  _SimpleCalculatorState createState() => _SimpleCalculatorState();
}

class _SimpleCalculatorState extends State<SimpleCalculator> {
  String equation = "0";
  String result = "0";
  String expression = "0";
  double equationFontSize = 38.0;
  double resultFontSize = 48.0;

  bool _test = true;

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
        if ((!equation.isEmpty || equation != "0")) {
          result = (int.parse(equation) / 100).toString();
        }
      }
      // ** transition button condition
      else if (buttonText == "T") {
        _test = !_test;
      } else if (buttonText == "=") {
        equationFontSize = 38.0;
        resultFontSize = 48.0;

        expression = equation;
        expression = expression.replaceAll('×', '*');
        expression = expression.replaceAll('÷', '/');

        // *  for expo
        // * expression = "0^0";

        // expression = "2^-1";

        // cos 30 deg
        // expression = "cos(30 * 0.01745329251";

        expression = "123 % 100";
        try {
          Parser p = new Parser();
          Expression exp = p.parse(expression);

          ContextModel cm = ContextModel();

          result = '${exp.evaluate(EvaluationType.REAL, cm)}';
        } catch (e) {
          result = "Error";
        }
      } else {
        equationFontSize = 48.0;
        resultFontSize = 38.0;
        if (equation == "0") {
          equation = buttonText;
          // TODO some higher number exp when ui gets distorted.

        } else {
          equation = equation + buttonText;
        }
      }
    });
  }

  //button builder widget
  Widget buildButton(
      String buttonText, double buttonHeight, Color buttonColor) {
    return Container(
      height: MediaQuery.of(context).size.height * buttonHeight,
      color: buttonColor,
      child: FlatButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0.0),
          side: BorderSide(
              color: Colors.white, width: 1.0, style: BorderStyle.solid),
        ),
        // todo padding logic
        padding: EdgeInsets.all(12.0),
        onPressed: () => buttonPressed(buttonText),
        child: Text(
          buttonText,
          style: TextStyle(
              fontSize: 30.0,
              fontWeight: FontWeight.normal,
              color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_test == true) {
      // * return advanced calc options
      return Scaffold(
        appBar: AppBar(
          title: Text("Simple Calculator"),
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
                        buildButton("bb", 1 * 0.09, Colors.red),
                      ]),
                      TableRow(children: [
                        // ! row
                        buildButton("bb", 1 * 0.09, Colors.red),
                      ]),
                      TableRow(children: [
                        // ! row
                        buildButton("bb", 1 * 0.09, Colors.red),
                      ]),
                      TableRow(children: [
                        // ! row
                        buildButton("bb", 1 * 0.09, Colors.red),
                      ]),
                      TableRow(children: [
                        // ! row
                        buildButton("aa", 1 * 0.09, Colors.red),
                      ]),
                      TableRow(children: [
                        // * transition button
                        buildButton("T", 1 * 0.09, Colors.deepOrange),
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
                        buildButton("n", 1 * 0.09, Colors.black54),
                        buildButton("n", 1 * 0.09, Colors.black54),
                        buildButton("n", 1 * 0.09, Colors.black54),
                      ]),
                      TableRow(children: [
                        // ! row
                        buildButton("C", 1 * 0.09, Colors.redAccent),
                        buildButton("⌫", 1 * 0.09, Colors.deepPurple),
                        buildButton("%", 1 * 0.09, Colors.deepPurple),
                      ]),
                      TableRow(children: [
                        // ! row
                        buildButton("7", 1 * 0.09, Colors.black54),
                        buildButton("8", 1 * 0.09, Colors.black54),
                        buildButton("9", 1 * 0.09, Colors.black54),
                      ]),
                      TableRow(children: [
                        // ! row
                        buildButton("4", 1 * 0.09, Colors.black54),
                        buildButton("5", 1 * 0.09, Colors.black54),
                        buildButton("6", 1 * 0.09, Colors.black54),
                      ]),
                      TableRow(children: [
                        // ! row
                        buildButton("1", 1 * 0.09, Colors.black54),
                        buildButton("2", 1 * 0.09, Colors.black54),
                        buildButton("3", 1 * 0.09, Colors.black54),
                      ]),
                      TableRow(children: [
                        // ! row
                        buildButton("tb", 1 * 0.09, Colors.black54),
                        buildButton(".", 1 * 0.09, Colors.black54),
                        buildButton("0", 1 * 0.09, Colors.black54),
                      ]),
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.2,
                  child: Table(
                    children: [
                      TableRow(children: [
                        buildButton("n", 1 * 0.09, Colors.deepPurpleAccent),
                      ]),
                      TableRow(children: [
                        buildButton("+", 1 * 0.09, Colors.deepPurple),
                      ]),
                      TableRow(children: [
                        buildButton("-", 1 * 0.09, Colors.deepPurple),
                      ]),
                      TableRow(children: [
                        buildButton("×", 1 * 0.09, Colors.deepPurple),
                      ]),
                      TableRow(children: [
                        buildButton("÷", 1 * 0.09, Colors.deepPurple),
                      ]),
                      TableRow(children: [
                        buildButton("=", 1 * 0.09, Colors.redAccent),
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
                        buildButton("C", 0.1, Colors.redAccent),
                        buildButton("⌫", 0.1, Colors.deepPurple),
                        buildButton("%", 0.1, Colors.deepPurple),
                      ]),
                      TableRow(children: [
                        // ! row
                        buildButton("7", 0.1, Colors.black54),
                        buildButton("8", 0.1, Colors.black54),
                        buildButton("9", 0.1, Colors.black54),
                      ]),
                      TableRow(children: [
                        // ! row
                        buildButton("4", 0.1, Colors.black54),
                        buildButton("5", 0.1, Colors.black54),
                        buildButton("6", 0.1, Colors.black54),
                      ]),
                      TableRow(children: [
                        // ! row
                        buildButton("1", 0.1, Colors.black54),
                        buildButton("2", 0.1, Colors.black54),
                        buildButton("3", 0.1, Colors.black54),
                      ]),
                      TableRow(children: [
                        // ! row
                        buildButton("T", 0.1, Colors.deepOrange),
                        buildButton(".", 0.1, Colors.black54),
                        buildButton("0", 0.1, Colors.black54),
                      ]),
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.25,
                  child: Table(
                    children: [
                      TableRow(children: [
                        buildButton("+", 0.1, Colors.deepPurple),
                      ]),
                      TableRow(children: [
                        buildButton("-", 0.1, Colors.deepPurple),
                      ]),
                      TableRow(children: [
                        buildButton("×", 0.1, Colors.deepPurple),
                      ]),
                      TableRow(children: [
                        buildButton("÷", 0.1, Colors.deepPurple),
                      ]),
                      TableRow(children: [
                        buildButton("=", 0.1, Colors.redAccent),
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
