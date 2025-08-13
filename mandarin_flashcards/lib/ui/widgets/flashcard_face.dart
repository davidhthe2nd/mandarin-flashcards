import 'package:flutter/material.dart';

class FlashcardFace extends StatelessWidget {
  const FlashcardFace({
    super.key,
    required this.title,
    this.subtitle,
    this.footnote,
  });

  final String title;
  final String? subtitle;
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      key: ValueKey('$title|${subtitle ?? ''}|${footnote ?? ''}'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(width: 1.0, color: Theme.of(context).dividerColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, textAlign: TextAlign.center, style: t.displaySmall),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(subtitle!, textAlign: TextAlign.center, style: t.titleLarge),
          ],
          if (footnote != null) ...[
            const SizedBox(height: 8),
            Text(footnote!, textAlign: TextAlign.center, style: t.bodyMedium),
          ],
        ],
      ),
    );
  }
}