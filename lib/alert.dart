import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'endpoints.dart';

class AlertView extends StatefulWidget {
  const AlertView({super.key});

  @override
  State<AlertView> createState() => _AlertViewState();
}

class _AlertViewState extends State<AlertView> {
  WebSocketChannel? _channel;
  BuildContext? _context;

  @override
  void initState() {
    super.initState();
    _channel = WebSocketChannel.connect(Uri.parse(baseUrl));
    _channel?.stream.listen((message) {
      _showAlert(message);
    });
  }

  void _showAlert(String message) {
    showDialog(
      context: _context!,
      builder: (context) => AlertDialog(
        title: Center(child: Text('ICE Incoming')),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _sendAlert() {
    _channel?.sink.add('alert');
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return Scaffold(
      body: Center(
        child: InkWell(
          onTap: _sendAlert,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                'Incoming',
                style: Theme.of(
                  context,
                ).textTheme.headlineLarge?.copyWith(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
