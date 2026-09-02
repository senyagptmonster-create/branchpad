import 'package:flutter/material.dart';

import '../app/brand.dart';
import '../app/theme.dart';
import 'mind_store.dart';

/// Экран 1. Каталог карт мыслей
class MapsScreen extends StatelessWidget {
  const MapsScreen({super.key, required this.onOpenCanvas});

  final VoidCallback onOpenCanvas;

  @override
  Widget build(BuildContext context) {
    final store = MindScope.of(context);
    final maps = store.maps;

    return Scaffold(
      backgroundColor: cBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('BranchPad', style: AppTheme.display(28)),
                      const SizedBox(height: 4),
                      Text('Лёгкие карты мыслей и ветвления идей', style: AppTheme.text(13.5, color: AppTheme.textMuted)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_rounded, color: cAccent, size: 36),
                  onPressed: () => _showNewMapDialog(context, store),
                ),
              ],
            ),
            const SizedBox(height: 18),
            ...maps.map((m) {
              final isSelected = store.activeMap.id == m.id;
              final nodesCount = m.root.totalNodesCount;

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: cSurface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? cAccent : cEdge,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: cAccent.withValues(alpha: 0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: cAccent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text('$nodesCount узлов', style: AppTheme.text(12, color: cAccent, weight: FontWeight.w700)),
                          ),
                          if (maps.length > 1)
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.redAccent),
                              onPressed: () => store.deleteMap(m),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(m.title, style: AppTheme.display(20)),
                      const SizedBox(height: 4),
                      Text('Корень: ${m.root.text}', style: AppTheme.text(13, color: AppTheme.textMuted)),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: cAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () {
                            store.selectMap(m);
                            onOpenCanvas();
                          },
                          icon: const Icon(Icons.account_tree_rounded, size: 18),
                          label: Text('Открыть холст карты', style: AppTheme.text(14, color: Colors.white, weight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showNewMapDialog(BuildContext context, MindStore store) {
    final titleCtrl = TextEditingController(text: 'Новый проект');
    final rootCtrl = TextEditingController(text: 'Главная идея');

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cSurface,
        title: Text('Новая карта мыслей', style: AppTheme.display(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: InputDecoration(
                labelText: 'Название карты',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: rootCtrl,
              decoration: InputDecoration(
                labelText: 'Текст центрального узла',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Отмена')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: cAccent),
            onPressed: () async {
              final t = titleCtrl.text.trim();
              final r = rootCtrl.text.trim();
              if (t.isNotEmpty && r.isNotEmpty) {
                await store.addMap(t, r);
                if (ctx.mounted) Navigator.of(ctx).pop();
                onOpenCanvas();
              }
            },
            child: const Text('Создать'),
          ),
        ],
      ),
    );
  }
}

/// Экран 2. Холст карты мыслей
class CanvasScreen extends StatelessWidget {
  const CanvasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = MindScope.of(context);
    final map = store.activeMap;

    return Scaffold(
      backgroundColor: cBg,
      appBar: AppBar(
        title: Text(map.title, style: AppTheme.display(18)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Холст карты', style: AppTheme.display(24)),
            const SizedBox(height: 4),
            Text('Нажмите на любой узел, чтобы добавить ветвь', style: AppTheme.text(13, color: AppTheme.textMuted)),
            const SizedBox(height: 18),
            _NodeCard(node: map.root, isRoot: true, store: store),
            const SizedBox(height: 14),
            ...map.root.children.map((child) => Padding(
                  padding: const EdgeInsets.only(left: 20, bottom: 12),
                  child: _NodeCard(node: child, store: store),
                )),
          ],
        ),
      ),
    );
  }
}

class _NodeCard extends StatelessWidget {
  const _NodeCard({required this.node, this.isRoot = false, required this.store});

