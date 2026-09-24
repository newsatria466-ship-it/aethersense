import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smart_city_tegal/controllers/telemetry_controller.dart';
import 'package:smart_city_tegal/screens/dashboard_screen.dart';
import 'package:smart_city_tegal/services/mqtt_service.dart';
import 'package:smart_city_tegal/services/update_service.dart';

void main() {
  testWidgets('AetherSense smoke test', (WidgetTester tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;

    // Use isolated MqttService without real TCP sockets in widget test
    final testMqtt = MqttService(autoConnect: false);
    final testController = TelemetryController(mqttService: testMqtt);
    final testUpdate = UpdateService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<TelemetryController>.value(value: testController),
          ChangeNotifierProvider<UpdateService>.value(value: testUpdate),
        ],
        child: const MaterialApp(
          home: DashboardScreen(),
        ),
      ),
    );

    expect(find.text('AetherSense Dashboard'), findsOneWidget);
    expect(find.text('AetherSense'), findsOneWidget);

    // Unmount and dispose controllers cleanly
    await tester.pumpWidget(const SizedBox());
    testController.dispose();
    testUpdate.dispose();
  });
}
