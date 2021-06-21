import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<File> get _localFile async {
  final path = await _localPath;
  return File('$path/booksInfo.json');
}

Future<File> writeBooks(EpubBookList list) async {
  final file = await _localFile;

  return file.writeAsString(jsonEncode(list.toJson()));
}

Future<String> readBooks() async {
  try {
    final file = await _localFile;

    final contents = await file.readAsString();

    return contents.toString();
  } catch (e) {
    return null;
  }
}

class EpubBookInfo {
  String path;
  String title;
  String author;
  String lastCfi;
  List<Bookmarks> bookmarks;

  EpubBookInfo(this.path, this.title, this.author,
      [this.lastCfi, this.bookmarks]);

  factory EpubBookInfo.fromJson(dynamic json) {
    if (json['bookmarks'] != null) {
      var tmp = json['bookmarks'] as List;
      List<Bookmarks> _bookmarks =
          tmp.map((bmjson) => Bookmarks.fromJson(bmjson)).toList();
      return EpubBookInfo(json['path'] as String, json['title'] as String,
          json['author'] as String, json['lastcfi'] as String, _bookmarks);
    } else {
      return EpubBookInfo(json['path'] as String, json['title'] as String,
          json['author'] as String, json['lastcfi'] as String);
    }
  }

  Map<String, dynamic> toJson() => {
        'path': path,
        'title': title,
        'author': author,
        'lastcfi': lastCfi,
        'bookmarks': this.bookmarks != null
            ? this.bookmarks.map((i) => i.toJson()).toList()
            : null,
      };

  @override
  String toString() {
    return '{${this.path},${this.title},${this.author},${this.lastCfi},${this.bookmarks}}';
  }
}

class Bookmarks {
  String name;
  String cfi;

  Bookmarks(this.name, this.cfi);

  factory Bookmarks.fromJson(dynamic json) {
    return Bookmarks(json['name'] as String, json['cfi'] as String);
  }

  Map<String, dynamic> toJson() => {'name': name, 'cfi': cfi};
  @override
  String toString() {
    return '{${this.name},${this.cfi}}';
  }
}

class EpubBookList {
  List<EpubBookInfo> epubList;

  EpubBookList([this.epubList]);

  factory EpubBookList.fromJson(dynamic json) {
    if (json['epubList'] != null) {
      var eBLObjsJson = json['epubList'] as List;
      List<EpubBookInfo> _books = eBLObjsJson
          .map((bookJson) => EpubBookInfo.fromJson(bookJson))
          .toList();

      return EpubBookList(
        _books,
      );
    } else {
      return EpubBookList(null);
    }
  }

  Map toJson() {
    List<Map> epubList = this.epubList != null
        ? this.epubList.map((i) => i.toJson()).toList()
        : null;

    return {'epubList': epubList};
  }

  @override
  String toString() {
    return '${this.epubList}';
  }
}
