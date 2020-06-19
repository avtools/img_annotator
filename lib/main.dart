import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:img_annotator/capture.dart';

Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();
// Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      title: 'Image Annotator',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Welcome to Flutter'),

        ),
        body: Column(
          children: [ HomePage(camera: cameras.first)],
        ),
      ),
    ),
  );
}


class HomePage extends StatelessWidget {
  HomePage({CameraDescription camera}) : this.this_camera = camera;
  final CameraDescription this_camera;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[950],
      child: Center(
        child: Ink(
          decoration: const ShapeDecoration(
            color: Colors.lightBlue,
            shape: CircleBorder(),
          ),
          child: IconButton(
            icon: Icon(Icons.android),
            color: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TakePictureScreen(camera: this_camera),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}


//TakePictureScreen(
//// Pass the appropriate camera to the TakePictureScreen widget.
//camera: firstCamera,
//)

