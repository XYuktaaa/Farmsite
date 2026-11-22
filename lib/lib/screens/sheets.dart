import 'package:material_ui/material_ui.dart';

import '../education/content.dart';
import '../game/game_state.dart';
import '../models/crop.dart';

void _sheet(
  BuildContext context,
  GameState gs,
  String title,
  List<Widget> Function() build,
) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.8,
    ),
    builder: (ctx) => ListenableBuilder(
      listenable: gs,
      builder: (c, w) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Text(title, style: Theme.of(c).textTheme.headlineSmall),
          const SizedBox(height: 8),
          ...build(),
        ],
      ),
    ),
  );
}

Widget _header(String t) => Padding(
  padding: const EdgeInsets.only(top: 12, bottom: 4),
  child: Text(
    t,
    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
  ),
);

void showLessonDialog(BuildContext context, Lesson l, {bool reward = false}) {
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.school),
      title: Text(l.title),
      content: SingleChildScrollView(child: Text(l.body)),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(reward ? 'Got it (+5 XP)' : 'Close'),
        ),
      ],
    ),
  );
}

// ---------- Shop ----------
void showShop(BuildContext context, GameState gs) => _sheet(
  context,
  gs,
  'Seed Shop',
  () => [
    Text('Coins: ${gs.coins}'),
    const SizedBox(height: 8),
    for (final id in cropOrder) _seedTile(gs, crops[id]!),
    _header('Supplies'),
    Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.science)),
        title: const Text('Fertilizer (NPK) · 10 coins'),
        subtitle: const Text('Speeds growth by about 30% on one crop.'),
        trailing: FilledButton(
          onPressed: gs.buyFertilizer,
          child: const Text('Buy'),
        ),
      ),
    ),
  ],
);

Widget _seedTile(GameState gs, Crop c) {
  final locked = gs.level < c.unlockLevel;
  return Card(
    child: ListTile(
      leading: CircleAvatar(backgroundColor: Color(c.color)),
      title: Text('${c.name} seed · ${c.seedCost} coins'),
      subtitle: Text(
        locked
            ? 'Unlocks at level ${c.unlockLevel}'
            : '${c.season.label} · grows in ${c.growSeconds}s · sells for ${c.sellPrice}\n${c.tip}',
      ),
      isThreeLine: !locked,
      trailing: FilledButton(
        onPressed: locked ? null : () => gs.buySeed(c.id),
        child: const Text('Buy'),
      ),
    ),
  );
}

// ---------- Barn / inventory ----------
void showBarn(BuildContext context, GameState gs) =>
    _sheet(context, gs, 'Barn', () {
      final w = <Widget>[_header('Seeds')];
      if (gs.seeds.isEmpty) {
        w.add(const ListTile(title: Text('No seeds. Buy some in the shop.')));
      }
      for (final e in gs.seeds.entries) {
        final c = crops[e.key]!;
        w.add(
          ListTile(
            leading: CircleAvatar(backgroundColor: Color(c.color)),
            title: Text('${c.name} seeds'),
            trailing: Text('x${e.value}'),
          ),
        );
      }
      w.add(
        ListTile(
          leading: const CircleAvatar(child: Icon(Icons.science)),
          title: const Text('Fertilizer (NPK)'),
          trailing: Text('x${gs.fertilizer}'),
        ),
      );
      w.add(_header('Harvested produce'));
      if (gs.produce.isEmpty) {
        w.add(const ListTile(title: Text('Nothing to sell yet.')));
      }
      for (final e in gs.produce.entries) {
        final c = crops[e.key]!;
        w.add(
          ListTile(
            leading: CircleAvatar(backgroundColor: Color(c.color)),
            title: Text('${c.name} x${e.value}'),
            subtitle: Text('${c.sellPrice} coins each'),
            trailing: FilledButton(
              onPressed: () => gs.sell(e.key),
              child: Text('Sell ${e.value * c.sellPrice}'),
            ),
          ),
        );
      }
      w.add(_header('Tools'));
      w.add(
        const ListTile(
          leading: Icon(Icons.agriculture),
          title: Text('Hoe (tilling)'),
        ),
      );
      w.add(
        const ListTile(
          leading: Icon(Icons.water_drop),
          title: Text('Watering can'),
        ),
      );
      return w;
    });

