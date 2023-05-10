import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "package:mqtt_client/mqtt_client.dart";
import 'package:mqtt_client/mqtt_server_client.dart';

class Mqttprovider with ChangeNotifier {
  static const url = 'a3ic1k7itt4ynl-ats.iot.ap-northeast-1.amazonaws.com';

  static const port = 8883;

  static const clientid = 'under';

  final client = MqttServerClient.withPort(url, clientid, port);
  var _data = "jjjjjjjjj";

  set mqttData(String data) {
    _data = json.decode(data)['fault_string'] ?? "jjjjjjjjj";
    notifyListeners();
  }

  String get mqttData => _data;

  newAWSConnect() async {
    client.secure = true;

    client.keepAlivePeriod = 20;

    client.setProtocolV311();

    client.logging(on: true);

    final context = SecurityContext.defaultContext;

    ByteData crctdata =
        await rootBundle.load('assets/certi/Device_cable_certificate.pem.crt');
    context.useCertificateChainBytes(crctdata.buffer.asUint8List());

    ByteData authorities =
        await rootBundle.load('assets/certi/AmazonRootCA1 _cable.pem');
    context.setClientAuthoritiesBytes(authorities.buffer.asUint8List());

    ByteData keybyte =
        await rootBundle.load('assets/certi/cable-private.pem.key');
    context.usePrivateKeyBytes(keybyte.buffer.asUint8List());
    client.securityContext = context;

    final mess =
        MqttConnectMessage().withClientIdentifier('under').startClean();
    client.connectionMessage = mess;

    try {
      print('MQTT client is connecting to AWS');
      await client.connect();
    } on Exception catch (e) {
      print('MQTT client exception - $e');
      client.disconnect();
    }
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('AWS iot connection succesfully done');

      const topic = 'esp8266/pub';
      // final maker = MqttClientPayloadBuilder();
      // maker.addString('mommu');

      // client.publishMessage(topic, MqttQos.atLeastOnce, maker.payload!);

      client.subscribe(topic, MqttQos.atLeastOnce);
      client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final rcvmsg = c[0].payload as MqttPublishMessage;
        final pt =
            MqttPublishPayload.bytesToStringAsString(rcvmsg.payload.message);
        print(
            'Example::Change notification:: topic is<${c[0].topic}>, payload is <--$pt-->');
        mqttData = pt;
        print('helloworld$pt');
      });
    } else {
      print(
          'ERROR MQTT client connection failed - disconnecting, state is ${client.connectionStatus!.state}');
      client.disconnect();
    }

    return 0;
  }
}
