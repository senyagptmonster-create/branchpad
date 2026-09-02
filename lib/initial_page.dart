import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import 'app/brand.dart';
import 'app/theme.dart';
import 'flag_service.dart';
import 'location_service.dart';
import 'product/product_app.dart';
import 'webview_page.dart';

/// Заставка и развилка по удалённому конфигу. Любой отказ ведёт в продукт,
/// а не в ошибку: нет сети, флаг выключен, страна не определилась, битый JSON.
class InitialPage extends StatefulWidget {
  const InitialPage({super.key});

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage>
    with SingleTickerProviderStateMixin {
  /// Сетевые шаги ограничены по времени: без этого медленный Flagsmith
  /// держит заставку сколько угодно.
  static const _flagTimeout = Duration(seconds: 6);
  static const _locationTimeout = Duration(seconds: 12);

  final FlagService _flagService = FlagService();
  final LocationService _locationService = LocationService();

  bool _loading = true;
  bool _webView = false;
  String _url = '';

  late final AnimationController _anim;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeIn);
    _start();
  }

  Future<void> _start() async {
    final splash = Future<void>.delayed(const Duration(milliseconds: 1500));

    final conn = await Connectivity().checkConnectivity();
    if (!conn.any((r) => r != ConnectivityResult.none)) {
      await splash;
      _showProduct();
      return;
    }

    final flags = _flagService.init().timeout(_flagTimeout, onTimeout: () {});
    final country = _locationService
        .getCountryCode()
        .timeout(_locationTimeout, onTimeout: () => null);

    await Future.wait([flags, splash]);
    _route(await country);
  }

  void _route(String? country) {
    if (!_flagService.showWebView) {
      _showProduct();
      return;
    }
    if (country != null && _flagService.webViewConfig.containsKey(country)) {
      _showWebView(_flagService.webViewConfig[country]!);
    } else {
      _showProduct();
    }
  }

  void _showProduct() {
    if (!mounted) return;
    setState(() {
      _webView = false;
      _loading = false;
    });
  }

  void _showWebView(String url) {
    if (!mounted) return;
    setState(() {
      _webView = true;
      _url = url;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _anim.dispose();
    _flagService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return _splash();
    if (_webView && _url.isNotEmpty) return WebviewPage(url: _url);
    return const ProductApp();
  }

  Widget _splash() {
    return Scaffold(
      backgroundColor: cBg,
      body: FadeTransition(
        opacity: _fade,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: Image.asset('assets/images/icon.png', width: 108),
              ),
              const SizedBox(height: 22),
              Text(kAppTitle, style: AppTheme.display(27)),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 44),
                child: Text(
                  kProductTagline,
                  textAlign: TextAlign.center,
                  style: AppTheme.text(13.5, color: AppTheme.textMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}