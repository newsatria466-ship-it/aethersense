import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'controllers/telemetry_controller.dart';
import 'screens/dashboard_screen.dart';
import 'services/update_service.dart';
import 'utils/constants.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style untuk status bar yang bersih dan modern
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0A0F1D),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const AetherSenseApp());
}

class AetherSenseApp extends StatelessWidget {
  const AetherSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TelemetryController()),
        ChangeNotifierProvider(create: (_) => UpdateService()),
      ],
      child: MaterialApp(
        title: 'Tegal EcoSense',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AetherConstants.background,
          colorScheme: const ColorScheme.dark(
            primary: AetherConstants.cyanAccent,
            surface: AetherConstants.background,
            onSurface: Colors.white,
          ),
          textTheme: GoogleFonts.plusJakartaSansTextTheme(
            ThemeData.dark().textTheme,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
        ),
        home: const DashboardScreen(),
      ),
    );
  }
}
