import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'controllers/telemetry_controller.dart';
import 'controllers/theme_controller.dart';
import 'screens/splash_screen.dart';
import 'services/monitoring_history_service.dart';
import 'services/update_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MonitoringHistoryService.instance.init();

  runApp(const SmartCityTegalApp());
}

class SmartCityTegalApp extends StatelessWidget {
  const SmartCityTegalApp({super.key});

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
              systemNavigationBarColor: isDark ? AppColors.backgroundDark : Colors.white,
              systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            ),
          );

          return MaterialApp(
            title: 'Smart City Tegal',
            debugShowCheckedModeBanner: false,
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
