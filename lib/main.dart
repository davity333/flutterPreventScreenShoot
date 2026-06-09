import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_prevent_screenshot/disablescreenshot.dart';
import 'package:safe_device/safe_device.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Recibir notificaciones en segundo plano
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (message.data['action'] == 'tilines') {
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'user_email');
    await storage.delete(key: 'user_password');
    await storage.delete(key: 'card_number');
    await storage.delete(key: 'user_pin');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Learnex Login',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _flutterPrevenirCapturar = FlutterPreventScreenshot.instance;
  bool _obscureText = true;
  bool _isLoading = true;
  bool _isMockLocationDetected = false;

  @override
  void initState() {
    super.initState();
    _flutterPrevenirCapturar.screenshotOff();
    _verificarSeguridadDispositivo();
  }

  Future<void> _verificarSeguridadDispositivo() async {
    try {
      PermissionStatus status = await Permission.location.request();
      if (status.isGranted) {
        bool finalDetection = false;
        try {
          Position? lastKnown = await Geolocator.getLastKnownPosition();
          if (lastKnown != null && lastKnown.isMocked) {
            finalDetection = true;
          }
        } catch (_) {}

        if (!finalDetection) {
          try {
            Position position = await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.lowest,
                timeLimit: Duration(seconds: 3),
              ),
            );
            finalDetection = position.isMocked;
          } catch (_) {}
        }

        try {
          bool isMockLocation = await SafeDevice.isMockLocation;
          finalDetection = finalDetection || isMockLocation;
        } catch (_) {}

        setState(() {
          _isMockLocationDetected = finalDetection;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isMockLocationDetected = true;
          _isLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF9C27B0)),
        ),
      );
    }

    if (_isMockLocationDetected) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.security_update_warning, color: Colors.redAccent, size: 90),
                const SizedBox(height: 30),
                const Text(
                  'Acceso Denegado',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF2D3142)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                const Text(
                  'Se ha detectado el uso de ubicaciones simuladas (Fake GPS).\n\nDesinstala estas herramientas o desactiva las "Ubicaciones de prueba" en las opciones de desarrollador.',
                  style: TextStyle(fontSize: 15, color: Color(0xFF9094A6), height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () => SystemNavigator.pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('SALIR DE LA APLICACIÓN',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    const primaryColor = Color(0xFF9C27B0);
    const textColor = Color(0xFF2D3142);
    const subtitleColor = Color(0xFF9094A6);
    const borderColor = Color(0xFFE0E0E0);
    const inputFillColor = Colors.white;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Image.asset('assets/logo.png', height: 90, fit: BoxFit.contain),
                ),
                const SizedBox(height: 30),
                const Center(
                  child: Text(
                    'Bienvenido a Learnex',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textColor),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Ingresa tus credenciales para continuar',
                    style: TextStyle(fontSize: 15, color: subtitleColor),
                  ),
                ),
                const SizedBox(height: 40),
                const Text('Email',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 8),
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'usuario@gmail.com',
                    hintStyle: const TextStyle(color: subtitleColor, fontSize: 14),
                    filled: true,
                    fillColor: inputFillColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: primaryColor, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Contraseña',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 8),
                TextField(
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    hintText: 'Mínimo 8 caracteres',
                    hintStyle: const TextStyle(color: subtitleColor, fontSize: 14),
                    filled: true,
                    fillColor: inputFillColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: primaryColor, width: 2),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: subtitleColor,
                      ),
                      onPressed: () => setState(() => _obscureText = !_obscureText),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      '¿Olvidaste tu contraseña?',
                      style: TextStyle(color: primaryColor, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const SecureDataPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('INICIAR SESIÓN',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('¿No tienes cuenta? ',
                        style: TextStyle(color: subtitleColor, fontSize: 14)),
                    GestureDetector(
                      onTap: () {},
                      child: const Text('Regístrate',
                          style: TextStyle(color: primaryColor, fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Vista de datos protegidos y borrado remoto
class SecureDataPage extends StatefulWidget {
  const SecureDataPage({super.key});

  @override
  State<SecureDataPage> createState() => _SecureDataPageState();
}

class _SecureDataPageState extends State<SecureDataPage> {
  Timer? _inactivityTimer;
  final _storage = const FlutterSecureStorage();
  final int _timeoutSeconds = 30;

  String? _email;
  String? _password;
  String? _cardNumber;
  String? _pin;
  String? _fcmToken;
  bool _wiped = false;
  bool _dataLoaded = false;

  @override
  void initState() {
    super.initState();
    _startInactivityTimer();
    _loadSecureData();
    _setupFCM();
  }

  void _startInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(Duration(seconds: _timeoutSeconds), _handleInactivity);
  }

  void _handleUserInteraction([_]) => _startInactivityTimer();

  Future<void> _handleInactivity() async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesión cerrada por inactividad')),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MyHomePage()),
      );
    }
  }

  Future<void> _loadSecureData() async {
    final email = await _storage.read(key: 'user_email');
    final password = await _storage.read(key: 'user_password');
    final cardNumber = await _storage.read(key: 'card_number');
    final pin = await _storage.read(key: 'user_pin');
    if (mounted) {
      setState(() {
        _email = email;
        _password = password;
        _cardNumber = cardNumber;
        _pin = pin;
        _dataLoaded = true;
      });
    }
  }

  Future<void> _autoFillData() async {
    await _storage.write(key: 'user_email', value: 'sujey@learnex.com');
    await _storage.write(key: 'user_password', value: 'Learnex@2025!');
    await _storage.write(key: 'card_number', value: '4111-1111-1111-1234');
    await _storage.write(key: 'user_pin', value: '7391');
    await _loadSecureData();
    if (mounted) setState(() => _wiped = false);
  }

  Future<void> _executeWipe() async {
    await _storage.delete(key: 'user_email');
    await _storage.delete(key: 'user_password');
    await _storage.delete(key: 'card_number');
    await _storage.delete(key: 'user_pin');
    if (mounted) {
      setState(() {
        _email = null;
        _password = null;
        _cardNumber = null;
        _pin = null;
        _wiped = true;
      });
    }
  }

  Future<void> _setupFCM() async {
    // Pedir permisos
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Obtener token para pruebas
    String? token = await FirebaseMessaging.instance.getToken();
    if (mounted) setState(() => _fcmToken = token);

    // Escuchar notificaciones (app abierta)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data['action'] == 'tilines') {
        _executeWipe();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Wipe remoto ejecutado. Datos eliminados.'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 5),
              ),
            );
        }
      }
    });

    // Tocar notificación en segundo plano
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data['action'] == 'tilines') {
        _executeWipe();
      }
    });
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF9C27B0);
    const textColor = Color(0xFF2D3142);
    const subtitleColor = Color(0xFF9094A6);
    const borderColor = Color(0xFFE0E0E0);

    return Listener(
      onPointerDown: _handleUserInteraction,
      onPointerMove: _handleUserInteraction,
      onPointerUp: _handleUserInteraction,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: textColor,
          elevation: 0,
          title: const Text(
            'Datos Sensibles',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: textColor),
              onPressed: () {
                _inactivityTimer?.cancel();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const MyHomePage()),
                );
              },
            ),
          ],
        ),
        body: !_dataLoaded
            ? const Center(child: CircularProgressIndicator(color: primaryColor))
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_wiped) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade300),
                        ),
                        child: const Text(
                          'Wipe remoto ejecutado. Datos eliminados.',
                          style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
                        ),
                      ),
                    ],

                    const Text(
                      'Almacenamiento seguro',
                      style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Informacion cifrada en el dispositivo',
                      style: TextStyle(color: subtitleColor, fontSize: 13),
                    ),
                    const SizedBox(height: 20),

                    _buildSecureField(Icons.email_outlined, 'Correo electronico', _email),
                    _buildSecureField(Icons.lock_outline, 'Contrasena', _password),
                    _buildSecureField(Icons.credit_card_outlined, 'Numero de tarjeta', _cardNumber),
                    _buildSecureField(Icons.pin_outlined, 'PIN', _pin),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _autoFillData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text(
                          'Llenar datos automaticamente',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),
                    const Divider(color: borderColor),
                    const SizedBox(height: 16),

                    const Text(
                      'Token FCM',
                      style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Usalo en Firebase Console para enviar el wipe remoto.',
                      style: TextStyle(color: subtitleColor, fontSize: 12),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        if (_fcmToken != null) {
                          Clipboard.setData(ClipboardData(text: _fcmToken!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Token copiado al portapapeles')),
                          );
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _fcmToken ?? 'Cargando token...',
                              style: const TextStyle(
                                  color: textColor,
                                  fontSize: 11,
                                  fontFamily: 'monospace'),
                            ),
                            if (_fcmToken != null) ...[
                              const SizedBox(height: 6),
                              const Text(
                                'Toca para copiar',
                                style: TextStyle(
                                    color: primaryColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Palabra clave del wipe remoto',
                            style: TextStyle(
                                color: subtitleColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'tilines',
                            style: TextStyle(
                                color: primaryColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace'),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Enviar en el campo "action" del payload FCM',
                            style: TextStyle(color: subtitleColor, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSecureField(IconData icon, String label, String? value) {
    const primaryColor = Color(0xFF9C27B0);
    const textColor = Color(0xFF2D3142);
    const subtitleColor = Color(0xFF9094A6);
    const borderColor = Color(0xFFE0E0E0);
    final hasValue = value != null && value.isNotEmpty;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: hasValue ? primaryColor : subtitleColor, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                      color: subtitleColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                Text(
                  hasValue ? value : 'Sin datos',
                  style: TextStyle(
                      color: hasValue ? textColor : subtitleColor,
                      fontSize: 14,
                      fontStyle: hasValue ? FontStyle.normal : FontStyle.italic),
                ),
              ],
            ),
          ),
          Icon(
            hasValue ? Icons.check_circle_outline : Icons.circle_outlined,
            color: hasValue ? Colors.green : borderColor,
            size: 18,
          ),
        ],
      ),
    );
  }
}
