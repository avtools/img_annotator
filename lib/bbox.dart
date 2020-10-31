import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'file_manager.dart';
import 'persistance.dart';
import 'utils.dart';
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
  Tag current;
  ui.Image _image;
  List<List<Offset>> _listRect;
  List<DropdownChoices> dropdownChoices;

  @override
  void initState() {
    widget.tempfile.readPath();
    _listRect = [];
    current = Tag("default", 0x000000ff);
    current.location = List<Location>();
    _loadImage(widget.imagePath);
  }

  Location offsets_to_location(Offset start, Offset end) {
    double x = (start.dx + end.dx) * 0.5;
    double y = (start.dy + end.dy) * 0.5;
    double w = (end.dx - start.dx).abs();
    double h = (end.dy - start.dy).abs();
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
                              //current.location.add(
                              //    this.offsets_to_location(_start, _end));
                              widget.tempfile.labels.pictures[widget.index]
                                  .tags[current.name].location.add(
                                  this.offsets_to_location(_start, _end));

                            });
                            Navigator.pop(context);


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

  List<DropdownChoices> userdropdownchoices = <DropdownChoices>[
    DropdownChoices(title: 'Add new', color: 0x000000ff),

  ];

  void onTabTapped(int Index) {
    print(Index);
  }

  void addTag(value) {
    int color = Random().nextInt(0xaaaaaaaa);
    DropdownChoices newtag = DropdownChoices(title: value, color: color);
    widget.tempfile.labels.pictures[widget.index].tags[value] =
        Tag(value, color);
    userdropdownchoices.add(newtag);
  }

  void setCurrent(DropdownChoices) {
    print(DropdownChoices.title);
    setState(() {
      current.name = DropdownChoices.title;
      current.color = DropdownChoices.color;
    });
  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: RichText(
            text: TextSpan(
                text: widget.tempfile.labels.pictures[widget.index].filename,
                //+ title,
                style: TextStyle(
                  fontSize: 15.0,
                  color: Colors.white,
                ),
                children: [
                  TextSpan(text: '\n'),
                  TextSpan(
                    text: (widget.index + 1).toString() + "/" +
                        widget.tempfile.labels.pictures.length.toString(),
                    style: TextStyle(
                      fontSize: 10.0,
                      color: Colors.white,
                    ),
                  ),
                ]),
            textAlign: TextAlign.center,
          ),
          centerTitle: true,
          actions: <Widget>[
            PopupMenuButton<DropdownChoices>(
              itemBuilder: (BuildContext context) {
                return userdropdownchoices.map((DropdownChoices choice) {
                  if (choice.title == 'Add new') {
                    return PopupMenuItem<DropdownChoices>(
                      value: choice,
                      child: TextField(decoration: InputDecoration(
                          prefixIcon: Icon(Icons.add_circle),
                          labelText: "Add Tag",
                          border: InputBorder.none
                      ),
                        onSubmitted: addTag,
                      ),
                    );
                  }
                  else {
                    return PopupMenuItem<DropdownChoices>(
                        value: choice,
                        child: Container(
                            color: this.current.name == choice.title
                                ? Colors.blue
                                : Colors.white,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50.0),
                            child: Row(
                                children: <Widget>[
                                  Icon(Icons.label, color: MaterialColor(
                                      choice.color,
                                      getSwatch(Color(choice.color))),), Text(
                                    choice.title,
                                    style: new TextStyle(color: Colors.black),
                                  )
                                ]
                            )
                        )
                    );
                  }
                }).toList();
              },
              onSelected: setCurrent,
            ),
          ],
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
            painter: new MyCustomPainter(
                _start,
                _end,
                _image,
                _listRect,
                current,
                widget.tempfile,
                widget.index),
            child: new ConstrainedBox(
              constraints: new BoxConstraints.expand(),
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          onTap: onTabTapped,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.arrow_back),
              title: Text('Previous'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.tag_faces),
              title: Text("current Tag"),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.arrow_forward),
              title: Text('Next'),
            ),
          ],
        ));
  }
}

class MyCustomPainter extends CustomPainter {
  final Offset _start;
  Offset _end;
  final List<List<Offset>> listRect;
  double scale;
  Tag current;
  ui.Image _image;
  TmpFile tempfile;
  int index;


  MyCustomPainter(this._start, this._end, this._image, this.listRect,
      this.current, this.tempfile, this.index) :super();

  @override
  void paint(Canvas canvas, Size size) {
    this.scale = size.width / _image.width;
    canvas.scale(this.scale);
    if (_image != null) {
      canvas.drawImage(_image, new Offset(0.0, 0.0), new Paint());
    }
    drawCurrentBBox(_transform(_start), _transform(_end), canvas);
    if (_end == null) return;

    drawExistingBBox(canvas);

    _end == null;


  }

  void drawExistingBBox(ui.Canvas canvas) {
    Map<String, Tag> tags = tempfile.labels.pictures[index].tags;
    tags.forEach((key, value) {
      if (value.location != []) {
        value.location.forEach((element) {
          List<Offset> limits = location_to_offset(element);
        canvas.drawRect(
            Rect.fromPoints(
                _transform(limits[0]), _transform(limits[1])),
            new Paint()
              ..color = MaterialColor(
                  value.color, getSwatch(Color(value.color)))
              ..style = PaintingStyle.stroke
              ..strokeWidth = (2 / this.scale));
        });
      }
    });

  }

  void drawCurrentBBox(Offset x, Offset y, ui.Canvas canvas) {
    //print(x.toString() + "   " + y.toString());
    canvas.drawRect(
        Rect.fromPoints(x, y),
        new Paint()
          ..color = MaterialColor(
              current.color, getSwatch(Color(current.color)))
          ..style = PaintingStyle.stroke
          ..strokeWidth = (2 / scale));
  }

  Offset _transform(Offset x) {
    return x / scale;
  }

  List<Offset> location_to_offset(Location L) {
    Offset start = Offset((L.x - (L.w * 0.5)), (L.y - (L.h * 0.5)));
    Offset end = Offset((L.x + (L.w * 0.5)), (L.y + (L.h * 0.5)));
    return [start, end];
  }
  @override
  bool shouldRepaint(MyCustomPainter other) => true; //other._end != _end;
}

