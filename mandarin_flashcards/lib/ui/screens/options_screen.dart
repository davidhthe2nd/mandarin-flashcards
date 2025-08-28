import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/options_state.dart';
import '../../utils/colors.dart'; // theming helpers

class OptionsScreen extends StatelessWidget {
  const OptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final opts = context.watch<OptionsState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Options')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Show Pinyin'),
            subtitle: const Text('Display pinyin alongside characters'),
            value: opts.showPinyin,
            onChanged: (v) => context.read<OptionsState>().toggleShowPinyin(v),
          ),
          const Divider(),

          SwitchListTile(
            title: const Text('Invert language pair'),
            subtitle: const Text('Spanish → Chinese (front shows Spanish)'),
            value: opts.invertPair,
            onChanged: (v) => context.read<OptionsState>().toggleInvertPair(v),
          ),

          SwitchListTile(
            title: const Text('Dark mode'),
            subtitle: const Text('Use a dark theme throughout the app'),
            value: opts.darkMode,
            onChanged: (v) => context.read<OptionsState>().toggleDarkMode(v),
          ),

          const Divider(),
          SwitchListTile(
            title: const Text('Dark mode'),
            value: opts.darkMode,
            onChanged: (v) => context.read<OptionsState>().setDarkMode(v),
          ),
          ListTile(
            title: const Text('Theme palette'),
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
                    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            'Coming soon',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const ListTile(
            title: Text('Font size'),
            subtitle: Text('Adjust character and pinyin size'),
            enabled: false,
          ),
          

          const Divider(),

          
        ],
      ),
    );
  }
}