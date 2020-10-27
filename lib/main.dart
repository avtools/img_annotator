import 'dart:async';

import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:img_annotator/capture.dart';
import 'package:img_annotator/file_manager.dart';
import 'package:permission_handler/permission_handler.dart';

import 'file_manager.dart';
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

class HomePage extends StatefulWidget {

  final CameraDescription this_camera;

  HomePage({CameraDescription camera}) : this.this_camera = camera;


  @override
  HomePageState createState() => new HomePageState();
}

class HomePageState extends State<HomePage> {
  Map<String, String> _paths = null;
  TmpFile tempFile = TmpFile();


  void openFileExplorer() async {
    try {
      _paths = await FilePicker.getMultiFilePath(
          type: FileType.image);
      this.tempFile.writePath(_paths);
      print(_paths);
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[950],
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [ Column(
            mainAxisAlignment: MainAxisAlignment.center,
            //crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClassicButton(Icons.camera, "Camera", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TakePictureScreen(camera: widget.this_camera),
                  ),
                );
              }),
              SizedBox(height: 20),
              ClassicButton(Icons.folder_shared, "Export from", () {
                openFileExplorer();
                //print(_paths);
              }),
              SizedBox(height: 20),
              ClassicButton(Icons.label, "Labelling", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        Fetch_File(tempfile: tempFile),
                  ),
                );
              })
            ],
          ),
          ]
      ),
    );
  }
}
