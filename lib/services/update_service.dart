import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:ota_update/ota_update.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppUpdateInfo {
  final String latestVersion;
  final int latestVersionCode;
  final String changelog;
  final String apkUrl;
  final bool hasUpdate;
  final String currentVersion;

  AppUpdateInfo({
    required this.latestVersion,
    required this.latestVersionCode,
    required this.changelog,
    required this.apkUrl,
    required this.hasUpdate,
    required this.currentVersion,
  });
}

class UpdateService extends ChangeNotifier {
  // Daftar endpoint pengecekan pembaruan:
  // 1. Web server lokal di laptop (Apache di 192.168.18.159)
  // 2. URL raw GitHub (jika nanti sudah dipublikasikan online)
  static const List<String> defaultEndpoints = [
    'https://raw.githubusercontent.com/newsatria466-ship-it/aethersense/main/version.json',
    'http://192.168.0.110/version.json',
  ];

  String _currentVersion = '1.0.0';
  bool _isChecking = false;
  bool _isDownloading = false;
  String _downloadProgress = '0%';
  String? _errorMessage;
  AppUpdateInfo? _updateInfo;

  String get currentVersion => _currentVersion;
  bool get isChecking => _isChecking;
  bool get isDownloading => _isDownloading;
  String get downloadProgress => _downloadProgress;
  String? get errorMessage => _errorMessage;
  AppUpdateInfo? get updateInfo => _updateInfo;

  UpdateService() {
    _initVersion();
  }

  Future<void> _initVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      _currentVersion = info.version;
      notifyListeners();
    } catch (_) {
      _currentVersion = '1.0.0';
    }
  }

  /// Memeriksa apakah ada pembaruan di server/GitHub
  Future<AppUpdateInfo?> checkForUpdate({String? customUrl}) async {
    _isChecking = true;
    _errorMessage = null;
    notifyListeners();

    final List<String> urlsToTry = customUrl != null
        ? [customUrl]
        : defaultEndpoints;

    for (final urlStr in urlsToTry) {
      try {
        final url = Uri.parse(urlStr);
        final response = await http.get(url).timeout(const Duration(seconds: 4));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final String latestVersion = data['version'] ?? '1.0.0';
          final int latestCode = data['versionCode'] ?? 1;
          final String changelog = data['changelog'] ?? 'Pembaruan sistem';
          final String apkUrl = data['apkUrl'] ?? '';

          final info = await PackageInfo.fromPlatform();
          final currentVer =
              info.version.isNotEmpty ? info.version : _currentVersion;
          final int currentCode = int.tryParse(info.buildNumber) ?? 1;

          final bool hasNewer = latestCode > currentCode ||
              _isVersionGreaterThan(latestVersion, currentVer);

          _updateInfo = AppUpdateInfo(
            latestVersion: latestVersion,
            latestVersionCode: latestCode,
            changelog: changelog,
            apkUrl: apkUrl,
            hasUpdate: hasNewer,
            currentVersion: currentVer,
          );

          _isChecking = false;
          notifyListeners();
          return _updateInfo;
        }
      } catch (e) {
        if (kDebugMode) {
          print('Gagal cek update di $urlStr: $e');
        }
      }
    }

    _errorMessage = 'Tidak dapat menghubungi server pembaruan.';
    _isChecking = false;
    notifyListeners();
    return null;
  }

  /// Membandingkan semver string (misal "1.0.1" > "1.0.0")
  bool _isVersionGreaterThan(String newVer, String oldVer) {
    try {
      final newParts =
          newVer.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final oldParts =
          oldVer.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      for (int i = 0; i < 3; i++) {
        final n = i < newParts.length ? newParts[i] : 0;
        final o = i < oldParts.length ? oldParts[i] : 0;
        if (n > o) return true;
        if (n < o) return false;
      }
    } catch (_) {}
    return false;
  }

  /// Menjalankan download APK dan membuka installer Android secara otomatis
  StreamSubscription<OtaEvent>? startDownloadAndInstall({
    required String apkUrl,
    required void Function(String progress) onProgress,
    required void Function() onInstalling,
    required void Function(String error) onError,
  }) {
    _isDownloading = true;
    _downloadProgress = '0%';
    notifyListeners();

    try {
      return OtaUpdate().execute(
        apkUrl,
        destinationFilename: 'smart_city_tegal_update.apk',
      ).listen(
        (OtaEvent event) {
          switch (event.status) {
            case OtaStatus.DOWNLOADING:
              _downloadProgress = '${event.value}%';
              onProgress(_downloadProgress);
              notifyListeners();
              break;
            case OtaStatus.INSTALLING:
              _isDownloading = false;
              _downloadProgress = '100%';
              notifyListeners();
              onInstalling();
              break;
            case OtaStatus.ALREADY_RUNNING_ERROR:
              _isDownloading = false;
              onError('Proses download pembaruan sedang berjalan.');
              notifyListeners();
              break;
            case OtaStatus.PERMISSION_NOT_GRANTED_ERROR:
              _isDownloading = false;
              onError('Izin instalasi aplikasi belum diaktifkan di HP.');
              notifyListeners();
              break;
            case OtaStatus.INTERNAL_ERROR:
            case OtaStatus.CHECKSUM_ERROR:
            default:
              _isDownloading = false;
              onError('Gagal mengunduh file update: ${event.value}');
              notifyListeners();
              break;
          }
        },
        onError: (err) {
          _isDownloading = false;
          onError('Terjadi kesalahan download: $err');
          notifyListeners();
        },
      );
    } catch (e) {
      _isDownloading = false;
      onError('Error inisialisasi OTA: $e');
      notifyListeners();
      return null;
    }
  }
}
