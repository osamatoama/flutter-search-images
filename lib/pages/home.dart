import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:images/pages/results.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:toast/toast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

// todo:
// save all searchs
class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  TextEditingController _searchInputController = TextEditingController();
  bool _loading = false;
  void _stopLoading() {
    setState(() {
      _loading = false;
    });
  }

  void _startLoading() {
    setState(() {
      _loading = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("search photos"),
          centerTitle: true,
        ),
        body: ModalProgressHUD(
          inAsyncCall: _loading,
          child: Container(
            margin: EdgeInsets.only(right: 20, left: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'images/search.png',
                  width: 100,
                  height: 100,
                ),
                TextField(
                  controller: _searchInputController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (String keyword) async {
                    search();
                  },
                  decoration: InputDecoration(
                      labelText: 'looking for...',
                      hintText: 'e.g: cars, dogs, nature',
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                          borderRadius: BorderRadius.circular(20)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20))),
                ),
                SizedBox(height: 10),
                FutureBuilder(
                  future: getOldKeywords(),
                  builder: (ctx, snapShot) {
                    if (snapShot.hasData) {
                      List keywords = snapShot.data;
                      return Wrap(
                        crossAxisAlignment: WrapCrossAlignment.start,
                        children: keywords.map((keyword) {
                          return GestureDetector(
                            onTap: () {
                              _searchInputController.text = keyword;
                              search();
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 5),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(20)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    keyword,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  InkWell(
                                    child: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onTap: () {
                                      removeKeyword(keyword);
                                    },
                                  )
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }

                    return CircularProgressIndicator();
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void search() async {
    if (_searchInputController.text == null ||
        _searchInputController.text.isEmpty) {
      Toast.show("search keyword can't be null", context,
          duration: 5, gravity: Toast.TOP);
      return;
    }
    _startLoading();
    var data = await getPics(_searchInputController.text);
    if (data['hits'].isEmpty) {
      Toast.show(
          "No search results found for ${_searchInputController.text}", context,
          duration: 5, gravity: Toast.TOP);
      _stopLoading();
      return;
    }

    _startLoading();
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              ResultsPage(_searchInputController.text, data['hits'])),
    );
    _stopLoading();
    await saveKeyword(_searchInputController.text);
    setState(() {
      _searchInputController.text = '';
    });
  }
}

Future<Map> getPics(String q) async {
  final String url =
      'https://pixabay.com/api/?key=12872816-001a87bb2117c2dceca9e556c&q=$q&image_type=photo&pretty=true&per_page=150';
  http.Response response = await http.get(url);
  return json.decode(response.body);
}

Future<void> saveKeyword(String keyword) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> oldKeywords = prefs.getStringList('keywords') ?? new List();
  oldKeywords.add(keyword);
  prefs.setStringList('keywords', oldKeywords);
}

Future<List<String>> getOldKeywords() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> oldKeywords = prefs.getStringList('keywords') ?? new List();

  return oldKeywords;
}

Future<void> removeKeyword(keyword) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> oldKeywords = prefs.getStringList('keywords') ?? new List();

  oldKeywords.removeWhere((savedKeyword) {
    return savedKeyword == keyword;
  });
  prefs.setStringList('keywords', oldKeywords);
}
