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

  EpubBookInfo(this.path, this.title, this.author);

  factory EpubBookInfo.fromJson(dynamic json) {
    return EpubBookInfo(json['path'] as String, json['title'] as String,
        json['author'] as String);
  }

  Map<String, dynamic> toJson() => {
        'path': path,
        'title': title,
        'author': author,
      };

  @override
  String toString() {
    return '{${this.path},${this.title},${this.author}}';
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
