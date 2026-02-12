import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/options_state.dart';
import '../../utils/colors.dart'; // theming helpers
import "../../state/deck_state.dart"; // new: to update mix 🌙
import "../../l10n/app_localizations.dart";
import "../widgets/confirm_dialog.dart"; // new: for reset confirmation dialog 🌙

class OptionsScreen extends StatelessWidget {
  const OptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final opts = context.watch<OptionsState>();
    final deck = context.read<DeckState>();
    final t = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final totalPercent = ((opts.mixToLearn + opts.mixForgotten + opts.mixAlmost) * 100).round();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.optionsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // SwitchListTile(
          //   title: const Text('Show Pinyin'),
          //   subtitle: const Text('Display pinyin alongside characters'),
          //   value: opts.showPinyin,
          //   onChanged: (v) => context.read<OptionsState>().toggleShowPinyin(v),
          // ),
          // const Divider(),

          // SwitchListTile(
          //   title: const Text('Invert language pair'),
          //   subtitle: const Text('Spanish → Chinese (front shows Spanish)'),
          //   value: opts.invertPair,
          //   onChanged: (v) => context.read<OptionsState>().toggleInvertPair(v),
          // ),

          // const Divider(),
          // SwitchListTile(
          //   title: const Text('Dark mode'),
          //   value: opts.darkMode,
          //   onChanged: (v) => context.read<OptionsState>().setDarkMode(v),
          // ),
          ListTile(
            title: Text(l10n.themePalette),
            subtitle: Text(TestPalettes.names[opts.activePaletteIndex]),
            trailing: DropdownButton<int>(
              value: opts.activePaletteIndex,
              onChanged: (idx) {
                if (idx != null) {
                  context.read<OptionsState>().setActivePaletteIndex(idx);
                }
              },
              items: List.generate(TestPalettes.all.length, (i) {
                return DropdownMenuItem(
                  value: i,
                  child: Text(TestPalettes.names[i]),
                );
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              spacing: 8,
              children: TestPalettes.all[opts.activePaletteIndex].map((hex) {
                return Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(int.parse(hex.replaceFirst('#', '0xFF'))),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(),
          Text(l10n.hskLevels, style: t.titleMedium),
          const SizedBox(height: 12),
          Wrap(
          spacing: 8,      // Horizontal space between chips
          runSpacing: 12,  // Vertical space between lines (Fixes your 2nd issue!)
          children: List.generate(6, (index) {
            final level = index + 1;
            final isSelected = opts.includesHSK(level);
            
            return FilterChip(
              label: Text("HSK $level"),
              selected: isSelected,
              showCheckmark: false, // Prevents width change/jumping
              // Optional: Explicitly set padding to keep them consistent
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              onSelected: (selected) async {
                await opts.toggleHSK(level, selected);

                final deck = context.read<DeckState>();
                deck.applyHSKAndRequeue(
                  opts.hskLevels,
                  target: opts.dailyTarget,
                );
              },
              );
            }),
          ),

          const SizedBox(height: 6),
          const Divider(),

          // Title
          const SizedBox(height: 16),
          Text(l10n.studyMix, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),

          // To-learn
          Row(
            children: [
              SizedBox(width: 88, child: Text(l10n.toLearn)),
              Expanded(
                child: Slider(
                  value: (opts.mixToLearn * 100),
                  min: 0,
                  max: 100,
                  divisions: 20,
                  label: '${(opts.mixToLearn * 100).round()}%',
                  onChanged: (v) async {
                    await context.read<OptionsState>().setMix(toLearn: v);
                    deck.setMix(
                      toLearn: context.read<OptionsState>().mixToLearn,
                      forgotten: context.read<OptionsState>().mixForgotten,
                      almost: context.read<OptionsState>().mixAlmost,
                    );
                    deck.rebuildDueQueueWeighted();
                  },
                ),
              ),
            ],
          ),

          // Forgotten
          Row(
            children: [
              SizedBox(width: 88, child: Text(l10n.forgotten)),
              Expanded(
                child: Slider(
                  value: (opts.mixForgotten * 100),
                  min: 0,
                  max: 100,
                  divisions: 20,
                  label: '${(opts.mixForgotten * 100).round()}%',
                  onChanged: (v) async {
                    await context.read<OptionsState>().setMix(forgotten: v);
                    deck.setMix(
                      toLearn: context.read<OptionsState>().mixToLearn,
                      forgotten: context.read<OptionsState>().mixForgotten,
                      almost: context.read<OptionsState>().mixAlmost,
                    );
                    deck.rebuildDueQueueWeighted();
                  },
                ),
              ),
            ],
          ),

          // Almost
          Row(
            children: [
              SizedBox(width: 88, child: Text(l10n.almost)),
              Expanded(
                child: Slider(
                  value: (opts.mixAlmost * 100),
                  min: 0,
                  max: 100,
                  divisions: 20,
                  label: '${(opts.mixAlmost * 100).round()}%',
                  onChanged: (v) async {
                    await context.read<OptionsState>().setMix(almost: v);
                    deck.setMix(
                      toLearn: context.read<OptionsState>().mixToLearn,
                      forgotten: context.read<OptionsState>().mixForgotten,
                      almost: context.read<OptionsState>().mixAlmost,
                    );
                    deck.rebuildDueQueueWeighted();
                  },
                ),
              ),
            ],
          ),

          // Summary
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              l10n.studyMixTotal(totalPercent),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          

          const SizedBox(height: 18),
          TextButton.icon(
            onPressed: () => opts.clearAllFilters(),
            icon: const Icon(Icons.filter_alt_off_rounded),
            label: Text(l10n.clearFilters),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
          ),
          
          const SizedBox(height: 24),
          Text(
            l10n.comingSoon,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ListTile(
            title: Text(l10n.fontSize),
            subtitle: Text(l10n.fontSubtitle),
            enabled: false,
          ),

          const Divider(),

          const SizedBox(height: 12),
          

          if (opts.showBetaFeatures) ...[
            const Divider(),
            DropdownButtonFormField<int>(
            value: opts.selectedLesson,
            decoration: InputDecoration(labelText: l10n.textbookLesson),
            items: [
              DropdownMenuItem(value: 0, child: Text(l10n.allLessons)),
              ...List.generate(10, (i) => DropdownMenuItem(value: i + 1, child: Text(l10n.lesson(i + 1)))),
              ],
              onChanged: (val) => opts.setSelectedLesson(val ?? 0),
              ),
             const Divider(),
             Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () async {
                  final confirmed = await showConfirmDialog(
                    context: context,
                    title: "Clear all data?",
                    message: "This will reset all your word mastery. This cannot be undone.",
                    confirmText: "Reset",
                  );

                  if (confirmed == true && context.mounted) {
                    await context.read<DeckState>().clearAllProgress();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("All progress cleared")),
                    );
                  }
                },
                icon: const Icon(Icons.delete_forever_rounded),
                label: const Text("Reset App Progress"),
              ),
            ),

          ],
        ],
      ),
    );
  }
}
