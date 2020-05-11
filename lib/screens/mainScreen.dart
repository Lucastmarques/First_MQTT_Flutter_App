import 'package:flutter/material.dart';
import 'package:iot_first_app/widgets/objectCardWidget.dart';
import '../MQTT/MQTTClientWrapper.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

List<String> topics = ['Slempty/feeds/L1', 'Slempty/feeds/L2'];

class _MyHomePageState extends State<MyHomePage> {
  String lamp1 = "0";
  String lamp2 = '0';
  MQTTClientWrapper mqttClientWrapper = MQTTClientWrapper();

  @override
  void initState() {
    super.initState();
    setup(mqttClientWrapper);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Primeiro app MQTT"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ObjectCard(
                name: "Lâmpada 1",
                icon: Icons.lightbulb_outline,
                topic: topics[0],
                mqttClientWrapper: mqttClientWrapper,
              ),
              ObjectCard(
                name: "Lâmpada 2",
                icon: Icons.lightbulb_outline,
                topic: topics[1],
                mqttClientWrapper: mqttClientWrapper,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
