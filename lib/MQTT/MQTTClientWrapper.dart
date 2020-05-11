import 'package:flutter/cupertino.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

///First of all, you have to initialize on your main code, or wherever you want
///to use this class, the instance MQTTClientWrapper. Than you just have to pass
///all the parameters needed and be happy.

enum MqttCurrentConnectionState {
  //just to make debug easier
  IDLE,
  CONNECTING,
  CONNECTED,
  DISCONNECTED,
  ERROR_WHEN_CONNECTING
}
enum MqttSubscriptionState { IDLE, SUBSCRIBED } //just to make debug easier

///Create a Class to connect
class MQTTClientWrapper {
  //MQTTClientWrapper(this.onMessageReceived, this.onConnectedCallback);

  String broker = 'io.adafruit.com'; //Just change if you use another broker tcp
  int port = 1883; //By default, port = 1883. Change it if you need it
  String username = 'your_username'; //Here you have to put your Broker Username
  String passwd = 'your_passowrd'; // Broker Password
  String clientIdentifier = 'myAndroid'; //Can be whatever you want

  MqttServerClient client; //initialize MqttServerClient as client

  MqttCurrentConnectionState connectionState = MqttCurrentConnectionState.IDLE;
  MqttSubscriptionState subscriptionState = MqttSubscriptionState.IDLE;

  //final Function(String) onMessageReceived;
  //final VoidCallback onConnectedCallback;

  void _setupMqttClient() {
    //Setup the Server Client
    client = MqttServerClient.withPort(broker, clientIdentifier, port);
    client.logging(on: false);
    client.keepAlivePeriod = 20;
    client.onDisconnected = _onDisconnected;
    client.onConnected = _onConnected;
    client.onSubscribed = _onSubscribed;
    client.onUnsubscribed = _onUnsubscribed;
    client.pongCallback = _pong;

    final connMess = MqttConnectMessage()
        .withClientIdentifier(clientIdentifier)
        .keepAliveFor(20) // Must agree with the keep alive set above or not set
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atLeastOnce);
    print('MQTT_SERVER_CLIENT::Mosquitto client connecting....');
    client.connectionMessage = connMess;
  }

  Future<void> _connectClient() async {
    try {
      print('MQTTClientWrapper::Adafruit client connecting....');
      connectionState = MqttCurrentConnectionState.CONNECTING;
      await client.connect(
          username, passwd); //Connect the client to the server client
    } on Exception catch (e) {
      //Catch any exception
      print('MQTTClientWrapper::client exception - $e');
      connectionState = MqttCurrentConnectionState.ERROR_WHEN_CONNECTING;
      client.disconnect();
    }
    //Check if client is connected to the server client
    if (client.connectionStatus.state == MqttConnectionState.connected) {
      connectionState = MqttCurrentConnectionState.CONNECTED;
      print('MQTTClientWrapper::Adafruit client connected');
    } else {
      print(
          'MQTTClientWrapper::ERROR Adafruit client connection failed - disconnecting, status is ${client.connectionStatus}');
      connectionState = MqttCurrentConnectionState.ERROR_WHEN_CONNECTING;
      client.disconnect();
    }
  }

  void _subscribeToTopic(String topicName) {
    print('MQTTClientWrapper::Subscribing to the $topicName topic');
    client.subscribe(topicName, MqttQos.atMostOnce);

    ///Uncomment below if you need to listen to change notifications from server client
    /*client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload;
      final String pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      print(
          'MQTTClientWrapper::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
      print('');
    });*/
  }

  ///Important if you are working with multiple feeds
  void _unsubscribeToTopic(String topicName) {
    print('MQTTClientWrapper::Unsubscribing');
    try {
      client.unsubscribe(topicName);
    } catch (e) {
      print(
          'MQTTClientWrapper::ERROR:: Unable to unsubscribe, exception <-$e->');
    }
  }

  ///onConnected callback function
  void _onConnected() {
    connectionState = MqttCurrentConnectionState.CONNECTED;
    print(
        'MQTTClientWrapper::OnConnected client callback - Client connection was sucessful');
    //onConnectedCallback();
  }

  ///onDisconnected callback function
  void _onDisconnected() {
    print(
        'MQTTClientWrapper::OnDisconnected client callback - Client disconnection');
    if (client.connectionStatus.returnCode ==
        MqttConnectReturnCode.connectionAccepted) {
      print(
          'MQTTClientWrapper::OnDisconnected callback is solicited, this is correct');
    }
    connectionState = MqttCurrentConnectionState.DISCONNECTED;
  }

  ///onSubscribed callback function
  void _onSubscribed(String topic) {
    print('MQTTClientWrapper::Subscription confirmed for topic $topic');
    subscriptionState = MqttSubscriptionState.SUBSCRIBED;
  }

  ///onUnsubscribed callback function
  void _onUnsubscribed(String topic) {
    print('MQTTClientWrapper::Unsubscription confirmed for topic $topic');
    subscriptionState = MqttSubscriptionState.IDLE;
  }

  ///pong callback function
  void _pong() {
    print('MQTTClientWrapper::Ping response client callback invoked');
  }

  ///Not private function to setup and connect your client.
  void prepareMqttClient() async {
    _setupMqttClient();
    await _connectClient();
  }

  ///Not private function to subscribe to a topic, publish a message
  ///and unsubscribe to topic
  void publishMessage(String topic, String message) async {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);

    _subscribeToTopic(topic);

    print('MQTTClientWrapper::Publishing message $message to topic $topic');
    client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload);

    _unsubscribeToTopic(topic);
    //Wait for subscribe message from the broker
    await MqttUtilities.asyncSleep(2);
  }
}

///Function to be used in main code - Setup and connect to MQTT server client
void setup(MQTTClientWrapper mqttClientWrapper) {
  mqttClientWrapper.prepareMqttClient();
}

///Function to be used in main code - Publish a message on a topic
void publishMessage({
  @required String topic,
  @required String msg,
  @required mqttClientWrapper,
}) {
  mqttClientWrapper.publishMessage(topic, msg);
}
