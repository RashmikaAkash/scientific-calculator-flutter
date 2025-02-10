import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Scientific Calculator',
      theme: ThemeData.dark(),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _expression = "";
  String _result = "0";
  List<String> _history = [];

  void _onButtonPressed(String value) {
    setState(() {
      if (value == "C") {
        _expression = "";
        _result = "0";
      } else if (value == "⌫") {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
      } else if (value == "=") {
        _calculateResult();
      } else {
        _expression += value;
      }
    });
  }

  void _calculateResult() {
    try {
      Parser p = Parser();
      Expression exp = p.parse(_expression
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('^', '^')
          .replaceAll('√', 'sqrt')
          .replaceAll('sin', 'sin')
          .replaceAll('cos', 'cos')
          .replaceAll('tan', 'tan')
          .replaceAll('ln', 'log')
          .replaceAll('log', 'log10')
          .replaceAll('!', 'factorial'));

      ContextModel cm = ContextModel();
      double evalResult = exp.evaluate(EvaluationType.REAL, cm);

      if (evalResult.isInfinite || evalResult.isNaN) {
        _result = "Error";
      } else {
        _result = evalResult.toString();
        _history.add("$_expression = $_result");
      }
    } catch (e) {
      _result = "Error";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scientific Calculator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Calculation History"),
                  content: SingleChildScrollView(
                    child: Column(
                      children: _history.map((entry) => Text(entry)).toList(),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Close"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              alignment: Alignment.bottomRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    _expression,
                    style: const TextStyle(fontSize: 32, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _result,
                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: _buildButtons(),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    List<String> buttons = [
      'C', '⌫', '(', ')', '÷',
      '7', '8', '9', '×', '√',
      '4', '5', '6', '-', 'sin',
      '1', '2', '3', '+', 'cos',
      '0', '.', '=', '^', 'tan',
      'log', 'ln', '!', 'π', 'e'
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        childAspectRatio: 1.2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: buttons.length,
      itemBuilder: (context, index) {
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.all(20),
            backgroundColor: _getButtonColor(buttons[index]),
          ),
          onPressed: () => _onButtonPressed(buttons[index]),
          child: Text(
            buttons[index],
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }

  Color _getButtonColor(String button) {
    if (button == "C" || button == "⌫") {
      return Colors.redAccent;
    } else if (button == "=" || button == "+" || button == "-" || button == "×" || button == "÷") {
      return Colors.orangeAccent;
    } else if (button == "sin" || button == "cos" || button == "tan" || button == "log" || button == "ln" || button == "√" || button == "^" || button == "!" || button == "π" || button == "e") {
      return Colors.purpleAccent;
    } else {
      return Colors.blueGrey;
    }
  }
}