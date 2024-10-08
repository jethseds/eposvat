import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(MyHome());

class MyHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera and Location Demo',
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatelessWidget {
  final permissionCamera = Permission.camera;
  final permissionLocation = Permission.location;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Camera and Location Demo'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () async {
                  final status = await permissionCamera.request();
                  if (status.isGranted) {
                    // Open the camera
                    print('Opening camera...');
                  } else {
                    // Permission denied
                    print('Camera permission denied.');
                  }
                },
                child: Text('Open Camera'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
