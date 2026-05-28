import 'package:flutter/material.dart';

void main() {
  runApp(const _BootstrapPlaceholderApp());
}

class _BootstrapPlaceholderApp extends StatelessWidget {
  const _BootstrapPlaceholderApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Stock Calendar v2',
      home: Scaffold(body: SizedBox.shrink()),
    );
  }
}
