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
      home: MyHomePage(title: 'Image labeler'),
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
      body: Container(
          width: MediaQuery.of(context).size.width,
          height:MediaQuery.of(context).size.height ,
          decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.cover,
                image: _image != null
                    ? FileImage(_image)
                    : AssetImage("assets/white.jpeg")),
          ),
          child: _image != null
              ? Align(
                  alignment: Alignment.bottomLeft,
                  child: Wrap(
                    direction: Axis.horizontal,
                    spacing: 10.0, // gap between adjacent chips
                    runSpacing: 0.0,
                    children: [
                      for (int i = 0; i <_labels.length; i++)
                        Opacity(
                          opacity: 0.75,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(40),
                              ),
                            ),
                            color: Colors.grey[500],
                            elevation: 10,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(8.0,4,8,4),
                              child: Text(
                                _labels[i],
                                style:
                                    TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              : Container(
                  child: Center(child: Text("Tap to capture image.")),
                )),
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
