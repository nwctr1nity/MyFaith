import 'package:material_ui/material_ui.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 24, 20, 8),
      child: Text(
        text,
        style: theme.textTheme.titleSmall
            ?.copyWith(color: theme.colorScheme.primary),
      ),
    );
  }
}

/// A paragraph of secondary explanatory text inside a settings list.
class HintText extends StatelessWidget {
  const HintText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 8),
      child: Text(
        text,
        style: theme.textTheme.bodySmall
            ?.copyWith(color: theme.colorScheme.onSurfaceVariant, height: 1.4),
      ),
    );
  }
}

/// Opens a bottom sheet with [options] and returns the picked one through
/// [onSelected].
Future<void> pickOption<T>(
  BuildContext context, {
  required String title,
  required T selected,
  required Map<T, String> options,
  required void Function(T) onSelected,
}) async {
  final entry = await showModalBottomSheet<MapEntry<T, String>>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: options.length > 6 ? 0.8 : 0.5,
      builder: (context, scroll) => ListView(
        controller: scroll,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 8),
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          for (final e in options.entries)
            ListTile(
              title: Text(e.value),
              trailing: e.key == selected ? const Icon(Icons.check) : null,
              onTap: () => Navigator.of(context).pop(e),
            ),
        ],
      ),
    ),
  );
  if (entry != null) onSelected(entry.key);
}
