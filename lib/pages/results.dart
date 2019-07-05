import 'package:flutter/material.dart';
import 'package:images/pages/full_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ResultsPage extends StatefulWidget {
  final String _keyword;
  final List _results;

  ResultsPage(this._keyword, this._results);
  @override
  State<StatefulWidget> createState() {
    return _ResultsPageState();
  }
}

class _ResultsPageState extends State<ResultsPage> {
  Widget _searchResultsBuilder(BuildContext context, int index) {
    String imagePath = widget._results[index]['largeImageURL'];
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FullImagePage(imagePath)),
        );
      },
      child: Hero(
        tag: imagePath,
        child: FadeInImage.assetNetwork(
          fadeInCurve: Curves.easeInCubic,
          placeholder: 'images/loading.gif',
          image: imagePath,
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('search results for ${widget._keyword}'),
      ),
      body: StaggeredGridView.countBuilder(
        crossAxisCount: 4,
        staggeredTileBuilder: (int index) =>
            new StaggeredTile.count(2, index.isEven ? 2 : 1),
        itemBuilder: _searchResultsBuilder,
        itemCount: widget._results.length,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
    );
  }
}