  final MindNode node;
  final bool isRoot;
  final MindStore store;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Color(node.colorValue), width: isRoot ? 2 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: Color(node.colorValue), shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  node.text,
                  style: AppTheme.display(isRoot ? 18 : 16),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_rounded, size: 20, color: cAccent),
                onPressed: () => _showAddChildDialog(context, node),
              ),
            ],
          ),
          if (node.children.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: node.children.map((sub) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(sub.colorValue).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(sub.colorValue)),
                  ),
                  child: Text(sub.text, style: AppTheme.text(12.5, color: cInk, weight: FontWeight.w600)),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  void _showAddChildDialog(BuildContext context, MindNode parent) {
    final textCtrl = TextEditingController();
    final colors = [0xFF6C8AE4, 0xFFE4A36C, 0xFF4ECFC0, 0xFFE0393E, 0xFF9B59B6];
    int selectedColor = colors.first;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: cSurface,
          title: Text('Добавить под-узел', style: AppTheme.display(18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: textCtrl,
                decoration: InputDecoration(
                  labelText: 'Текст идеи',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 14),
              Text('Цвет ветви:', style: AppTheme.text(13, color: AppTheme.textMuted)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: colors.map((c) {
                  final isSel = selectedColor == c;
                  return GestureDetector(
                    onTap: () => setState(() => selectedColor = c),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Color(c),
                        shape: BoxShape.circle,
                        border: Border.all(color: isSel ? Colors.black : Colors.transparent, width: 2),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Отмена')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: cAccent),
              onPressed: () async {
                final txt = textCtrl.text.trim();
                if (txt.isNotEmpty) {
                  await store.addChildNode(parent, txt, selectedColor);
                  if (ctx.mounted) Navigator.of(ctx).pop();
                }
              },
              child: const Text('Добавить'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Экран 3. Структура дерева (Outline)
class OutlineScreen extends StatelessWidget {
  const OutlineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = MindScope.of(context);
    final map = store.activeMap;

    return Scaffold(
      backgroundColor: cBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
          children: [
            Text('Структура карты', style: AppTheme.display(28)),
            const SizedBox(height: 4),
            Text('Иерархический список всех ветвей и узлов', style: AppTheme.text(13.5, color: AppTheme.textMuted)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cSurface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: cEdge),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.circle, size: 10, color: cAccent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(map.root.text, style: AppTheme.display(18)),
                      ),
                    ],
                  ),
                  const Divider(height: 20, color: cEdge),
                  ...map.root.children.map((child) => Padding(
                        padding: const EdgeInsets.only(left: 16, top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.subdirectory_arrow_right_rounded, size: 16, color: cAccent2),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(child.text, style: AppTheme.text(15, color: cInk, weight: FontWeight.w600)),
                                ),
                              ],
                            ),
                            ...child.children.map((sub) => Padding(
                                  padding: const EdgeInsets.only(left: 24, top: 4),
                                  child: Row(
                                    children: [
                                      Icon(Icons.remove, size: 14, color: AppTheme.textMuted),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(sub.text, style: AppTheme.text(13.5, color: AppTheme.textMuted)),
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Экран 4. Настройки
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = MindScope.of(context);

    return Scaffold(
      backgroundColor: cBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
          children: [
            Text('Настройки', style: AppTheme.display(28)),
            const SizedBox(height: 4),
            Text('BranchPad v1.0.0', style: AppTheme.text(13.5, color: AppTheme.textMuted)),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: cSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cEdge),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.account_tree_outlined, color: cAccent),
                    title: Text('Карт в базе', style: AppTheme.text(15, color: cInk)),
                    trailing: Text('${store.maps.length}', style: AppTheme.text(15, color: cAccent, weight: FontWeight.w700)),
                  ),
                  const Divider(height: 1, color: cEdge),
                  ListTile(
                    leading: const Icon(Icons.restart_alt_rounded, color: Colors.redAccent),
                    title: const Text('Сбросить все карты мыслей', style: TextStyle(color: Colors.redAccent)),
                    onTap: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: cSurface,
                          title: Text('Сбросить карты?', style: AppTheme.display(18)),
                          content: Text('Все пользовательские ветви будут удалены.', style: AppTheme.text(14, color: cInk)),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Отмена')),
                            FilledButton(
                              style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text('Сбросить'),
                            ),
                          ],
                        ),
                      );
                      if (ok == true) {
                        await store.resetAll();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
