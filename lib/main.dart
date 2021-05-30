import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/src/widgets/image.dart' as Img;
import 'package:image/image.dart' as DImage;
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_windows/shared_preferences_windows.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:epubx/epubx.dart';

import 'book_reader.dart';
import 'fileReadWrite.dart';

/// Set minimal window size
Future setMinWindowSize() async {
  DesktopWindow.setMinWindowSize(Size(800, 600));
}

Future toggleFullScreen() async {
  DesktopWindow.toggleFullScreen();
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setMinWindowSize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Epub_Reader',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blueGrey,
      ),
      home: MyHomePage(title: 'Epub Reader Book Explorer'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List entries = [
    {
      'Cover': 'xxx',
      'Title': 'Genealogy of Morals',
      'Author': 'Frydrysz Nicze',
      'Path': 'C:/Users/NorbertSolecki/Downloads/genealogy-of-morals.epub'
    },
    {
      'Cover': 'xxx',
      'Title': 'Winnie',
      'Author': 'Author2',
      'Path': 'C:/Users/NorbertSolecki/Downloads/Winnie.epub'
    },
    {
      'Cover': 'xxx',
      'Title': 'Sindbad',
      'Author': 'Author3',
      'Path': 'C:/Users/NorbertSolecki/Downloads/sindbad.epub'
    }
  ];
  final List<int> colorCodes = <int>[100, 200, 300];
  EpubBook epubBook;
  String filePath = '';
  DImage.Image coverImage;
  List<EpubBook> epubList = <EpubBook>[];
  String test = '';

  Future getFilePath() async {
    final file = OpenFilePicker()
      ..filterSpecification = {'Epub Format': '*.epub', 'All Files': '*.*'}
      ..defaultExtension = 'epub'
      ..title = 'Select a book in epub format';

    final result = file.getFile();
    if (result != null) {
      setState(() {
        filePath = result.path;
      });
    } else
      return null;
  }

  void _tst() async {
    for (var book in entries) {
      await _loadBook(book['Path']).whenComplete(() => {
            test = '252525',
            setState(() {
              test = '252525252525';
            }),
            print(epubList[0].Title)
          });
      //setState(() {
      //  test = '222222';
      //});
    }
  }

  Future<EpubBook> _loadBook(String path) async {
    if (path != '' && path != null) {
      var targetFile = new File(path);
      final List<int> bytes = await targetFile.readAsBytes();
      final EpubBook testepubBook = await EpubReader.readBook(bytes);
      return testepubBook;
    } else {
      print('Error! File with path: $path not found!');
      return null;
    }
  }

  Future<List<EpubBook>> _allBooks() async {
    List<EpubBook> epubBooks = <EpubBook>[];
    for (var book in entries) {
      EpubBook temp = await _loadBook(book['Path']);
      epubBooks.add(temp);
    }
    return epubBooks;
  }

  @override
  void initState() {
    super.initState();
    getEpubDetails();
  }

  Future getEpubDetails() async {
    List<EpubBook> bookList = await _allBooks();
    epubList = bookList;
    return bookList;
  }

  ///CHRYSTE PANIE BOZE RATUJ
  Widget epubWidget() {
    return FutureBuilder(
      builder: (context, bookSnap) {
        if (bookSnap.connectionState == ConnectionState.none &&
            bookSnap.hasData == null) {
          return Container();
        }
        return ListView.builder(
          padding: EdgeInsets.all(15),
          itemCount: bookSnap.data.length,
          itemBuilder: (context, index) {
            EpubBook tempBook = bookSnap.data[index];
            return Container(
              height: 50,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(':('),
                      ), //Img.Image.memory(
                      //epubList[0].CoverImage.getBytes())),
                      Expanded(
                        child: Text('$tempBook.Title'),
                      ),
                      Expanded(
                        child: Text('$tempBook.Author'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
      future: _allBooks(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        automaticallyImplyLeading: false,
        //title: Text(widget.title),
        flexibleSpace: Center(
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                TextButton.icon(
                  style: TextButton.styleFrom(
                    primary: Colors.blueGrey.shade50,
                  ),
                  label: Text('Add new book',
                      softWrap: true, textAlign: TextAlign.center),
                  icon: const Icon(Icons.add_rounded, size: 50),
                  onPressed: () => {getFilePath(), print(filePath)},
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    primary: Colors.blueGrey.shade50,
                  ),
                  label: Text('Continue reading', textAlign: TextAlign.center),
                  icon: const Icon(Icons.arrow_right_alt_rounded, size: 50),
                  onPressed: () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookReaderPage(
                          epubPath:
                              'C:/Users/NorbertSolecki/Downloads/sindbad.epub',
                        ),
                      ),
                    ),
                  },
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    primary: Colors.blueGrey.shade50,
                  ),
                  label: Text('Settings', textAlign: TextAlign.center),
                  icon: const Icon(Icons.settings_rounded, size: 50),
                  onPressed: () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MainOptions(title: 'Settings')),
                    ),
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: Center(
        // Column is also a layout widget. It takes a list of children and
        //
        // Invoke "debug painting" (press "p" in the console, choose the
        // "Toggle Debug Paint" action from the Flutter Inspector in Android
        // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
        // to see the wireframe for each widget.
        //
        // Column has various properties to control how it sizes itself and
        // how it positions its children. Here we use mainAxisAlignment to
        // center the children vertically; the main axis here is the vertical
        // axis because Columns are vertical (the cross axis would be
        // horizontal).

        child: //epubWidget(),

            ListView.separated(
          padding: const EdgeInsets.all(8),
          itemCount: entries.length,
          itemBuilder: (BuildContext context, int index) {
            // _loadBook(entries[index]['Path']);
            return Column(
              children: [
                TextButton(
                  onPressed: () => {
                    print(entries[index]['Path']),
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BookReaderPage(
                                epubPath: entries[index]['Path'])))
                  },
                  child: Container(
                    height: 50,
                    color: Colors.blue[colorCodes[index]],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Icon(Icons.book),
                            ), //Img.Image.memory(
                            //epubList[0].CoverImage.getBytes())),
                            Expanded(
                              child: Text('${entries[index]['Title']}'),
                            ),
                            Expanded(
                              child: Text('${entries[index]['Author']}'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
          separatorBuilder: (BuildContext context, int index) =>
              const Divider(),
        ),
      ),
    );
  }
}

class MainOptions extends StatefulWidget {
  MainOptions({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MainOptionsState createState() => _MainOptionsState();
}

class _MainOptionsState extends State<MainOptions>
    with SingleTickerProviderStateMixin {
  TabController tabController;
  bool nightMode;
  double fontSize = 12;
  String fontFamily = 'Roboto';
  String backgroundColor = 'White';
  String textColor = 'Black';
  void toggleNightMode() => setState(() {
        nightMode = !nightMode;
      });

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    _loadConfiguration();
  }

  void _loadConfiguration() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      this.fontSize = (prefs.getDouble('fontSize') ?? 12);
      this.fontFamily = (prefs.getString('fontFamily') ?? 'Roboto');
      this.backgroundColor = (prefs.getString('backgroundColor') ?? 'White');
      this.textColor = (prefs.getString('textColor') ?? 'Black');
    });
  }

  void _saveConfiguration() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setDouble('fontSize', this.fontSize);
      prefs.setString('fontFamily', this.fontFamily);
      prefs.setString('backgroundColor', this.backgroundColor);
      prefs.setString('textColor', this.textColor);
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  Widget getOptions() {
    return TabBar(controller: tabController, tabs: [
      Tab(text: "Font", icon: const Icon(Icons.font_download_rounded)),
      Tab(text: "Colors", icon: const Icon(Icons.color_lens_rounded))
    ]);
  }

  Widget getOptionPages() {
    return TabBarView(
      controller: tabController,
      children: <Widget>[
        Center(
          child: Container(
            width: 315,
            child: Column(
              children: <Widget>[
                // Font Family Selection
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Font Family:',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    DropdownButton<String>(
                      value: fontFamily,
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
                          fontFamily = value;
                        })
                      },
                    ),
                  ],
                ),
                // Font size
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Font Size:',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    DropdownButton<double>(
                      value: fontSize,
                      items: <double>[
                        6,
                        7,
                        8,
                        9,
                        10,
                        11,
                        12,
                        14,
                        16,
                        18,
                        20,
                        24,
                        26,
                        28,
                        32
                      ].map<DropdownMenuItem<double>>((double value) {
                        return DropdownMenuItem<double>(
                          value: value,
                          child: Text(value.toString()),
                        );
                      }).toList(),
                      onChanged: (double value) => setState(() {
                        fontSize = value;
                      }),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: OutlinedButton(
                    child: Text('Save', style: TextStyle()),
                    onPressed: () => {
                      _saveConfiguration(),
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Settings Saved!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      ),
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        Center(
          child: Container(
            width: 315,
            child: Column(
              children: <Widget>[
                // Background Color Selection
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Background Color:',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    DropdownButton<String>(
                      value: backgroundColor,
                      items: <String>['White', 'Black', 'Red', 'Green', 'Blue']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String value) => setState(() {
                        backgroundColor = value;
                      }),
                    ),
                  ],
                ),
                // Text color
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Text Color:',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    DropdownButton<String>(
                      value: textColor,
                      items: <String>['Black', 'White', 'Red', 'Green', 'Blue']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String value) => setState(() {
                        textColor = value;
                      }),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: OutlinedButton(
                      child: Text('Save', style: TextStyle()),
                      onPressed: () => {
                            _saveConfiguration(),
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Settings Saved!'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            ),
                          }),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MyHomePage(),
              ),
            )
          },
        ),
        flexibleSpace: SafeArea(
          child: getOptions(),
        ),
      ),
      body: Center(
        child:
            Padding(padding: EdgeInsets.only(top: 50), child: getOptionPages()),
      ),
    );
  }
}
