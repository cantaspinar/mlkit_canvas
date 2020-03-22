import 'dart:ui' as ui;
import 'dart:async';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mlkit_canvas/FacePainter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: FacePage(),
    );
  }
}

class FacePage extends StatefulWidget {
  @override
  _FacePageState createState() => _FacePageState();
}

class _FacePageState extends State<FacePage> {
  ui.Image _image;
  List<Face> _faces;
  bool _loading = false;

  void _getImageAndDetectFaces() async {
    try {
      final imageFile =
          await ImagePicker.pickImage(source: ImageSource.gallery);
      if (imageFile == null) {
        return;
      }
      setState(() {
        _loading = true;
      });
      final image = FirebaseVisionImage.fromFile(imageFile);
      final faceDetector = FirebaseVision.instance
          .faceDetector(FaceDetectorOptions(mode: FaceDetectorMode.accurate));
      _faces = await faceDetector.processImage(image);
      _image = await loadImage(imageFile.readAsBytesSync());
      setState(() {
        _loading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<ui.Image> loadImage(List<int> img) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(img, (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Face Painter"),
      ),
      body: Builder(builder: (context) {
        if (_image == null && !_loading) {
          return Container();
        }
        if (_loading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return Center(
          child: FittedBox(
            child: SizedBox(
              width: _image.width.toDouble(),
              height: _image.height.toDouble(),
              child: CustomPaint(
                painter: FacePainter(_image, _faces),
              ),
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: _getImageAndDetectFaces,
        tooltip: "Pick an image",
        child: Icon(Icons.add_a_photo),
      ),
    );
  }
}
