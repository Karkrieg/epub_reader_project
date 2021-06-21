import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:io';
import 'package:epub_reader_project/BookModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:epub_view/epub_view.dart';

import 'main.dart';

Future<Uint8List> _loadEpubBook(String assetName) async {
  //final bytes = await rootBundle.load(assetName);
  //return bytes.buffer.asUint8List();
  final bytes = await File(assetName).readAsBytes();
  return bytes.buffer.asUint8List();
}

class BookReaderPage extends StatefulWidget {
  BookReaderPage({
    Key key,
    this.epubPath,
    this.lastCfi,
    this.listIndex,
  }) : super(key: key);

  final String epubPath;
  final String lastCfi;
  final int listIndex;

  @override
  _BookReaderPageState createState() => _BookReaderPageState();
}

class _BookReaderPageState extends State<BookReaderPage>
    with SingleTickerProviderStateMixin {
  EpubBookList lista_epub;
  List<EpubBook> epubList = <EpubBook>[];
  EpubController _epubController;
  TextStyle _defaultTextStyle = new TextStyle(fontSize: 12, height: 1.25);
  String _textColorString = 'Black';
  String _backgroundColorString = 'White';
  Color _textColor = Colors.black;
  Color _backgroundColor = Colors.white;
  bool isEmptyList = true;
  String epubPath;
  String lastCfi;
  int listIndex;
  bool empty = false;
  Bookmarks temp = new Bookmarks('temp', 'temp');
  List<Bookmarks> tempBookmarks;
  List<Bookmarks> bookmarks; // Zrobić też tę listę, co się sama ładuje...
  final myController = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Future<EpubBookList> loadInfo() async {
    String json = await readBooks();
    if (json != '' && json != '{"epubList":[]}') {
      lista_epub = new EpubBookList.fromJson(jsonDecode(json));
      for (int i = 0; i < lista_epub.epubList.length; i++) {
        if (lista_epub.epubList[i].path == this.epubPath) {
          listIndex = i;
        }
      }
      return lista_epub;
    } else
      return null;
  }

  //FUTURE BUILDER
  Widget bookmarksWidget() {
    return FutureBuilder(
      builder: (context, bookSnap) {
        final books = bookSnap.data;
        isEmptyList = bookSnap.data?.epubList?.contains('title') ?? true;

        switch (bookSnap.connectionState) {
          case ConnectionState.waiting:
            return Center(child: CircularProgressIndicator());
          default:
            if (bookSnap.hasError) {
              print("Wystąpił błąd.");
              return Center(child: Text('Error occurred!'));
            } else {
              return Padding(
                padding: EdgeInsets.only(top: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 10,
                          child: SizedBox(
                            height: 50,
                            width: 200,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 100),
                              child: TextField(
                                cursorHeight: 25,
                                controller: myController,
                                decoration: InputDecoration(
                                  labelText: 'Add new bookmark',
                                  border: OutlineInputBorder(),
                                ),
                                onSubmitted: (String name) async => {
                                  if (lista_epub.epubList[listIndex].bookmarks
                                          .toString() ==
                                      'null')
                                    {
                                      lista_epub.epubList[listIndex]
                                          .bookmarks[0] = temp,
                                    },
                                  if (name != '')
                                    {
                                      lista_epub.epubList[listIndex].bookmarks
                                          .add(Bookmarks(
                                              name,
                                              _epubController
                                                  .generateEpubCfi())),
                                      await writeBooks(lista_epub),
                                      Navigator.pop(context),
                                      lista_epub = await loadInfo(),
                                      showModalBottomSheet<void>(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return bookmarksWidget();
                                          }),
                                      myController.clear(),
                                    }
                                },
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: IconButton(
                            tooltip: 'Save bookmark',
                            icon: const Icon(
                              Icons.save,
                              color: Colors.blueGrey,
                            ),
                            onPressed: () async => {
                              if (myController.text != '')
                                {
                                  lista_epub.epubList[listIndex].bookmarks.add(
                                      Bookmarks(myController.text,
                                          _epubController.generateEpubCfi())),
                                  writeBooks(lista_epub),
                                  Navigator.pop(context),
                                  lista_epub = await loadInfo(),
                                  showModalBottomSheet<void>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return bookmarksWidget();
                                      }),
                                  myController.clear(),
                                }
                            },
                          ),
                        ),
                      ],
                    ),
                    buildList(books),
                  ],
                ),
              );
            }
        }
      },
      future: loadInfo(),
    );
  }

  Widget buildList(EpubBookList books) => isEmptyList == false
      ? Expanded(
          child: ListView.separated(
            addAutomaticKeepAlives: true,
            addRepaintBoundaries: true,
            addSemanticIndexes: true,
            shrinkWrap: true,
            padding: const EdgeInsets.all(20),
            itemCount: lista_epub.epubList[listIndex]?.bookmarks?.length ?? 0,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                children: [
                  TextButton(
                    onPressed: () => {
                      _epubController.gotoEpubCfi(
                          books.epubList[listIndex].bookmarks[index].cfi),
                      Navigator.pop(context),
                    },
                    child: Container(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          flex: 10,
                          child: Text(
                            books.epubList[listIndex].bookmarks[index].name,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: TextButton.icon(
                            onPressed: () async => {
                              books.epubList[listIndex].bookmarks
                                  .removeAt(index),
                              await writeBooks(books),
                              books = await loadInfo(),
                              Navigator.pop(context),
                              showModalBottomSheet<void>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return bookmarksWidget();
                                  }),
                            },
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            label: Text("DELETE",
                                style: TextStyle(color: Colors.red)),
                          ),
                        ),
                      ],
                    )),
                  ),
                ],
              );
            },
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(),
          ),
        )
      : Container();

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadInfo().whenComplete(() => {setState(() {})});
    setState(() {
      epubPath = widget.epubPath;
      lastCfi = widget.lastCfi;
      listIndex = widget.listIndex;
    });

    _loadConfiguration();
    if (epubPath != 'NONE') {
      _epubController = EpubController(
          document: EpubReader.readBook(_loadEpubBook(epubPath)),
          epubCfi: lastCfi);
      _epubController.gotoEpubCfi(lastCfi);
    } else {
      Navigator.pop(context);
    }
  }

  void resolveTextColor(String _textColorString) {
    switch (this._textColorString) {
      case 'Black':
        this._textColor = Colors.black;
        break;
      case 'White':
        this._textColor = Colors.white;
        break;
      case 'Red':
        this._textColor = Colors.red.shade800;
        break;
      case 'Green':
        this._textColor = Colors.green.shade800;
        break;
      case 'Blue':
        this._textColor = Colors.blue.shade800;
        break;
      default:
        this._textColor = Colors.black;
    }
  }

  void resolveBackgroundColor(String _backgroundColorString) {
    switch (this._backgroundColorString) {
      case 'Black':
        this._backgroundColor = Colors.black;
        break;
      case 'White':
        this._backgroundColor = Colors.white;
        break;
      case 'Red':
        this._backgroundColor = Colors.red.shade800;
        break;
      case 'Green':
        this._backgroundColor = Colors.green.shade800;
        break;
      case 'Blue':
        this._backgroundColor = Colors.blue.shade800;
        break;
      default:
        this._backgroundColor = Colors.black;
    }
  }

  void _loadConfiguration() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      this._backgroundColorString =
          (prefs.getString('backgroundColor') ?? 'White');
      this._textColorString = (prefs.getString('textColor') ?? 'Black');
      resolveTextColor(_textColorString);
      resolveBackgroundColor(_backgroundColorString);
      this._defaultTextStyle = new TextStyle(
        fontSize: prefs.getDouble('fontSize') ?? 15,
        fontFamily: prefs.getString('fontFamily' ?? 'Roboto'),
        fontWeight: FontWeight.normal,
        color: _textColor,
        backgroundColor: _backgroundColor,
        height: 1.25,
      );
    });
  }

  void _saveLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    final cfi = _epubController.generateEpubCfi();
    setState(() {
      prefs.setString('lastRead', this.epubPath);
      prefs.setString('lastCfi', cfi);
      print(this.epubPath);
      print(cfi);
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

  Widget _buildDivider(EpubChapter chap) {
    return Container(
      //height: double.minPositive,
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade900,
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        chap.Title ?? '',
        style: TextStyle(
          color: Colors.blueGrey.shade50,
          fontSize: this._defaultTextStyle.fontSize + 10,
          fontFamily: this._defaultTextStyle.fontFamily,
          height: 1.25,
        ),
      ),
    );
  }

  @override
  build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => {_saveLastRead(), Navigator.pop(context)},
        ),
        title: EpubActualChapter(
          controller: _epubController,
          builder: (chapterValue) => Text(
            '${chapterValue.chapter?.Title ?? ''}',
            textAlign: TextAlign.start,
          ),
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.menu),
              onPressed: () => {
                    _scaffoldKey.currentState.openEndDrawer(),
                  })
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Listener(
          onPointerDown: _onPointerDown,
          child: EpubView(
            controller: _epubController,
            textStyle: _defaultTextStyle,
            dividerBuilder: (value) => _buildDivider(value),
            //itemBuilder: (context,chapters,paragraphs,val) =>,
          ),
        ),
      ),
      endDrawer: Drawer(
        child: EpubReaderTableOfContents(
          controller: _epubController,
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
                'Narzędzia',
                textAlign: TextAlign.center,
              ),
            ),
            ListTile(
                title: Text(
                  'A+',
                  textAlign: TextAlign.center,
                ),
                onTap: () => {
                      setState(() {
                        if (_defaultTextStyle.fontSize != 50)
                          _defaultTextStyle = new TextStyle(
                            fontSize: _defaultTextStyle.fontSize + 1,
                            fontFamily: _defaultTextStyle.fontFamily,
                            fontWeight: FontWeight.normal,
                            color: _defaultTextStyle.color,
                            backgroundColor: _defaultTextStyle.backgroundColor,
                            height: 1.25,
                          );
                      }),
                    }),
            ListTile(
              title: Text(
                'A-',
                textAlign: TextAlign.center,
              ),
              onTap: () => {
                setState(() {
                  if (_defaultTextStyle.fontSize != 5)
                    _defaultTextStyle = new TextStyle(
                      fontSize: _defaultTextStyle.fontSize - 1,
                      fontWeight: FontWeight.normal,
                      fontFamily: _defaultTextStyle.fontFamily,
                      color: _defaultTextStyle.color,
                      backgroundColor: _defaultTextStyle.backgroundColor,
                      height: 1.25,
                    );
                }),
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Font Family: ',
                ),
                DropdownButton<String>(
                  value: this._defaultTextStyle.fontFamily,
                  items: <String>[
                    'Barlow',
                    'Roboto',
                    'Stint',
                    'Yanone-Kaffeesatz'
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String value) => {
                    setState(() {
                      this._defaultTextStyle = new TextStyle(
                        fontFamily: value,
                        fontSize: _defaultTextStyle.fontSize,
                        fontWeight: FontWeight.normal,
                        color: _textColor,
                        backgroundColor: _backgroundColor,
                        height: 1.25,
                      );
                    })
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Text Color: '),
                DropdownButton<String>(
                  value: _textColorString,
                  items: <String>['Black', 'White', 'Red', 'Green', 'Blue']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String value) => setState(() {
                    _textColorString = value;
                    resolveTextColor(_textColorString);
                    this._defaultTextStyle = new TextStyle(
                      fontFamily: _defaultTextStyle.fontFamily,
                      fontSize: _defaultTextStyle.fontSize,
                      fontWeight: FontWeight.normal,
                      color: _textColor,
                      backgroundColor: _defaultTextStyle.backgroundColor,
                      height: 1.25,
                    );
                  }),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Background Color: '),
                DropdownButton<String>(
                  value: _backgroundColorString,
                  items: <String>['Black', 'White', 'Red', 'Green', 'Blue']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String value) => setState(() {
                    _backgroundColorString = value;
                    resolveBackgroundColor(_backgroundColorString);
                    this._defaultTextStyle = new TextStyle(
                      fontFamily: _defaultTextStyle.fontFamily,
                      fontSize: _defaultTextStyle.fontSize,
                      fontWeight: FontWeight.normal,
                      color: _defaultTextStyle.color,
                      backgroundColor: _backgroundColor,
                      height: 1.25,
                    );
                  }),
                ),
              ],
            ),
            ListTile(
              title: Text(
                'Bookmarks',
                textAlign: TextAlign.center,
              ),
              onTap: () => {
                showModalBottomSheet<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return bookmarksWidget();
                    }),
              },
            ),
            ListTile(
              title: Text(
                'Save Progress',
                textAlign: TextAlign.center,
              ),
              onTap: () async => {
                lastCfi = _epubController.generateEpubCfi(),
                await loadInfo(),
                lista_epub.epubList[listIndex].lastCfi = lastCfi,
                await writeBooks(lista_epub),
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  backgroundColor: Colors.blueGrey,
                  content: Text(
                    'Progress saved!',
                    textAlign: TextAlign.center,
                  ),
                  behavior: SnackBarBehavior.floating,
                ))
              },
            ),
          ],
        ),
      ),
    );
  }
}
