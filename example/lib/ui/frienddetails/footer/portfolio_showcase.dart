import 'package:flutter/material.dart';
import 'dart:math';

class PortfolioShowcase extends StatelessWidget {
  List<Widget> _buildItems() {
    var items = <Widget>[];

    Random r = Random();

    for (var i = 1; i <= 6; i++) {
      var image = new Image.network("https://picsum.photos/200/200/?image=${r.nextInt(20)+10}");
      items.add(image);
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    var delegate = new SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      crossAxisSpacing: 8.0,
      mainAxisSpacing: 8.0,
    );

    return new GridView(
      padding: const EdgeInsets.only(top: 16.0),
      gridDelegate: delegate,
      children: _buildItems(),
    );
  }
}
