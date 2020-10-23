import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:img_annotator/bbox.dart';
import 'package:path_provider/path_provider.dart';

class TmpFile {
  //for persisting data
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/store.txt');
  }

  Future<int> readCounter() async {
    try {
      final file = await _localFile;

      // Read the file
      String contents = await file.readAsString();

      return int.parse(contents);
    } catch (e) {
      // If encountering an error, return 0
      return 0;
    }
  }

  Future<File> writeCounter(int counter) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString('$counter');
  }
}

class Fetch_File extends StatefulWidget {
  final Map<String, String> paths;

  const Fetch_File({Key key,
    @required this.paths
  }) : super(key: key);

  @override
  _FilePickerState createState() => new _FilePickerState();
}

class _FilePickerState extends State<Fetch_File> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _fileName;
  String _path;
  bool _loadingPath = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          title: const Text('Select files to Label'),
        ),
        body: new Center(
            child: new Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: new SingleChildScrollView(
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[

                    new Builder(
                      builder: (BuildContext context) =>
                      _loadingPath
                          ? Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: const CircularProgressIndicator())
                          : _path != null || widget.paths != null
                          ? new Container(
                        padding: const EdgeInsets.only(bottom: 30.0),
                        height: MediaQuery
                            .of(context)
                            .size
                            .height * 0.70,
                        child: new Scrollbar(
                            child: new ListView.separated(

                              itemCount: widget.paths != null &&
                                  widget.paths.isNotEmpty
                                  ? widget.paths.length
                                  : 1,
                              itemBuilder: (BuildContext context, int index) {
                                final bool isMultiPath =
                                    widget.paths != null &&
                                        widget.paths.isNotEmpty;
                                final String name = 'File $index: ' +
                                    (isMultiPath
                                        ? widget.paths.keys.toList()[index]
                                        : _fileName ?? '...');
                                final path = isMultiPath
                                    ? widget.paths.values.toList()[index]
                                    .toString()
                                    : _path;

                                return new ListTile(
                                  title: new Text(
                                    name,
                                  ),
                                  subtitle: new Text(path),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                          //MyHomePage(imagePath: path)
                                          DrawPage(imagePath: path)
                                        //DisplayPictureScreen(
                                        //    imagePath: path),
                                      ),
                                    );
                                  },
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) =>
                              new Divider(),

                            )),
                      )
                          : new Container(),
                    ),
                  ],
                ),
              ),
            )),
      ),
    );
  }
}