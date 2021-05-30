import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:io';
import 'main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:epub_view/epub_view.dart';
import 'package:flutter/services.dart' show rootBundle;

Future<Uint8List> _loadEpubBook(String assetName) async {
  //final bytes = await rootBundle.load(assetName);
  //return bytes.buffer.asUint8List();
  final bytes = await File(assetName).readAsBytes();
  return bytes.buffer.asUint8List();
}

class BookReaderPage extends StatefulWidget {
  BookReaderPage({Key key, this.epubPath}) : super(key: key);

  final String epubPath;
  @override
  _BookReaderPageState createState() => _BookReaderPageState();
}

class _BookReaderPageState extends State<BookReaderPage>
    with SingleTickerProviderStateMixin {
  EpubController _epubController;
  TextStyle _defaultTextStyle = new TextStyle(fontSize: 12, height: 1.25);
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    String epubPath = widget.epubPath;
    _loadConfiguration();
    _epubController =
        EpubController(document: EpubReader.readBook(_loadEpubBook(epubPath)));
    super.initState();
  }

  void _loadConfiguration() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      this._defaultTextStyle = new TextStyle(
        fontSize: prefs.getDouble('fontSize') ?? 15,
      );
      // = (prefs.getInt('fontSize') ?? 12);
      //this.fontFamily = (prefs.getString('fontFamily') ?? 'Arial');
      // this.backgroundColor = (prefs.getString('backgroundColor') ?? 'White');
      // this.textColor = (prefs.getString('textColor') ?? 'Black');
    });
  }

  Future<void> _onPointerDown(PointerDownEvent event) async {
    // Check, if right mouse button was clicked
    if (event.kind == PointerDeviceKind.mouse &&
        event.buttons == kSecondaryMouseButton) {
      _scaffoldKey.currentState.openDrawer();
      //print("RMB CLICKED!");
      //final overlay =
      //Overlay.of(context).context.findRenderObject() as RenderBox;
      //final menuItem = await showMenu<int>(
      //  context: context,
      //  items: [
      //    PopupMenuItem
      //  ]
      // )
    }
  }

  @override
  build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        //title: EpubActualChapter(
        //  controller: _epubController,
        //  builder: (chapterValue) => Text(
        //'Chapter ${chapterValue.chapter.Title ?? ''}',
        //    textAlign: TextAlign.start,
        //  ),
        // ),
      ),
      body: Container(
        color: Colors.white,
        child: Listener(
          onPointerDown: _onPointerDown,
          child: EpubView(
            controller: _epubController,
            textStyle: _defaultTextStyle,
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.all(10),
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade100,
              ),
              child: Text(
                'Drawer',
                textAlign: TextAlign.center,
              ),
            ),
            ListTile(
                title: Text(
                  'A+',
                  textAlign: TextAlign.center,
                ),
                onTap: () => {}),
            ListTile(
              title: Text(
                'A-',
                textAlign: TextAlign.center,
              ),
              onTap: () => {},
            ),
            ListTile(
              title: Text(
                'Font Family',
                textAlign: TextAlign.center,
              ),
              onTap: () => {},
            ),
            ListTile(
              title: Text(
                'Text Color',
                textAlign: TextAlign.center,
              ),
              onTap: () => {},
            ),
            ListTile(
              title: Text(
                'Background Color',
                textAlign: TextAlign.center,
              ),
              onTap: () => {},
            ),
            ListTile(
              title: Text(
                'Bookmarks',
                textAlign: TextAlign.center,
              ),
              onTap: () => {},
            ),
          ],
        ),
      ),
    );
  }
}
