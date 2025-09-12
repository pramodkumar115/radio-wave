import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:orbit_radio/commons/shimmer.dart';
import 'package:orbit_radio/model/radio_station.dart';
import 'package:velocity_x/velocity_x.dart';

class RadioStationListView extends StatefulWidget {
  final List<RadioStation> stationList;
  const RadioStationListView({super.key, required this.stationList});

  @override
  State<RadioStationListView> createState() => _RadioStationListViewState();
}

class _RadioStationListViewState extends State<RadioStationListView> {
  @override
  Widget build(BuildContext context) {
    print("size: ${widget.stationList.length}");

    return SizedBox(
        height: 350,
        // scrollDirection: Axis.horizontal,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: widget.stationList
              .map((s) => Column(children: [
                    // GFCard(
                    //   boxFit: BoxFit.cover,
                    //   showImage: true,
                    //   image: Image.network(s.favicon!, width: 50, height: 50),
                    //   border: Border.all(width: 15, color: Colors.blueGrey),
                    //   // color: Colors.tealAccent[100],
                    //   // content: Text(s.name!),
                    // ),
                    // Center(
                    //     child: Text(
                    //   s.name!,
                    //   softWrap: true,
                    // ))
                    Card(
                        child: GridTile(
                            child: Image.network(s.favicon!,
                                loadingBuilder: (context, child,
                                        loadingProgress) =>
                                    (loadingProgress == null)
                                        ? child
                                        : const CircularProgressIndicator(),
                                errorBuilder: (context, error, stackTrace) =>
                                    Image.asset("assets/music.jpg",
                                        width: 10, height: 10),
                                width: 10,
                                height: 10).p24())).w24(context).h10(context)
                  ]))
              .toList(),
        ));
  }
}
