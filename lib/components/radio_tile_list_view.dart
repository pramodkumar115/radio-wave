import 'package:flutter/material.dart';
import 'package:orbit_radio/components/radio_tile.dart';
import 'package:orbit_radio/model/radio_station.dart';

class RadioTileListView extends StatefulWidget {
  const RadioTileListView({super.key, required this.radioStationList});
  final List<RadioStation>? radioStationList;

  @override
  State<RadioTileListView> createState() => _RadioTileListViewState();
}

class _RadioTileListViewState extends State<RadioTileListView> {
  List<RadioStation>? radioList = List.empty(growable: true);
  bool isReorderClicked = false;
  @override
  void initState() {
    super.initState();
    if (widget.radioStationList != null &&
        widget.radioStationList!.isNotEmpty) {
      radioList?.addAll(widget.radioStationList!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return getList();
  }
  Widget getList() {
    return ListView(
        children: radioList!
            .map((radio) => RadioTile(
                key: Key("${radio.stationUuid}_${radioList?.indexOf(radio)}"),
                radio: radio,
                radioStations: radioList!,
                from: 'FAVOURITES', isReorderClicked: false))
            .toList());
  }
}
