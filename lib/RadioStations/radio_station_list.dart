import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:orbit_radio/RadioPlayer/radio_player_view.dart';
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
              .map((s) => GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      isDismissible: true,
                      scrollControlDisabledMaxHeightRatio: 1,
                      builder: (BuildContext context) {
                        return RadioPlayerView(
                            radioStationsList: widget.stationList, selectedRadioId: s.stationUuid!);
                      },
                    );
                  },
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Card(
                            margin: const EdgeInsets.all(8),
                            color: Colors.white,
                            elevation: 4,
                            child: Container(
                                    padding: const EdgeInsets.all(24),
                                    child: Image.network(
                                      s.favicon!,
                                      height: 100,
                                      width: 200,
                                      loadingBuilder: (context, child,
                                              loadingProgress) =>
                                          (loadingProgress == null)
                                              ? child
                                              : const CircularProgressIndicator(),
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Image.asset("assets/music.jpg",
                                                  width: 75, height: 75),
                                    ).w15(context).h10(context))
                                .w32(context)
                                .h15(context)),
                        Text("${s.name!}", softWrap: true)
                            .text
                            .semiBold
                            .align(TextAlign.center)
                            .make()
                            .w32(context),
                        Text("(${s.country})", softWrap: true)
                            .text
                            .semiBold
                            .align(TextAlign.center)
                            .make()
                            .w32(context),
                      ])))
              .toList(),
        ));
  }
}
