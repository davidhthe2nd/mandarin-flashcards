// lib/ui/screens/grammar_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/grammar_detail_content.dart';
import '../../state/options_state.dart';
import '../../l10n/app_localizations.dart';

class GrammarDetailScreen extends StatelessWidget {
  final GrammarArticle article;
  const GrammarDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final opts = context.watch<OptionsState>();
    final l10n = AppLocalizations.of(context)!;
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(article.getTitle(opts.localeCode))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(article.getContent(opts.localeCode), style: t.bodyLarge),
            const SizedBox(height: 32),
            if (article.examples.isNotEmpty) ...[
              Text(l10n.examplesLabel, style: t.titleLarge?.copyWith(color: cs.primary)),
              const Divider(),
              ...article.examples.map((ex) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ex.chinese, style: t.headlineSmall),
                    Text(ex.pinyin, style: t.bodyMedium?.copyWith(fontStyle: FontStyle.italic)),
                    Text(ex.getTranslation(opts.localeCode), style: t.bodyMedium?.copyWith(color: cs.secondary)),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }
}