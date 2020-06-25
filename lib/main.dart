import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:img_annotator/capture.dart';
import 'package:img_annotator/file_manager.dart';
import 'package:permission_handler/permission_handler.dart';

import 'utils.dart';

Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();
// Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  var status = await Permission.storage.status;
  if (status.isUndetermined) {
    // You can request multiple permissions at once.
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.camera,
    ].request();
    print(statuses[Permission
        .storage]); // it should print PermissionStatus.granted
  }
  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      title: 'Image Annotator',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Image Annotator'),
        ),
        body: HomePage(camera: cameras.first),
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
      child: Column(

        mainAxisAlignment: MainAxisAlignment.center,
        //crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClassicButton(Icons.camera, "Camera", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    TakePictureScreen(camera: this_camera),
              ),
            );
          }),
          SizedBox(height: 20),
          ClassicButton(Icons.folder_shared, "Export from", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    Fetch_File(),
              ),
            );
          }),
          SizedBox(height: 20),
          ClassicButton(Icons.label, "Labels", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    TakePictureScreen(camera: this_camera),
              ),
            );
          })
          , SizedBox(height: 20),
          ClassicButton(Icons.get_app, "Fetch Sources", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    Fetch_File(),
              ),
            );
          }
          )
        ],
      ),
    );
  }
}