// ---------- Learning center ----------
void showLearn(BuildContext context, GameState gs) => _sheet(
  context,
  gs,
  'Learning Center',
  () => [
    Card(
      color: Colors.green.shade50,
      child: ListTile(
        leading: const Icon(Icons.quiz),
        title: const Text('Take the quiz'),
        subtitle: Text(
          '${gs.quizzesDone.length}/${quizQuestions.length} answered correctly · first-time correct answers earn coins and XP',
        ),
        onTap: () {
          Navigator.pop(context);
          showQuiz(context, gs);
        },
      ),
    ),
    _header('Lessons'),
    for (final l in lessons.values)
      ListTile(
        leading: Icon(
          gs.lessonsSeen.contains(l.id)
              ? Icons.check_circle
              : Icons.radio_button_unchecked,
          color: gs.lessonsSeen.contains(l.id) ? Colors.green : null,
        ),
        title: Text(l.title),
        subtitle: gs.lessonsSeen.contains(l.id)
            ? null
            : const Text('Do the matching farm action to unlock rewards'),
        onTap: () => showLessonDialog(context, l),
      ),
  ],
);

void showQuiz(BuildContext context, GameState gs) {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _QuizDialog(gs: gs),
  );
}

class _QuizDialog extends StatefulWidget {
  const _QuizDialog({required this.gs});
  final GameState gs;

  @override
  State<_QuizDialog> createState() => _QuizDialogState();
}

class _QuizDialogState extends State<_QuizDialog> {
  int _i = 0;
  int? _picked;
  int _score = 0;

  @override
  Widget build(BuildContext context) {
    if (_i >= quizQuestions.length) {
      return AlertDialog(
        title: const Text('Quiz complete'),
        content: Text(
          'You scored $_score / ${quizQuestions.length}. New correct answers earned coins and XP.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      );
    }
    final q = quizQuestions[_i];
    return AlertDialog(
      title: Text('Question ${_i + 1}/${quizQuestions.length}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              q.question,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            for (var k = 0; k < q.options.length; k++)
              Card(
                color: _picked == null
                    ? null
                    : (k == q.answer
                          ? Colors.green.shade100
                          : (k == _picked ? Colors.red.shade100 : null)),
                child: ListTile(
                  title: Text(q.options[k]),
                  onTap: _picked != null
                      ? null
                      : () {
                          setState(() {
                            _picked = k;
                            if (k == q.answer) _score++;
                          });
                          widget.gs.answerQuiz(q.id, k == q.answer);
                        },
                ),
              ),
            if (_picked != null) ...[
              const SizedBox(height: 8),
              Text(q.explanation),
            ],
          ],
        ),
      ),
      actions: [
        if (_picked != null)
          FilledButton(
            onPressed: () => setState(() {
              _i++;
              _picked = null;
            }),
            child: Text(_i == quizQuestions.length - 1 ? 'Finish' : 'Next'),
          ),
      ],
    );
  }
}

// ---------- Profile ----------
void showProfile(BuildContext context, GameState gs) => _sheet(
  context,
  gs,
  'Profile & Progress',
  () => [
    ListTile(
      leading: const CircleAvatar(child: Icon(Icons.person)),
      title: Text('Level ${gs.level}'),
      subtitle: Text('${gs.xp} XP total · ${gs.coins} coins'),
    ),
    LinearProgressIndicator(
      value: gs.levelProgress,
      minHeight: 8,
      borderRadius: BorderRadius.circular(4),
    ),
    _header('Farm statistics'),
    for (final id in cropOrder)
      ListTile(
        dense: true,
        leading: CircleAvatar(
          radius: 10,
          backgroundColor: Color(crops[id]!.color),
        ),
        title: Text('${crops[id]!.name} harvested'),
        trailing: Text('${gs.harvested[id] ?? 0}'),
      ),
    ListTile(
      dense: true,
      leading: const Icon(Icons.school),
      title: const Text('Lessons completed'),
      trailing: Text('${gs.lessonsSeen.length}/${lessons.length}'),
    ),
    _header('Achievements'),
    for (final a in gs.achievements)
      ListTile(
        leading: Icon(
          a.done ? Icons.emoji_events : Icons.lock_outline,
          color: a.done ? Colors.amber : Colors.grey,
        ),
        title: Text(a.title),
        subtitle: Text(a.description),
      ),
  ],
);
