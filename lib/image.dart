import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

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
