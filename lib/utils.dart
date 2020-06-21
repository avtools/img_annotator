import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as IM;
import 'package:path_provider/path_provider.dart';
class AppUtil {
  static Future<String> createFolderInAppDocDir(String folderName) async {

    //Get this App Document Directory
    final Directory _appDocDir = await getExternalStorageDirectory();
    //App Document Directory + folder name
    final Directory _appDocDirFolder =
        Directory('${_appDocDir.path}/$folderName/');
    print(_appDocDirFolder);
    if (await _appDocDirFolder.exists()) {
      //if folder already exists return path
      return _appDocDirFolder.path;
    } else {
      //if folder not exists create folder and then return its path
      final Directory _appDocDirNewFolder =
          await _appDocDirFolder.create(recursive: true);
      return _appDocDirNewFolder.path;
    }
  }
}


class ClassicButton extends StatelessWidget {
  final String text;

  final IconData icon;
  final VoidCallback callback;

  ClassicButton(this.icon, this.text, this.callback);

  Widget build(BuildContext context) {
    return Ink(
      decoration: const ShapeDecoration(
        color: Colors.lightBlue,
        shape: StadiumBorder(),
      ),
      child: FlatButton(
        padding: EdgeInsets.all(15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[Icon(icon), SizedBox(width: 10), Text(text)],
        ),
        onPressed: callback,
      ),
    );
  }
}

Future<File> saveImage(String imagePath) async {
  try {
    var dir = await getExternalStorageDirectory();
    var testdir =
    await new Directory('${dir.path}').create(
        recursive: true);
    IM.Image image = IM.decodeImage(
        File(imagePath).readAsBytesSync());
    return new File(
        '${testdir.path}/${DateTime.now()
            .toUtc()
            .toIso8601String()}.png')
      ..writeAsBytesSync(IM.encodePng(image));
  } catch (e) {
    print(e);
    return null;
  }
}