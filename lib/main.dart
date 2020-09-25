import 'dart:io';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
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
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Firebase ML Vision Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _image;
  final picker = ImagePicker();
  List<String> _labels = List();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      _image = File(pickedFile.path);
    });
    getText();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Container(
            child: _image != null
                ? Stack(
                    children: [
                      Center(
                        child: Image(
                          fit: BoxFit.cover,
                          height: double.infinity,
                          width: double.infinity,
                          alignment: Alignment.center,
                          image: FileImage(_image),
                        ),
                      ),
                      ListView.builder(
                          itemCount: _labels.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                              color: Colors.grey[100],
                              elevation: 4,
                              child: Text(
                                _labels[index],
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                            );
                          })
                    ],
                  )
                : Container(
                    child: Text("Tap to capture image."),
                  )),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Take Image',
        child: Icon(Icons.camera),
      ),
    );
  }

  Future getText() async {
    FirebaseVisionImage firebaseVisionImage =
        FirebaseVisionImage.fromFile(_image);
//    final TextRecognizer textRecognizer = FirebaseVision.instance.textRecognizer();
    final ImageLabeler labeler = FirebaseVision.instance.imageLabeler(
      ImageLabelerOptions(confidenceThreshold: 0.75),
    );
    final List<ImageLabel> labels =
        await labeler.processImage(firebaseVisionImage);
    for (ImageLabel label in labels) {
      print("${label.text}");
      _labels.add(label.text);
    }
    labeler.close();
  }
}
