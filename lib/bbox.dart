import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'file_manager.dart';
import 'persistance.dart';
class DrawPage extends StatefulWidget {
  final String imagePath;
  final TmpFile tempfile;
  final int index;

  const DrawPage({Key key, this.index, @required this.imagePath, this.tempfile})
      : super(key: key);

  @override
  _DrawPageState createState() => new _DrawPageState();
}

class _DrawPageState extends State<DrawPage> {
  GlobalKey _paintKey = new GlobalKey();
  Offset _start;
  Offset _end;
  ui.Image _image;
  List<List<Offset>> _listRect;

  @override
  void initState() {
    _listRect = [];
    _loadImage(widget.imagePath);
  }

  Location offsets_to_location(Offset start, Offset end) {
    double x = (start.dx + end.dx) * 0.5;
    double y = (start.dy + end.dy) * 0.5;
    double w = (end.dx - start.dx);
    double h = end.dy - start.dy;
    return Location(x, y, w, h);
  }

  void _startPan(DragStartDetails details) {
    RenderBox referenceBox = _paintKey.currentContext.findRenderObject();
    setState(() {
      _start = referenceBox.globalToLocal(details.globalPosition);
    });
  }

  void _updatePan(DragUpdateDetails details) {
    RenderBox referenceBox = _paintKey.currentContext.findRenderObject();
    setState(() {
      _end = referenceBox.globalToLocal(details.globalPosition);
    });
  }

  void _endPan(DragEndDetails details) {
    var x = [_start, _end, (_start + _end) / 2];

    var p_x = (2 * (_end.dx) - 410) / 410;
    var p_y = (2 * (_end.dy) - 640) / 640;
    //print("x : " + p_x.toString() + "y:" + p_y.toString());
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          Align(
            // alignment: Alignment.bottomRight,
              alignment: Alignment(
                  (2 * (_end.dx) - 410) / 410,
                  (2 * (_end.dy) - 640) / 640),
              child: Row( // A simplified version of dialog.
                  children: <Widget>[
                    Wrap(
                      children: <Widget>[
                        FlatButton(
                          child: Icon(Icons.done),
                          onPressed: () {
                            setState(() {
                              _listRect.add(x);
                            });
                            Navigator.pop(context);

                            widget.tempfile.labels.pictures[widget.index].tags
                                .add(this.offsets_to_location(_start, _end));
                          },
                        ),
                        FlatButton(
                            child: Icon(Icons.cancel),
                            onPressed: () {
                              setState(() {
                                _end = null;
                              });
                              Navigator.of(context).pop();
                            })
                      ],
                    )
                  ])),
    );
  }

  void _longPress(LongPressStartDetails details) {
    RenderBox referenceBox = _paintKey.currentContext.findRenderObject();

    var x = referenceBox.globalToLocal(details.globalPosition);
    print(x);
    var index = _findClosestBBox(x);
    setState(() {
      _start = _listRect[index][0];
      _end = null;
    });
    _listRect.removeAt(index);
  }

  void _longPressMove(LongPressMoveUpdateDetails details) {
    RenderBox referenceBox = _paintKey.currentContext.findRenderObject();

    _end = referenceBox.globalToLocal(details.globalPosition);
  }

  int _findClosestBBox(Offset x) {
    var min = (_listRect[0][2] - x).distanceSquared;
    var minimum = 0;
    for (int i = 0; i < _listRect.length; i++) {
      var temp = (_listRect[i][2] - x).distanceSquared;
      if (min > temp) {
        min = temp;
        minimum = i;
      }
    }
    return minimum;
  }


  _loadImage(String path) async {

    final Uint8List bytes = File(path).readAsBytesSync();
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.Image image = (await codec.getNextFrame()).image;
    setState(() => _image = image);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Label your image'),
        ),
        body:
        new GestureDetector(

          onPanStart: _startPan,
          onPanUpdate: _updatePan,
          onPanEnd: _endPan,
          onLongPressStart: _longPress,
          onLongPressMoveUpdate: _longPressMove,
          child: new CustomPaint(
            key: _paintKey,
            painter: new MyCustomPainter(_start, _end, _image, _listRect),
            child: new ConstrainedBox(
              constraints: new BoxConstraints.expand(),
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.arrow_back),
              title: Text('Previous'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.tag_faces),
              title: Text('Tags'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.arrow_forward),
              title: Text('Next'),
            ),

//            BottomNavigationBarItem(
//              icon: Icon(Icons.control_point),
//              title: Text('Keypoints'),
//            ),

          ],
        ));
  }
}

class MyCustomPainter extends CustomPainter {
  final Offset _start;
  final Offset _end;
  final List<List<Offset>> listRect;
  double scale;
  ui.Image _image;


  MyCustomPainter(this._start, this._end, this._image, this.listRect) :super();

  @override
  void paint(Canvas canvas, Size size) {
    this.scale = size.width / _image.width;
    canvas.scale(this.scale);
    if (_image != null) {
      canvas.drawImage(_image, new Offset(0.0, 0.0), new Paint());
    }
    drawExistingBBox(canvas);
    if (_end == null) return;
    drawCurrentBBox(_transform(_start), _transform(_end), canvas);
  }

  void drawExistingBBox(ui.Canvas canvas) {
    if (listRect.length != 0) {
      for (var i = 0; i < listRect.length; i++) {
        canvas.drawRect(
            Rect.fromPoints(
                _transform(listRect[i][0]), _transform(listRect[i][1])),
            new Paint()
              ..color = Colors.red
              ..style = PaintingStyle.stroke
              ..strokeWidth = (2 / this.scale));
      }
    }
  }

  void drawCurrentBBox(Offset x, Offset y, ui.Canvas canvas) {
    //print(x.toString() + "   " + y.toString());
    canvas.drawRect(
        Rect.fromPoints(x, y),
        new Paint()
          ..color = Colors.red
          ..style = PaintingStyle.stroke
          ..strokeWidth = (2 / scale));
  }

  Offset _transform(Offset x) {
    return x / scale;
  }

  @override
  bool shouldRepaint(MyCustomPainter other) => true; //other._end != _end;
}
