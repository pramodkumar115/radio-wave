import 'package:flutter/material.dart';

class MyPlayListListView extends StatefulWidget {
  const MyPlayListListView({super.key});

  @override
  State<MyPlayListListView> createState() => _FavouritesViewState();
}

class _FavouritesViewState extends State<MyPlayListListView> {
  @override
  Widget build(BuildContext context) {
    return Container(child: Center(child: Text("My PLaylist")));
  }
}