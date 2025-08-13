import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/options_state.dart';

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
          const ListTile(
            title: Text('Theme'),
            subtitle: Text('Light / Dark'),
            enabled: false,
          ),
        ],
      ),
    );
  }
}