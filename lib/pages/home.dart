import 'dart:convert';

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
  void _triggerLoading(bool loading) {
    setState(() {
      _loading = loading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                onSubmitted: (String value) async {
                  if (_searchInputController.text == null ||
                      _searchInputController.text.isEmpty) {
                    Toast.show("search keyword can't be null", context,
                        duration: 5, gravity: Toast.TOP);
                    return;
                  }
                  _triggerLoading(true);
                  var data = await getPics(_searchInputController.text);
                  _triggerLoading(false);
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ResultsPage(
                            _searchInputController.text, data['hits'])),
                  );

                  setState(() {
                    _searchInputController.text = '';
                  });
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
            ],
          ),
        ),
      ),
    );
  }
}

Future getPics(String q) async {
  final String url =
      'https://pixabay.com/api/?key=12872816-001a87bb2117c2dceca9e556c&q=$q&image_type=photo&pretty=true';
  http.Response response = await http.get(url);
  return json.decode(response.body);
}
