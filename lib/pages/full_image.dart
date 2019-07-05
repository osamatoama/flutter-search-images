import 'package:flutter/material.dart';

class FullImagePage extends StatelessWidget {
  final String imagePath;
  FullImagePage(this.imagePath);
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(),
        body: SizedBox.expand(
          child: Container(
            child: Hero(
              tag: imagePath,
              child: Image.network(
                imagePath,
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
