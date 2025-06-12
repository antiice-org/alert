import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geolocator/geolocator.dart';
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
    if (Platform.isAndroid || Platform.isIOS) {
      _getPermissions();
    }
    _channel = WebSocketChannel.connect(Uri.parse(baseUrl));
    _channel?.stream.listen((message) {
      final body = jsonDecode(message);
      _showAlert(Alert.fromJson(body));
    });
  }

  void _getPermissions() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final _ = await Geolocator.requestPermission();
    }
  }

  void _showAlert(Alert alert) {
    showDialog(
      context: _context!,
      builder: (context) {
        final location = alert.location!.split(',');
        return AlertDialog(
          title: Center(child: Text('ICE Incoming')),
          content: SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            width: MediaQuery.of(context).size.width * 0.8,
            child: OSMFlutter(
              controller: MapController(
                initPosition: GeoPoint(
                  latitude: double.parse(location[0]),
                  longitude: double.parse(location[1]),
                ),
              ),
              osmOption: OSMOption(
                zoomOption: ZoomOption(initZoom: 17),
                userLocationMarker: UserLocationMaker(
                  personMarker: const MarkerIcon(
                    icon: Icon(
                      Icons.location_history_rounded,
                      color: Colors.red,
                      size: 48,
                    ),
                  ),
                  directionArrowMarker: const MarkerIcon(
                    icon: Icon(Icons.double_arrow, size: 48),
                  ),
                ),
              ),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _sendAlert() async {
    final location = await _getLocation();
    _channel?.sink.add(
      jsonEncode(Alert(message: 'incoming', location: location).toJson()),
    );
  }

  Future<String> _getLocation() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final location = await Geolocator.getCurrentPosition();
      return '${location.latitude},${location.longitude}';
    }
    return '0,0';
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
            decoration: BoxDecoration(color: Colors.red),
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
