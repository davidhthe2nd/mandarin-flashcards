// lib/ui/screens/grammar_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/grammar_detail_content.dart';
import '../../state/options_state.dart';
import '../../l10n/app_localizations.dart';
import 'grammar_detail_screen.dart';

class GrammarScreen extends StatelessWidget {
  const GrammarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final opts = context.watch<OptionsState>(); //

    return Scaffold(
      appBar: AppBar(title: Text(l10n.grammarTitle)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: grammarLibrary.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final article = grammarLibrary[index];
          return Card(
            child: ListTile(
              title: Text(
                article.getTitle(opts.localeCode), //
                style: const TextStyle(fontWeight: FontWeight.bold)
              ),
              subtitle: Text(article.getPreview(opts.localeCode)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => GrammarDetailScreen(article: article)),
              ),
            ),
          );
        },
      ),
    );
  }
}