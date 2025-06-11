import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'endpoints.dart';

part 'alert.g.dart';

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
      final body = jsonDecode(message);
      _showAlert(Alert.fromJson(body));
    });
  }

  void _showAlert(Alert alert) {
    showDialog(
      context: _context!,
      builder: (context) => AlertDialog(
        title: Center(child: Text('ICE Incoming')),
        content: Text(alert.message ?? 'incoming'),
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
    log('Sending alert');
    _channel?.sink.add(Alert(message: 'incoming', location: 'test').toJson());
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

@JsonSerializable()
class Alert {
  final String? message;
  final String? location;

  Alert({this.message, this.location});

  factory Alert.fromJson(Map<String, dynamic> json) => _$AlertFromJson(json);
  Map<String, dynamic> toJson() => _$AlertToJson(this);
}
