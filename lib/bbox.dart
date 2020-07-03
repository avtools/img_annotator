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
  List <List <Offset>> _list_rect;

  @override
  void initState() {
    _list_rect = [];
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
        title: new Text('Label your image'),
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
        onPointerUp: (PointerUpEvent event) {
          var x = [_start, _end];
          _list_rect.add(x);
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
        },
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
          ],)
    );
  }
}

class MyCustomPainter extends CustomPainter {

  final Offset _start;
  final Offset _end;
  final List<List <Offset>> list_rect;
  double scale;
  ui.Image _image;

  MyCustomPainter(this._start, this._end, this._image, this.list_rect);

  @override
  void paint(Canvas canvas, Size size) {
    this.scale = size.width / _image.width;
    canvas.scale(this.scale);
    canvas.drawImage(_image, new Offset(0.0, 0.0), new Paint());
    draw_existing_bbox(canvas);
    if (_end == null) return;
    draw_current_bbox(_transform(_start), _transform(_end), canvas);
    //print([_start, _end]);

    //canvas.drawCircle(_start, 10.0, new Paint()..color = Colors.blue..style = PaintingStyle.stroke);
  }

  void draw_existing_bbox(ui.Canvas canvas) {
    print(list_rect.length);
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
    canvas.drawRect(Rect.fromPoints(x, y), new Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = (2 / scale));
  }

  Offset _transform(Offset x) {
    return x / scale;
  }
  @override
  bool shouldRepaint(MyCustomPainter other) => other._end != _end;
}
