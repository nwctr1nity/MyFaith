import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';

class SourcesScreen extends StatelessWidget {
  const SourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final style =
        Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.55);
    return Scaffold(
      appBar: AppBar(title: Text(l.sources)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(l.sourcesQuran, style: style),
          const SizedBox(height: 16),
          Text(l.sourcesHadith, style: style),
          const SizedBox(height: 16),
          Text(l.sourcesOther, style: style),
        ],
      ),
    );
  }
}
