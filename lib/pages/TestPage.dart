import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  int _counter = 0;
  String _inputText = '';
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Test Dialog'),
          content: const Text('This is a test dialog that you can customize later.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    _showSnackBar('Copied to clipboard!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      backgroundColor: const Color(0xFF4A90A4),
      iconTheme: const IconThemeData(
        color: Colors.white, 
      ),
      elevation: 2,
      title: const Text(
        'Test Functions',
        style: TextStyle(
          fontWeight: FontWeight.bold, 
          color: Colors.white,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
    ),
      body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF7FB3D3), // Light blue
            Color(0xFFB8E6B8), // Light green
          ],
        ),
      ),
      // color: const Color.fromARGB(255, 180, 221, 218),
      // padding: const EdgeInsets.all(20),
      child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Counter Section
            _buildSection(
              title: 'Counter Test',
              content: Column(
                children: [
                  Text(
                    'Count: $_counter',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _incrementCounter,
                    child: const Text('Increment'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Text Input Section
            _buildSection(
              title: 'Text Input Test',
              content: Column(
                children: [
                  TextField(
                    controller: _textController,
                    onChanged: (value) {
                      setState(() {
                        _inputText = value;
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Type something...',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('You typed: $_inputText'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _inputText.isNotEmpty 
                        ? () => _copyToClipboard(_inputText)
                        : null,
                    child: const Text('Copy Text'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Button Actions Section
            _buildSection(
              title: 'Action Tests',
              content: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _showSnackBar('Button 1 pressed!'),
                        icon: const Icon(Icons.notifications),
                        label: const Text('Show Alert'),
                      ),
                      ElevatedButton.icon(
                        onPressed: _showDialog,
                        icon: const Icon(Icons.info),
                        label: const Text('Show Dialog'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _showSnackBar('Feature coming soon!'),
                    icon: const Icon(Icons.star),
                    label: const Text('Future Feature'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Info Section
            _buildSection(
              title: 'System Info',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Flutter Version: ${_getFlutterVersion()}'),
                  const SizedBox(height: 4),
                  Text('Platform: ${_getPlatform()}'),
                  const SizedBox(height: 4),
                  Text('Time: ${DateTime.now().toString().split('.')[0]}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget content}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 0, 147, 177),
              ),
            ),
            const SizedBox(height: 12),
            content,
          ],
        ),
      ),
    );
  }

  String _getFlutterVersion() {
    // You can replace this with actual version detection
    return '3.x.x';
  }

  String _getPlatform() {
    return Theme.of(context).platform.toString().split('.').last;
  }
}
