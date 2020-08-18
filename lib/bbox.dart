import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class DrawPage extends StatefulWidget {
  final String imagePath;

  const DrawPage({Key key, @required this.imagePath}) : super(key: key);

  @override
  _DrawPageState createState() => new _DrawPageState();
}

class _DrawPageState extends State<DrawPage> {
  GlobalKey _paintKey = new GlobalKey();
  Offset _start;
  Offset _end;
  ui.Image _image;
  List<List<Offset>> _list_rect;

  @override
  void initState() {
    _list_rect = [];
    _loadImage(widget.imagePath);
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
    var x = [_start, _end];

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
                            _list_rect.add(x);
                            Navigator.pop(context);
                          },
                        ),
                        FlatButton(
                            child: Icon(Icons.cancel),
                            onPressed: () {
                              Navigator.of(context).pop();
                            })
                      ],
                    )
                  ])),
    );
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
          title: new Text('Label your image'),
        ),
//  check gesture detector
//  onTap: (Offset offset, RenderBox getBox, TapDownDetails details) {
//    double dx;
//    double dy;
//    dx = offset.dx * _imageInfo.image.width;
//    dy = offset.dy * _imageInfo.image.height;
//    setState(() {
//    dragEnd(dx, dy);
//    })
//
        body:
        new GestureDetector(

          onPanStart: _startPan,
          onPanUpdate: _updatePan,
          onPanEnd: _endPan,
//        new Listener(
//
//          onPointerDown: (PointerDownEvent event) {
//            RenderBox referenceBox =
//            _paintKey.currentContext.findRenderObject();
//            Offset offset = referenceBox.globalToLocal(event.position);
//            setState(() {
//              _start = offset;
//              //print(offset);
//            });
//          },
//          onPointerMove: (PointerMoveEvent event) {
//            RenderBox referenceBox =
//            _paintKey.currentContext.findRenderObject();
//            Offset offset = referenceBox.globalToLocal(event.position);
//            setState(() {
//              _end = offset;
//            });
//          },
//          onPointerUp: (PointerUpEvent event) {
//            var x = [_start, _end];
//
//            var p_x = (2 * (_end.dx) - 410) / 410;
//            var p_y = (2 * (_end.dy) - 640) / 640;
//            //print("x : " + p_x.toString() + "y:" + p_y.toString());
//            showDialog(
//              context: context,
//              barrierDismissible: false,
//              builder: (BuildContext context) =>
//                  Align(
//                    // alignment: Alignment.bottomRight,
//                      alignment: Alignment(
//                          (2 * (_end.dx) - 410) / 410,
//                          (2 * (_end.dy) - 640) / 640),
//                      child: Row( // A simplified version of dialog.
//                          children: <Widget>[
//                            Wrap(
//                              children: <Widget>[
//                                FlatButton(
//                                  child: Icon(Icons.done),
//                                  onPressed: () {
//                                    _list_rect.add(x);
//                                    Navigator.pop(context);
//                                  },
//                                ),
//                                FlatButton(
//                                    child: Icon(Icons.cancel),
//                                    onPressed: () {
//                                      Navigator.of(context).pop();
//                                    })
//                              ],
//                            )
//                          ])),
//            );
//            RenderBox referenceBox =
//            _paintKey.currentContext.findRenderObject();
//            //Offset offset = referenceBox.globalToLocal(event.position);
//          },
          child: new CustomPaint(
            key: _paintKey,
            painter: new MyCustomPainter(_start, _end, _image, _list_rect),
            child: new ConstrainedBox(
              constraints: new BoxConstraints.expand(),
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.tag_faces),
              title: Text('Tags'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.control_point),
              title: Text('Keypoints'),
            ),
          ],
        ));
  }
}

class MyCustomPainter extends CustomPainter {
  final Offset _start;
  final Offset _end;
  final List<List<Offset>> list_rect;
  double scale;
  ui.Image _image;


  MyCustomPainter(this._start, this._end, this._image, this.list_rect) :super();

  @override
  void paint(Canvas canvas, Size size) {
    this.scale = size.width / _image.width;
    canvas.scale(this.scale);
    if (_image != null) {
      canvas.drawImage(_image, new Offset(0.0, 0.0), new Paint());
    }
    draw_existing_bbox(canvas);
    if (_end == null) return;
    draw_current_bbox(_transform(_start), _transform(_end), canvas);
    //print([_start, _end]);

    //canvas.drawCircle(_start, 10.0, new Paint()..color = Colors.blue..style = PaintingStyle.stroke);
  }

  void draw_existing_bbox(ui.Canvas canvas) {
    if (list_rect.length != 0) {
      for (var i = 0; i < list_rect.length; i++) {
        canvas.drawRect(
            Rect.fromPoints(
                _transform(list_rect[i][0]), _transform(list_rect[i][1])),
            new Paint()
              ..color = Colors.red
              ..style = PaintingStyle.stroke
              ..strokeWidth = (2 / this.scale));
      }
//    list_rect.map((i) => canvas.drawRect(
//        Rect.fromPoints(i[0] / scale, i[1] / scale), new Paint()
//      ..color = Colors.red
//      ..style = PaintingStyle.stroke
//      ..strokeWidth = (2/scale)));
    }
  }

  void draw_current_bbox(Offset x, Offset y, ui.Canvas canvas) {
    print(x.toString() + "   " + y.toString());
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
