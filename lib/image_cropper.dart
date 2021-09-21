import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/customClipper.dart';
import 'package:image_cropper/customPainter.dart';
import 'dart:ui' as ui;
import 'package:screenshot/screenshot.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.imageFile}) : super(key: key);

  final File imageFile;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Offset> pointsList = [];
  bool cropImage = false;
  ScreenshotController screenshotController = ScreenshotController();
  late ui.Image image;
  bool isImageLoaded = false;
  int rotation = 0;

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
      return Center(
        child: RotatedBox(
          quarterTurns: rotation,
          child: FittedBox(
            child: SizedBox(
              height: image.height.toDouble(),
              width: image.width.toDouble(),
              child: cropImage
                  ? Screenshot(
                      controller: screenshotController,
                      child: ClipPath(
                        clipper: MyClipper(pointsList: pointsList),
                        child: Image.file(widget.imageFile),
                      ),
                    )
                  : CustomPaint(
                      painter: new MyImagePainter(
                          image: image,
                          pointsList: pointsList,
                          context: context,
                          height: MediaQuery.of(context).size.width.toInt(),
                          crop: cropImage),
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          Paint paint = Paint();
                          paint.color = Colors.red;
                          paint.strokeWidth = 20.0;
                          paint.strokeCap = StrokeCap.round;
                          Offset click = new Offset(details.localPosition.dx,
                              details.localPosition.dy);
                          setState(() {
                            if (click.dx > 0 &&
                                click.dx < image.width &&
                                click.dy > 0 &&
                                click.dy < image.height) {
                              pointsList.add(click);
                            }
                          });
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

  List<Widget> _iconDecider() {
    if (isImageLoaded && !cropImage)
      return [
        IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              setState(() {
                cropImage = true;
              });
              screenshotController.capture().then((Uint8List? imageList) async {
                if (imageList != null) {
                  String path = await FileSaver.instance
                      .saveAs('result image', imageList, 'png', MimeType.PNG);
                  log(path);
                }
              });
            })
      ];
    return [];
  }

  Widget rotate() {
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
        actions: _iconDecider(),
      ),
      body: _buildImage(),
      bottomNavigationBar: rotate(),
    );
  }
}
