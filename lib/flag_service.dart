import 'dart:convert';
import 'package:flagsmith/flagsmith.dart';

/// Удалённый конфиг. Любая осечка — нет сети, нет флага, битый JSON —
/// возвращает состояние «показываем продукт».
class FlagService {
  static const String _apiKey = '6UQgZUwFugS3G6AAbvbVBh';

  FlagsmithClient? _client;
  bool showWebView = false;
  Map<String, String> webViewConfig = {};

  Future<void> init() async {
    try {
      _client = await FlagsmithClient.init(
        apiKey: _apiKey,
        config: const FlagsmithConfig(caches: false),
      );
      await _client!.getFeatureFlags(reload: true);
      final raw = await _client!.getFeatureFlagValue('appconfig');
      if (raw != null && raw.isNotEmpty) {
        applyFromJson(raw);
      } else {
        _reset();
      }
    } catch (_) {
      _reset();
    }
  }

  void applyFromJson(String json) {
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      showWebView = map['showWebView'] as bool? ?? false;
      final cfg = map['webViewConfig'] as Map<String, dynamic>? ?? {};
      webViewConfig = cfg.map((k, v) => MapEntry(k, v.toString()));
    } catch (_) {
      _reset();
    }
  }

  void _reset() {
    showWebView = false;
    webViewConfig = {};
  }

  void close() => _client?.close();
}