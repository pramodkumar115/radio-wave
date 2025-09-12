import 'package:flutter/cupertino.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Vx.hexToColor("#e8eddb"),
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
              const Text("Orbit Radio").text.color(Colors.red[900]).scale(1.5).extraBold.make(),
            // ]),
              const Icon(Icons.search_rounded)
            ],
          ),
          TopHitsView()
          // Center(
          //   child: Column(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: <Widget>[
          //         const Text("hello world").text.bold.scale(2).make(),
          //         GFButton(
          //           onPressed: () {},
          //           text: "Click Me",
          //           shape: GFButtonShape.pills,
          //           fullWidthButton: true,
          //           color: GFColors.PRIMARY, // GetWidget's color
          //         ).pOnly(left: 12, right: 12).box.roundedFull.make(),
          //       ]),
          // )
        ]).p12()));
  }
}
