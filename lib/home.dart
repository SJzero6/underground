import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:underground/provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_sms/flutter_sms.dart';

class Under extends StatefulWidget {
  const Under({super.key});

  @override
  State<Under> createState() => _UnderState();
}

class _UnderState extends State<Under> {
  final platform = const MethodChannel('sendSms');

  late String lat;
  late String long;

  var locationMSG = '';

  String data = "jjjjjjjjj";
  bool hasSMSSent = false;

  @override
  void initState() {
    Mqttprovider mqttProvider =
        Provider.of<Mqttprovider>(context, listen: false);
    mqttProvider.newAWSConnect();
    super.initState();
  }

  Future sendSms() async {
    String messageContent =
        "Fault Detected\nLocation:latitude:$lat,longitude:$long ";

    try {
      final String result = await platform.invokeMethod('send',
          <String, dynamic>{"phone": "+919061166316", "msg": messageContent});
      print(result);
    } on PlatformException catch (e) {
      print(e.toString());
    }
  }

  void _liveLoc() {
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );
    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      lat = position.latitude.toString();
      long = position.longitude.toString();
      setState(() {
        locationMSG = 'latitude:$lat,longitude:$long';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Mqttprovider mqttprovider = Provider.of<Mqttprovider>(context);
    data = mqttprovider.mqttData;

    if (data == "jjjjjjjjj") {
      hasSMSSent = false;
    }

    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text(
              "CABLE FAULT DETECTION",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: FittedBox(
                child: Container(
                  // decoration: BoxDecoration(border: Border.all(width: 3)),
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  // color: Colors.amber,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buildCircularNode(id: 0),
                          buildLinearConnection(),
                          buildCircularNode(id: 1),
                          buildLinearConnection(),
                          buildCircularNode(id: 2),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buildCircularNode(id: 3),
                          buildLinearConnection(),
                          buildCircularNode(id: 4),
                          buildLinearConnection(),
                          buildCircularNode(id: 5),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buildCircularNode(id: 6),
                          buildLinearConnection(),
                          buildCircularNode(id: 7),
                          buildLinearConnection(),
                          buildCircularNode(id: 8),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container buildLinearConnection() {
    return Container(
      height: 10,
      width: 200,
      decoration: BoxDecoration(color: Colors.amber),
    );
  }

  Container buildCircularNode({required id}) {
    bool isBroken = data[id] == 'x';
    if (isBroken && !hasSMSSent) {
      Future(() => _getcurrentLocation()).then(
        (_) {
          sendSms();
          hasSMSSent = true;
        },
      );
    }
    return Container(
      height: 80,
      width: 80,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isBroken ? Colors.red : Colors.blue,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3),
            )
          ]),
      child: Center(
        child: Icon(isBroken ? Icons.power_off : Icons.power,
            color: Colors.white70, size: 30),
      ),
    );
  }

  Future _getcurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error("location service is not enabled");
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("location permission is denied");
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error("location permission is PERMENENTLY DENIED ");
    }

    var position = await Geolocator.getCurrentPosition();

    lat = position.latitude.toString();
    long = position.longitude.toString();

    return;
  }
}
