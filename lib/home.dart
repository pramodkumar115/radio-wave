import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:orbit_radio/TopHits/top_hits_view.dart';
import 'package:velocity_x/velocity_x.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: VStack([
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // HStack([
          const GFAvatar(
            backgroundImage: AssetImage('assets/OrbitRadio.png'),
            shape: GFAvatarShape.square,
            backgroundColor: Color.fromRGBO(232, 237, 219, 0),
            foregroundColor: Color.fromRGBO(232, 237, 219, 0),
            size: 32,
          ),
          const Text("Orbit Radio")
              .text
              .color(Colors.red[900])
              .scale(1.5)
              .extraBold
              .make(),
          // ]),
          const Icon(Icons.search_rounded)
        ],
      ),
      const TopHitsView()
    ]).p12()));
  }
}
