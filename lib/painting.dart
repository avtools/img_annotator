import 'package:flutter/material.dart';

class DrawPage extends StatefulWidget {
  @override
  State createState() => new DrawPageState();
}

class DrawPageState extends State<DrawPage> {
  GlobalKey _paintKey = new GlobalKey();
  Offset _start;
  Offset _end;

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
            print([_start, _end]);
          });
        },
//        onPointerUp: (PointerUpEvent event) {
//          RenderBox referenceBox = _paintKey.currentContext.findRenderObject();
//          Offset offset = referenceBox.globalToLocal(event.position);
//          setState(() {
//            _offset = offset;
//            print(offset);
//          });
//        },
        child: new CustomPaint(
          key: _paintKey,
          painter: new MyCustomPainter(_start, _end),
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

  MyCustomPainter(this._start, this._end);

  @override
  void paint(Canvas canvas, Size size) {
    if (_end == null) return;
    //print([_start,_end]);
    canvas.drawRect(
        Rect.fromPoints(_start, _end), new Paint()..color = Colors.blue);
    canvas.drawCircle(_start, 10.0, new Paint()..color = Colors.blue);
  }

  @override
  bool shouldRepaint(MyCustomPainter other) => other._end != _end;
}
