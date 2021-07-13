import 'dart:ffi';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OneSignal',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'OneSignal'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  SharedPreferences _prefs;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    setupPlatform();

  }

  void setupPlatform() async{
    _prefs  = await SharedPreferences.getInstance();

    if(!_prefs.containsKey("userId")){
      final externalId = await showTextInputDialog(
        context: context,
        textFields: const [
          DialogTextField(
            hintText: 'External ID',
          ),
        ],
        title: 'Welcome',
        message: 'Please provide an external ID to be used',
      );

      print("external id: ${externalId[0]}");

      //Remove this method to stop OneSignal Debugging
      await OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

//      await OneSignal.shared.setAppId("d12fadcb-6d29-4ede-b6c7-bca3c052b628");
      await OneSignal.shared.setAppId("0472af68-8547-400b-8405-4aa3ef4ac15f");

      await OneSignal.shared.consentGranted(true);

      await OneSignal.shared.setExternalUserId(externalId[0]).then((results) {
        if (results == null) return;

      });

      await OneSignal.shared.getDeviceState().then((deviceState) {
        print("User created details: ${deviceState?.jsonRepresentation()}");

        _prefs.setString("userId", deviceState.userId);

      });
    }


// The promptForPushNotificationsWithUserResponse function will show the iOS push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
    OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
      print("Accepted permission: $accepted");
    });

    OneSignal.shared.setNotificationWillShowInForegroundHandler((OSNotificationReceivedEvent event) {
      // Will be called whenever a notification is received in foreground
      // Display Notification, pass null param for not displaying the notification
      event.complete(event.notification);
    });

    OneSignal.shared.setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      // Will be called whenever a notification is opened/button pressed.
    });

    OneSignal.shared.setPermissionObserver((OSPermissionStateChanges changes) {
      // Will be called whenever the permission changes
      // (ie. user taps Allow on the permission prompt in iOS)
    });

    OneSignal.shared.setSubscriptionObserver((OSSubscriptionStateChanges changes) {
      // Will be called whenever the subscription changes
      // (ie. user gets registered with OneSignal and gets a user ID)
    });

    OneSignal.shared.setEmailSubscriptionObserver((OSEmailSubscriptionStateChanges emailChanges) {
      // Will be called whenever then user's email subscription changes
      // (ie. OneSignal.setEmail(email) is called and the user gets registered
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Just testing the onesignal push notification service',
            ),

          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
