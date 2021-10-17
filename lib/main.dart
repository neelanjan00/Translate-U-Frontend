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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
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
  final picker = ImagePicker();

  Future<File> getImage(String source) async {
    final pickedFile = await picker.getImage(
        source: source == 'camera' ? ImageSource.camera : ImageSource.gallery);

    return File(pickedFile.path);
  }

  Widget homeButton(String buttonText, BuildContext context,
      String sourceLanguage, String targetLanguage) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        child: Text(
          buttonText,
          style: TextStyle(color: Colors.black),
        ),
        onPressed: () {
          Future<File> image = buttonText == "📷 Take an Image"
              ? getImage('camera')
              : getImage('gallery');

          image.then(
            (value) => {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImagePreviewAndResultPage(
                      sourceLanguage, targetLanguage, value),
                ),
              ),
            },
          );
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
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  homeButton("📷 Take an Image", context, widget.sourceLanguage,
                      widget.targetLanguage),
                  SizedBox(child: Text("OR")),
                  homeButton("🖼️ Upload an Image", context,
                      widget.sourceLanguage, widget.targetLanguage)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ImagePreviewAndResultPage extends StatefulWidget {
  final String sourceLanguage, targetLanguage;
  final File image;
  ImagePreviewAndResultPage(
      this.sourceLanguage, this.targetLanguage, this.image);

  @override
  ImagePreviewAndResultPageState createState() =>
      new ImagePreviewAndResultPageState();
}

class ImagePreviewAndResultPageState extends State<ImagePreviewAndResultPage> {
  bool isImagePosting = false;
  bool isImageShowing = true;
  String translatedText;

  Widget buildProgressIndicator() {
    return (Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            "Please Wait",
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 15),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.pink[100]),
          ),
        ],
      ),
    ));
  }

  void translateImage(
      File image, String sourceLanguage, String targetLanguage) async {
    setState(() {
      isImagePosting = true;
      isImageShowing = false;
    });

    var stream = new http.ByteStream(Stream.castFrom(image.openRead()));
    var length = await image.length();
    var uri = Uri.parse("path/to/server/");

    var request = new http.MultipartRequest("POST", uri);
    var multipartFile = new http.MultipartFile(
      'InputImg',
      stream,
      length,
      filename: basename(image.path),
    );

    request.files.add(multipartFile);

    request.fields['sourceLanguage'] = sourceLanguage;

    request.fields['targetLanguage'] = targetLanguage;

    var response = await request.send();

    response.stream.transform(utf8.decoder).listen((value) {
      setState(() {
        isImagePosting = false;
        isImageShowing = true;
        translatedText = value;
      });
    });
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              FractionallySizedBox(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18.0),
                  child: Image.file(widget.image),
                ),
                widthFactor: 0.74,
              ),
              SizedBox(height: 30),
              translatedText != null
                  ? Text(
                      translatedText,
                      style: TextStyle(fontSize: 22),
                    )
                  : RaisedButton(
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 13),
                      child: Text(
                        "Submit",
                        style: TextStyle(color: Colors.white, fontSize: 17),
                      ),
                      color: Colors.blue[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      onPressed: () => translateImage(widget.image,
                          widget.sourceLanguage, widget.targetLanguage),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
