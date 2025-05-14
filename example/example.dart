import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:malsami/malsami.dart';

void main() {
  runApp(const MalsamiDemoApp());
}

class MalsamiDemoApp extends StatelessWidget {
  const MalsamiDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Malsami G2P Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MalsamiDemoPage(),
    );
  }
}

class MalsamiDemoPage extends StatefulWidget {
  const MalsamiDemoPage({super.key});

  @override
  State<MalsamiDemoPage> createState() => _MalsamiDemoPageState();
}

class _MalsamiDemoPageState extends State<MalsamiDemoPage> {
  final TextEditingController _textController = TextEditingController();
  String _phonemes = '';
  bool _isLoading = false;
  final EnglishG2P _g2p = EnglishG2P();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeG2P();
  }

  Future<void> _initializeG2P() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Initialize the G2P engine
      await _g2p.initialize();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      // Handle initialization error
      log('Error initializing G2P: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _convertText() async {
    if (!_isInitialized || _textController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Convert text to phonemes
      final (phonemes, _) = await _g2p.convert(_textController.text);
      setState(() {
        _phonemes = phonemes;
      });
    } catch (e) {
      // Handle conversion error
      log('Error converting text: $e');
      setState(() {
        _phonemes = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Malsami G2P Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Enter text to convert',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              enabled: _isInitialized && !_isLoading,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isInitialized && !_isLoading ? _convertText : null,
              child:
                  _isLoading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Text('Convert to Phonemes'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Phonetic Representation:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child:
                  _isInitialized
                      ? SelectableText(
                        _phonemes.isEmpty
                            ? 'Enter text and press Convert'
                            : _phonemes,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 16,
                        ),
                      )
                      : const Center(child: Text('Initializing G2P engine...')),
            ),
            const SizedBox(height: 24),
            const Text(
              'Example Inputs:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _exampleChip('Hello world!'),
                _exampleChip('Malsami is a G2P engine.'),
                _exampleChip('How are you today?'),
                _exampleChip('[Kokoro](/kˈOkəɹO/) models'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _exampleChip(String text) {
    return InputChip(
      label: Text(text),
      onPressed:
          _isInitialized && !_isLoading
              ? () {
                _textController.text = text;
                _convertText();
              }
              : null,
    );
  }
}
