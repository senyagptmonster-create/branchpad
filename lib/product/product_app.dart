import 'package:flutter/material.dart';

import '../app/brand.dart';
import '../app/theme.dart';
import 'mind_store.dart';
import 'screens.dart';

class ProductApp extends StatefulWidget {
  const ProductApp({super.key});

  @override
  State<ProductApp> createState() => _ProductAppState();
}

class _ProductAppState extends State<ProductApp> {
  final MindStore _store = MindStore();
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _store.load();
  }

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MindScope(
      store: _store,
      child: AnimatedBuilder(
        animation: _store,
        builder: (context, _) {
          if (!_store.ready) {
            return const Scaffold(
              backgroundColor: cBg,
              body: Center(
                child: CircularProgressIndicator(color: cAccent, strokeWidth: 2),
              ),
            );
          }

          return Scaffold(
            backgroundColor: cBg,
            body: SafeArea(
              bottom: false,
              child: IndexedStack(
                index: _tab,
                children: [
                  MapsScreen(onOpenCanvas: () => setState(() => _tab = 1)),
                  const CanvasScreen(),
                  const OutlineScreen(),
                  const SettingsScreen(),
                ],
              ),
            ),
            bottomNavigationBar: _BottomBar(
              index: _tab,
              onTap: (i) => setState(() => _tab = i),
            ),
          );
        },
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.index, required this.onTap});

  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final items = [
      (icon: Icons.map_rounded, label: 'Карты'),
      (icon: Icons.account_tree_rounded, label: 'Холст'),
      (icon: Icons.format_list_bulleted_rounded, label: 'Структура'),
      (icon: Icons.tune_rounded, label: 'Опции'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: cSurface,
        border: Border(top: BorderSide(color: cEdge)),
      ),
      padding: const EdgeInsets.only(top: 8, bottom: 22),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTap(i),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      items[i].icon,
                      size: 22,
                      color: i == index ? cAccent : AppTheme.textMuted,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      items[i].label,
                      style: AppTheme.text(
                        11,
                        color: i == index ? cAccent : AppTheme.textMuted,
                        weight: i == index ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
