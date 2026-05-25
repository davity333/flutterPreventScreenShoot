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
  child: Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'INICIAR SESIÓN',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 30),

        // CAMPO EMAIL
        TextField(
          decoration: InputDecoration(
            labelText: 'Correo electrónico',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // CAMPO PASSWORD
        TextField(
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Contraseña',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        const SizedBox(height: 30),

        // BOTÓN LOGIN
        ElevatedButton(
          onPressed: () {},
          child: const Text('Ingresar'),
        ),

        const SizedBox(height: 15),

        // TEXTO REGISTRO
        TextButton(
          onPressed: () {},
          child: const Text('Crear cuenta'),
        ),
      ],
    ),
  ),
),


    );
  }
}
