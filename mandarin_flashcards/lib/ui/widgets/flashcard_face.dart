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
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 720), // new: keep readable line length 🌙
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,   // new: nicer multi-line centering 🌙
        children: [
          // TITLE
          Text(
            title,
            style: theme.textTheme.displayMedium,
            softWrap: true,                 // new: allow wrapping 🌙
            overflow: TextOverflow.visible, // new: no ellipsis unless you set maxLines 🌙
            textAlign: TextAlign.center,    // new: center long lines 🌙
          ),

          if (subtitle != null && subtitle!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: theme.textTheme.titleLarge,
              softWrap: true,                 // new 🌙
              overflow: TextOverflow.visible, // new 🌙
              textAlign: TextAlign.center,    // new 🌙
            ),
          ],

          if (footnote != null && footnote!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              footnote!,
              style: theme.textTheme.bodyMedium,
              softWrap: true,                 // new 🌙
              overflow: TextOverflow.visible, // new 🌙
              textAlign: TextAlign.center,    // new 🌙
            ),
          ],
        ],
      ),
    );
  }
}