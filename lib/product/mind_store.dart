import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MindNode {
  final String id;
  String text;
  int colorValue;
  double x;
  double y;
  final List<MindNode> children;

  MindNode({
    required this.id,
    required this.text,
    required this.colorValue,
    required this.x,
    required this.y,
    List<MindNode>? children,
  }) : children = children ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'colorValue': colorValue,
        'x': x,
        'y': y,
        'children': children.map((c) => c.toJson()).toList(),
      };

  static MindNode fromJson(Map<String, dynamic> j) => MindNode(
        id: (j['id'] ?? '').toString(),
        text: (j['text'] ?? '').toString(),
        colorValue: (j['colorValue'] as num?)?.toInt() ?? 0xFF6C8AE4,
        x: (j['x'] as num?)?.toDouble() ?? 150.0,
        y: (j['y'] as num?)?.toDouble() ?? 150.0,
        children: (j['children'] as List? ?? [])
            .map((e) => MindNode.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  int get totalNodesCount => 1 + children.fold(0, (sum, c) => sum + c.totalNodesCount);
}

class MindMap {
  final String id;
  String title;
  MindNode root;

  MindMap({
    required this.id,
    required this.title,
    required this.root,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'root': root.toJson(),
      };

  static MindMap fromJson(Map<String, dynamic> j) => MindMap(
        id: (j['id'] ?? '').toString(),
        title: (j['title'] ?? 'Карта идей').toString(),
        root: MindNode.fromJson(j['root'] as Map<String, dynamic>),
      );
}

class MindStore extends ChangeNotifier {
  static const _mapsKey = 'branchpad_maps_v1';

  final List<MindMap> _maps = [];
  bool _ready = false;
  MindMap? _activeMap;

  bool get ready => _ready;
  List<MindMap> get maps => List.unmodifiable(_maps);
  MindMap get activeMap => _activeMap ?? _maps.first;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_mapsKey);
      if (raw != null) {
        final list = jsonDecode(raw) as List;
        _maps.clear();
        for (final item in list) {
          _maps.add(MindMap.fromJson(item as Map<String, dynamic>));
        }
      }
    } catch (_) {}

    if (_maps.isEmpty) {
      _seedDemoMaps();
    }

    _activeMap = _maps.first;
    _ready = true;
    notifyListeners();
  }

  void _seedDemoMaps() {
    _maps.clear();
    _maps.add(
      MindMap(
        id: 'm1',
        title: 'Запуск мобильного продукта',
        root: MindNode(
          id: 'r1',
          text: 'Мобильный продукт',
          colorValue: 0xFF6C8AE4,
          x: 160.0,
          y: 150.0,
          children: [
            MindNode(
              id: 'c1',
              text: 'Дизайн и UI/UX',
              colorValue: 0xFFE4A36C,
              x: 60.0,
              y: 60.0,
              children: [
                MindNode(id: 's1', text: 'Вайрфреймы', colorValue: 0xFF6C8AE4, x: 20.0, y: 10.0),
                MindNode(id: 's2', text: 'UI Kit', colorValue: 0xFF6C8AE4, x: 90.0, y: 10.0),
              ],
            ),
            MindNode(
              id: 'c2',
              text: 'Разработка Flutter',
              colorValue: 0xFF4ECFC0,
              x: 260.0,
              y: 60.0,
              children: [
                MindNode(id: 's3', text: 'Логика и стор', colorValue: 0xFF4ECFC0, x: 220.0, y: 10.0),
                MindNode(id: 's4', text: 'Тесты', colorValue: 0xFF4ECFC0, x: 290.0, y: 10.0),
              ],
            ),
            MindNode(
              id: 'c3',
              text: 'Маркетинг и ASO',
              colorValue: 0xFFE0393E,
              x: 160.0,
              y: 250.0,
            ),
          ],
        ),
      ),
    );
  }

  void selectMap(MindMap map) {
    _activeMap = map;
    notifyListeners();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_mapsKey, jsonEncode(_maps.map((m) => m.toJson()).toList()));
    } catch (_) {}
  }

  Future<void> addMap(String title, String rootText) async {
    final map = MindMap(
      id: 'm_${DateTime.now().millisecondsSinceEpoch}',
      title: title.trim(),
      root: MindNode(
        id: 'r_${DateTime.now().millisecondsSinceEpoch}',
        text: rootText.trim(),
        colorValue: 0xFF6C8AE4,
        x: 160.0,
        y: 150.0,
      ),
    );
    _maps.add(map);
    _activeMap = map;
    notifyListeners();
    await _persist();
  }

  Future<void> addChildNode(MindNode parent, String text, int colorValue) async {
    final child = MindNode(
      id: 'n_${DateTime.now().millisecondsSinceEpoch}',
      text: text.trim(),
      colorValue: colorValue,
      x: parent.x + (parent.children.length % 2 == 0 ? -60.0 : 60.0),
      y: parent.y + 80.0,
    );
    parent.children.add(child);
    notifyListeners();
    await _persist();
  }

  Future<void> deleteMap(MindMap map) async {
    _maps.removeWhere((m) => m.id == map.id);
    if (_activeMap?.id == map.id) {
      _activeMap = _maps.isNotEmpty ? _maps.first : null;
    }
    notifyListeners();
    await _persist();
  }

  Future<void> resetAll() async {
    _maps.clear();
    _seedDemoMaps();
    _activeMap = _maps.first;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_mapsKey);
    } catch (_) {}
  }
}

class MindScope extends InheritedNotifier<MindStore> {
  const MindScope({super.key, required MindStore store, required super.child})
      : super(notifier: store);

  static MindStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<MindScope>();
    assert(scope != null, 'MindScope not found');
    return scope!.notifier!;
  }
}
