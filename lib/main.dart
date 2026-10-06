import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'controllers/telemetry_controller.dart';
import 'controllers/theme_controller.dart';
import 'screens/dashboard_screen.dart';
import 'services/monitoring_history_service.dart';
import 'services/update_service.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MonitoringHistoryService.instance.init();

  runApp(const AetherSenseApp());
}

class AetherSenseApp extends StatelessWidget {
  const AetherSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => TelemetryController()),
        ChangeNotifierProvider(create: (_) => UpdateService()),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, _) {
          final isDark = themeController.isDarkMode;

          // Adjust system navigation bar & status bar dynamically
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
              systemNavigationBarColor: isDark ? AetherConstants.bgDark : Colors.white,
              systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            ),
          );

          return MaterialApp(
            title: 'Tegal EcoSense',
            debugShowCheckedModeBanner: false,
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              scaffoldBackgroundColor: AetherConstants.bgLight,
              colorScheme: const ColorScheme.light(
                primary: AetherConstants.primaryBlue,
                surface: AetherConstants.surfaceLight,
                onSurface: AetherConstants.textPrimaryLight,
              ),
              textTheme: GoogleFonts.plusJakartaSansTextTheme(
                ThemeData.light().textTheme,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.white,
                elevation: 0,
                scrolledUnderElevation: 0,
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              scaffoldBackgroundColor: AetherConstants.bgDark,
              colorScheme: const ColorScheme.dark(
                primary: AetherConstants.cyanAccent,
                surface: AetherConstants.surfaceDark,
                onSurface: AetherConstants.textPrimaryDark,
              ),
              textTheme: GoogleFonts.plusJakartaSansTextTheme(
                ThemeData.dark().textTheme,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: AetherConstants.surfaceDark,
                elevation: 0,
                scrolledUnderElevation: 0,
              ),
            ),
            home: const DashboardScreen(),
          );
        },
      ),
    );
  }
}
