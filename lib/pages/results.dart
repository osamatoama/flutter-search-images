import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class ResultsPage extends StatefulWidget {
  final String _keyword;
  final List _results;
  bool _loading = true;
  ResultsPage(this._keyword, this._results);
  @override
  State<StatefulWidget> createState() {
    return _ResultsPageState();
  }
}

class _ResultsPageState extends State<ResultsPage> {
  void _triggerLoading() {
    Future.delayed(Duration(seconds: 5), () {
      setState(() {
        widget._loading = false;
      });
    });
  }

  initState() {
    _triggerLoading();
    super.initState();
  }

  Widget _searchResultsBuilder(BuildContext context, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      child: Column(
        children: <Widget>[
          Image.network(
            "${widget._results[index]['largeImageURL']}",
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('search results for ${widget._keyword}'),
      ),
      body: widget._results.length == 0
          ? _emptyResults(context)
          : ModalProgressHUD(
              inAsyncCall: widget._loading,
              child: ListView.builder(
                itemBuilder: _searchResultsBuilder,
                itemCount: widget._results.length,
              )),
    );
  }

  Widget _emptyResults(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          "can't find search results for ${widget._keyword}",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 30),
        ),
        SizedBox(
          height: 20,
        ),
        InkWell(
          child: Text(
            "try again",
            style: TextStyle(color: Colors.blue),
          ),
          onTap: () {
            Navigator.pop(context);
          },
        )
      ],
    );
  }
}
