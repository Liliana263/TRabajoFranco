import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'src/services/notification_service.dart';
import 'src/views/splash_screen.dart';
import 'src/views/PantallaLoginview.dart';
import 'src/views/RegistrarUsuarioView.dart';
import 'src/views/MenuPrincipalview.dart';
import 'src/views/DashboardDoctorview.dart';
import 'src/views/MenuPrincipalConectadoView.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carga variables .env (si usas dotenv)
  await dotenv.load(fileName: ".env");

  // Inicializa notificaciones locales (Android/iOS)
  await NotificationService.instance.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clínica Estética',
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/registro': (_) => const RegistrarUsuario(),
        'perfildoctor': (_) => const PantallaDoctor(),
        '/home': (_) => MenuPrincipalSesion(),
        '/homeconectado': (_) => MenuPrincipalConectadoSesion(),
      },
    );
  }
}
