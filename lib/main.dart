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
import 'package:dropdown_search/dropdown_search.dart';

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
      navigateAfterSeconds: LanguageSelectionPage(),
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

class LanguageSelectionPage extends StatefulWidget {
  @override
  LanguageSelectionPageState createState() => new LanguageSelectionPageState();
}

class LanguageSelectionPageState extends State<LanguageSelectionPage> {
  List<String> languages = ['English', 'Hindi', 'Bangla', 'French', 'German'];
  String sourceLanguage = "";

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
            heightFactor: 0.4,
            alignment: Alignment.center,
            child: Column(
              children: [
                DropdownSearch<String>(
                  mode: Mode.MENU,
                  items: languages,
                  showSearchBox: true,
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Source Language",
                  ),
                  onChanged: (value) {
                    setState(() {
                      sourceLanguage = value;
                    });
                  },
                  selectedItem: "",
                ),
                SizedBox(
                  height: 20,
                ),
                DropdownSearch<String>(
                  mode: Mode.MENU,
                  items: languages,
                  showSearchBox: true,
                  enabled: sourceLanguage == "" ? false : true,
                  popupItemDisabled: (String s) => s == sourceLanguage,
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Target Language",
                  ),
                  onChanged: (value) {
                    Navigator.push(
                      this.context,
                      MaterialPageRoute(
                        builder: (context) => ImageSelectionPage(
                          sourceLanguage,
                          value,
                        ),
                      ),
                    );
                  },
                  selectedItem: "",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ImageSelectionPage extends StatefulWidget {
  final String sourceLanguage, targetLanguage;
  ImageSelectionPage(this.sourceLanguage, this.targetLanguage);

  @override
  ImageSelectionPageState createState() => new ImageSelectionPageState();
}

class ImageSelectionPageState extends State<ImageSelectionPage> {
  File _image;
  final picker = ImagePicker();

  Future getImage(String source) async {
    final pickedFile = await picker.getImage(
        source: source == 'camera' ? ImageSource.camera : ImageSource.gallery);

    setState(() {
      _image = File(pickedFile.path);
    });
  }

  Widget homeButton(String buttonText, BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        child: Text(
          buttonText,
          style: TextStyle(color: Colors.black),
        ),
        onPressed: () {
          buttonText == "📷 Take an Image"
              ? getImage('camera')
              : getImage('gallery');
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
                  homeButton("📷 Take an Image", context),
                  SizedBox(child: Text("OR")),
                  homeButton("🖼️ Upload an Image", context)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
