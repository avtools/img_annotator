import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class DrawPage extends StatefulWidget {
  final String imagePath;

  const DrawPage({Key key,
    @required this.imagePath
  }) : super(key: key);

  @override
  _DrawPageState createState() => new _DrawPageState();
}

class _DrawPageState extends State<DrawPage> {
  GlobalKey _paintKey = new GlobalKey();
  Offset _start;
  Offset _end;
  ui.Image _image;

  @override
  void initState() {
    _loadImage(widget.imagePath);
  }

  _loadImage(String path) async {
    //ByteData bd = await rootBundle.load("assets/sampleImagees.jpg");
    //var listimage = File(path).readAsBytesSync();

    final Uint8List bytes = File(path).readAsBytesSync();

    final ui.Codec codec = await ui.instantiateImageCodec(bytes);

    final ui.Image image = (await codec.getNextFrame()).image;

    setState(() => _image = image);
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('CustomPaint example'),
      ),
      body: new Listener(
        onPointerDown: (PointerDownEvent event) {
          RenderBox referenceBox = _paintKey.currentContext.findRenderObject();
          Offset offset = referenceBox.globalToLocal(event.position);
          setState(() {
            _start = offset;
            //print(offset);
          });
        },
        onPointerMove: (PointerMoveEvent event) {
          RenderBox referenceBox = _paintKey.currentContext.findRenderObject();
          Offset offset = referenceBox.globalToLocal(event.position);
          setState(() {
            _end = offset;
          });
        },
//        onPointerUp: (PointerUpEvent event) {
//
//          showDialog(
//              context: context,
//              builder: (BuildContext context) {
//                return AlertDialog(
//                  title: Text("Accept?"),
//                  content: Text("Fix the bbox?"),
//                  actions: [
//                    FlatButton(child: Text("No")),
//                    FlatButton(child: Text("Yes"))
//                  ],
//                );
//              }
//          );
//        },
        child: new CustomPaint(
          key: _paintKey,
          painter: new MyCustomPainter(_start, _end, _image),
          child: new ConstrainedBox(
            constraints: new BoxConstraints.expand(),
          ),
        ),
      ),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  final Offset _start;
  final Offset _end;
  ui.Image _image;

  MyCustomPainter(this._start, this._end, this._image);

  @override
  void paint(Canvas canvas, Size size) {
    var scale = size.width / _image.width;
    canvas.scale(scale);
    canvas.drawImage(_image, new Offset(0.0, 0.0), new Paint());
    if (_end == null) return;
    print([_start, _end]);

    canvas.drawRect(
        Rect.fromPoints(_start / scale, _end / scale), new Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2);
    //canvas.drawCircle(_start, 10.0, new Paint()..color = Colors.blue..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(MyCustomPainter other) => other._end != _end;
}
