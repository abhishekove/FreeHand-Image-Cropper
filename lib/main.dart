import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ImageChecker(),
    );
  }
}

class ImageChecker extends StatefulWidget {
  @override
  _ImageCheckerState createState() => _ImageCheckerState();
}

class _ImageCheckerState extends State<ImageChecker> {
  PickedFile? imageFile;
  bool isImageResized = false, isFirst = true;
  Uint8List? task;
  Future<PickedFile> loadImage(bool gallery) async {
    Navigator.of(context).pop();
    final Completer<PickedFile> completer = new Completer();
    if (gallery) {
      ImagePicker().pickImage(source: ImageSource.gallery).then((value) {
        setState(() {
          isImageResized = true;
          task = null;
        });
        return completer.complete(PickedFile(value!.path));
      });
    } else {
      ImagePicker().pickImage(source: ImageSource.camera).then((value) {
        setState(() {
          isImageResized = true;
          task = null;
        });
        return completer.complete(PickedFile(value!.path));
      });
    }
    return completer.future;
  }

  _resizeImage(bool gallery) async {
    imageFile = await loadImage(gallery);
  }

  Future<void> _alertChoiceDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Select Image"),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  GestureDetector(
                    child: Text("Gallery"),
                    onTap: () {
                      setState(() {
                        isFirst = false;
                        imageFile = null;
                        isImageResized = false;
                        _resizeImage(true);
                      });
                    },
                  ),
                  SizedBox(height: 20.0),
                  GestureDetector(
                    child: Text("Camera"),
                    onTap: () {
                      setState(() {
                        isFirst = false;
                        imageFile = null;
                        isImageResized = false;
                        _resizeImage(false);
                      });
                    },
                  )
                ],
              ),
            ),
          );
        });
  }

  Widget _imageDecider() {
    if (isFirst || imageFile == null) return Container();
    return images();
  }

  images() {
    if (!isImageResized || imageFile == null)
      return new Center(child: new Text('loading'));
    if (task == null) return (Image.file(File(imageFile!.path)));
    return Image.memory(task!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Parent Screen"),
        actions: [
          IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                _alertChoiceDialog(context);
              })
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height - 200,
                child: _imageDecider(),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (imageFile != null) {
                    final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MyHomePage(
                                  imageFile: File(imageFile!.path),
                                )));
                    setState(() {
                      task = result;
                    });
                  }
                },
                child: Text("Click to edit"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.imageFile}) : super(key: key);

  final File imageFile;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class DrawModel {
  Offset offset;
  Paint paint;

  DrawModel({required this.offset, required this.paint});
}

