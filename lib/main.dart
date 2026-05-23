import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_prevent_screenshot/disablescreenshot.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // instancia de la clase FlutterPreventScreenshot
  final _flutterPrevenirCapturar = FlutterPreventScreenshot.instance;


  @override
  void initState() {
    super.initState();
    // metodo screenshotOff
    _flutterPrevenirCapturar.screenshotOff();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          //////////////UN HIJO ///////////////////
          children: [
            const Text('APLICACION PARA PREVENIR CAPTURAS DE PANTALLA'),
            const Text(
              'CAPTURAS DE PANTALLA PREVENIDAS',
              style: TextStyle(fontSize: 20),
            ),

          ],
          ////////////////////////////////
        ),
      ),

    );
  }
}
