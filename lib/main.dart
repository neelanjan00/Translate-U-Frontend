import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MyAppTheme());
  });
}

class MyAppTheme extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return (MaterialApp(
      title: "Translate U",
      theme: ThemeData(
        textTheme: Theme.of(context).textTheme.apply(
              fontFamily: 'PT Sans',
              bodyColor: Colors.black,
              displayColor: Colors.black,
            ),
      ),
      debugShowCheckedModeBanner: false,
      home: MyApp(),
    ));
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return (SplashScreen(
      seconds: 2,
      navigateAfterSeconds: HomePage(),
      title: Text(
        "Translate U",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 27.0),
      ),
      image: Image(
        image: AssetImage("assets/languages.png"),
      ),
      backgroundColor: Colors.blue[50],
      loaderColor: Colors.blue[50],
      photoSize: 100.0,
    ));
  }
}

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => new HomePageState();
}

class HomePageState extends State<HomePage> {
  File _image;
  final picker = ImagePicker();
  bool submitButtonVisible = false;
  bool predictedLabelTextVisible = false;
  bool isImagePosting = false;
  String predictedLabelText;

  Future getCameraImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    print(pickedFile.path);

    setState(() {
      _image = File(pickedFile.path);
      submitButtonVisible = true;
      predictedLabelTextVisible = false;
    });
  }

  Future getGalleryImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      _image = File(pickedFile.path);
      submitButtonVisible = true;
      predictedLabelTextVisible = false;
    });
  }

  Widget homeButton(String buttonText) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        child: Text(
          buttonText,
          style: TextStyle(color: Colors.black),
        ),
        onPressed: () {
          buttonText == "📷 Take an Image"
              ? getCameraImage()
              : getGalleryImage();
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.blue[100]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Translate U',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          alignment: Alignment.center,
          color: Colors.blue[50],
          child: FractionallySizedBox(
            widthFactor: 0.7,
            heightFactor: 0.15,
            alignment: Alignment.center,
            child: Container(
              child: Column(
                children: <Widget>[
                  homeButton("📷 Take an Image"),
                  Container(child: Text("OR")),
                  homeButton("🖼️ Upload an Image")
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