class _MyHomePageState extends State<MyHomePage> {
  List<DrawModel> pointsList = [];
  bool cropImage = false;
  bool edit = false;
  int touched = -1;
  late ui.Image image;
  bool isImageLoaded = false;
  int rotation = 0;
  _openCamera() async {
    List<Offset> list = await tp();
    Offset tl, tr, br, bl;
    setState(() {
      tl = list[0];
      tr = list[1];
      br = list[2];
      bl = list[3];
      Paint paint = Paint();
      paint.color = Colors.red;
      paint.strokeWidth = 20.0;
      paint.strokeCap = StrokeCap.round;
      pointsList.add(DrawModel(
        offset: tl,
        paint: paint,
      ));
      pointsList.add(DrawModel(
        offset: (tl + tr) / 2,
        paint: paint,
      ));
      pointsList.add(DrawModel(
        offset: tr,
        paint: paint,
      ));
      pointsList.add(DrawModel(
        offset: (tr + br) / 2,
        paint: paint,
      ));
      pointsList.add(DrawModel(
        offset: br,
        paint: paint,
      ));
      pointsList.add(DrawModel(
        offset: (br + bl) / 2,
        paint: paint,
      ));
      pointsList.add(DrawModel(
        offset: bl,
        paint: paint,
      ));
      pointsList.add(DrawModel(
        offset: (bl + tl) / 2,
        paint: paint,
      ));
    });
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<Null> init() async {
    image = await loadImage(File(widget.imageFile.path).readAsBytesSync());
  }

  tp() async {
    List<Offset> list = [];
    list.add(new Offset(10 * (image.height / MediaQuery.of(context).size.width),
        10 * (image.height / MediaQuery.of(context).size.width)));
    list.add(new Offset(
        image.width.toDouble() -
            (10 * (image.height / MediaQuery.of(context).size.width)),
        10 * (image.height / MediaQuery.of(context).size.width)));
    list.add(new Offset(
        image.width.toDouble() -
            (10 * (image.height / MediaQuery.of(context).size.width)),
        image.height.toDouble() -
            (10 * (image.height / MediaQuery.of(context).size.width))));
    list.add(new Offset(
        10 * (image.height / MediaQuery.of(context).size.width),
        image.height.toDouble() -
            (10 * (image.height / MediaQuery.of(context).size.width))));
    return list;
  }

  Widget _buildImage() {
    if (isImageLoaded) {
      // if (pointsList.length == 0) _openCamera();
      return Center(
        child: RotatedBox(
          quarterTurns: rotation,
          child: FittedBox(
            child: SizedBox(
              height: image.height.toDouble(),
              width: image.width.toDouble(),
              child: cropImage
                  ? ClipPath(
                      clipper: MyClipper(pointsList: pointsList),
                      child: Image.file(widget.imageFile),
                    )
                  : CustomPaint(
                      painter: new MyImagePainter(
                          image: image,
                          pointsList: pointsList,
                          context: context,
                          height: MediaQuery.of(context).size.width.toInt(),
                          crop: cropImage),
                      child: GestureDetector(
                        onPanStart: (details) {
                          touched = closestOffset(details.localPosition);
                        },
                        onPanUpdate: (details) {
                          
                          Paint paint = Paint();
                          paint.color = Colors.red;
                          paint.strokeWidth = 20.0;
                          paint.strokeCap = StrokeCap.round;
                          Offset click = new Offset(details.localPosition.dx,
                              details.localPosition.dy);
                              setState((){
                                if(click.dx>0 && click.dx<image.width && click.dy>0 && click.dy<image.height){
                            // pointsList.removeAt(touched);
                            pointsList.add( DrawModel(
                              offset: click,
                              paint: paint,
                            ));
                          }
                        
                              });
                        },
                        onPanEnd: (details) {
                          touched = -1;
                        },
                      ),
                    ),
            ),
          ),
        ),
      );
    } else {
      return new Center(child: new Text('loading'));
    }
  }

  int closestOffset(Offset click) {
    for (int i = 0; i < pointsList.length; i++) {
      if ((pointsList[i].offset - click).distance <
          (20.0 * (image.width.toDouble() / MediaQuery.of(context).size.width)))
        return i;
    }
    return -1;
  }

  Widget _iconDecider() {
    if (!edit) {
      setState(() {
        edit = true;
      });
    }
    return IconButton(
        icon: Icon(Icons.edit),
        onPressed: () async {
          setState(() {
            cropImage = true;
          });
        });
  }

  Widget zoomRotate() {
    return BottomAppBar(
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
              icon: Icon(Icons.rotate_left),
              onPressed: () async {
                setState(() {
                  rotation--;
                });
              }),
          IconButton(
              icon: Icon(Icons.rotate_right),
              onPressed: () async {
                setState(() {
                  rotation++;
                });
              }),
        ],
      ),
    );
  }

  Future<ui.Image> loadImage(Uint8List img) async {
    final Completer<ui.Image> completer = new Completer();
    ui.decodeImageFromList(img, (ui.Image img) {
      setState(() {
        isImageLoaded = true;
      });
      return completer.complete(img);
    });
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Doc Scanner"),
        actions: [_iconDecider()],
      ),
      body: _buildImage(),
      bottomNavigationBar: zoomRotate(),
    );
  }
}

class MyClipper extends CustomClipper<Path> {
  final List<DrawModel> pointsList;
  List<Offset> offsetList = [];

  MyClipper({required this.pointsList});
  @override
  Path getClip(Size size) {
    Path path = new Path();
    for (int i = 0; i < pointsList.length; i++) {
      offsetList.add(pointsList[i].offset);
    }
    if (offsetList.isNotEmpty) path.moveTo(offsetList[0].dx, offsetList[0].dy);
    for (int i = 1; i < offsetList.length; i++) {
      path.lineTo(offsetList[i].dx, offsetList[i].dy);
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    throw false;
  }
}

class MyImagePainter extends CustomPainter {
  ui.Image image;
  int height;
  final bool crop;
  final BuildContext context;
  MyImagePainter(
      {required this.image,
      required this.pointsList,
      required this.height,
      required this.crop,
      required this.context});
  final List<DrawModel> pointsList;
  double angle = 1.5686;
  List<Offset> offsetList = [];
  @override
  void paint(Canvas canvas, Size size) async {
    canvas.drawImage(image, new Offset(0.0, 0.0), new Paint());
    offsetList.clear();
    for (int i = 0; i < pointsList.length; i++) {
      offsetList.add(pointsList[i].offset);
    }
    if (pointsList.length > 0 && !crop) {
      canvas.drawPoints(
          PointMode.polygon,
          offsetList,
          Paint()
            ..strokeWidth = 3.0
            ..color = Colors.white
            ..strokeCap = StrokeCap.round);
      canvas.drawLine(
          offsetList[0],
          offsetList[offsetList.length - 1],
          Paint()
            ..strokeWidth = 3.0
            ..color = Colors.white
            ..strokeCap = StrokeCap.round);

      canvas.drawPoints(
          PointMode.points,
          offsetList,
          Paint()
            ..strokeWidth = 20 * (image.height / height)
            ..strokeCap = StrokeCap.round
            ..color = Colors.red);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
