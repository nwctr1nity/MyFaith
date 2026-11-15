import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/content/names.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_settings.dart';
import '../theme.dart';

/// The 99 names of Allah: a quiz and the full list.
class NamesScreen extends StatelessWidget {
  const NamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.names99),
          bottom: TabBar(
            tabs: [
              Tab(text: l.namesQuiz),
              Tab(text: l.namesList),
            ],
          ),
        ),
        body: const TabBarView(children: [_Quiz(), _List()]),
      ),
    );
  }
}

class _Quiz extends ConsumerStatefulWidget {
  const _Quiz();

  @override
  ConsumerState<_Quiz> createState() => _QuizState();
}

class _QuizState extends ConsumerState<_Quiz>
    with AutomaticKeepAliveClientMixin {
  final _random = math.Random();
  NameQuestion? _question;
  String? _language;
  DivineName? _picked;
  int _streak = 0;

  @override
  bool get wantKeepAlive => true;

  void _next(String language) {
    // Not the same name twice in a row.
    var index = _random.nextInt(divineNames.length);
    if (_question != null && divineNames[index] == _question!.name) {
      index = (index + 1) % divineNames.length;
    }
    _question = nameQuestion(index, _random.nextInt, language);
    _language = language;
    _picked = null;
  }

  void _pick(DivineName option) {
    if (_picked != null) return;
    final right = option == _question!.name;
    setState(() {
      _picked = option;
      _streak = right ? _streak + 1 : 0;
    });
    if (right && _streak > ref.read(settingsProvider).namesBest) {
      ref.read(settingsProvider.notifier).setValue('namesBest', _streak);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final language = Localizations.localeOf(context).languageCode;
    final best = ref.watch(settingsProvider.select((s) => s.namesBest));
    if (_question == null || _language != language) _next(language);
    final question = _question!;
    final picked = _picked;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: heroGradient(scheme),
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [
              Text(
                l.namesQuestion,
                style: theme.textTheme.bodyMedium?.copyWith(color: onHeroMuted),
              ),
              const SizedBox(height: 8),
              Text(
                question.name.arabic,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: quranFont,
                  fontSize: 44,
                  height: 1.8,
                  color: onHero,
                ),
              ),
              if (language != 'ar')
                Text(
                  question.name.transliteration(language),
                  style: theme.textTheme.titleMedium?.copyWith(color: onHero),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        for (final option in question.options) ...[
          _Option(
            text: option.meaning(language),
            state: picked == null
                ? null
                : option == question.name
                ? true
                : option == picked
                ? false
                : null,
            enabled: picked == null,
            onTap: () => _pick(option),
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text(
                l.namesStreak(_streak, best),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
            if (picked != null)
              FilledButton(
                onPressed: () => setState(() => _next(language)),
                child: Text(l.namesNext),
              ),
          ],
        ),
      ],
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.text,
    required this.state,
    required this.enabled,
    required this.onTap,
  });

  final String text;

  /// True for the right answer once shown, false for a wrong pick.
  final bool? state;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = state == null
        ? scheme.surfaceContainerHigh
        : state!
        ? scheme.primaryContainer
        : scheme.errorContainer;
    final onColor = state == null
        ? scheme.onSurface
        : state!
        ? scheme.onPrimaryContainer
        : scheme.onErrorContainer;
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: theme.textTheme.titleMedium?.copyWith(color: onColor),
                ),
              ),
              if (state != null)
                Icon(
                  state! ? Icons.check_circle : Icons.cancel,
                  color: onColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _List extends StatelessWidget {
  const _List();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final language = Localizations.localeOf(context).languageCode;
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: divineNames.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final n = divineNames[i];
        return ListTile(
          leading: SizedBox(
            width: 32,
            child: Text(
              '${n.number}',
              style: theme.textTheme.labelLarge?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          title: Text(language == 'ar' ? n.english : n.meaning(language)),
          subtitle: Text(n.transliteration(language)),
          trailing: Text(
            n.arabic,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: quranFont,
              fontSize: 22,
              color: scheme.primary,
            ),
          ),
        );
      },
    );
  }
}
