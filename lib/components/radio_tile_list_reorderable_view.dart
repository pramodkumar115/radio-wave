import 'package:animated_reorderable_list/animated_reorderable_list.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/list_tile/gf_list_tile.dart';
import 'package:getwidget/getwidget.dart';
import 'package:orbit_radio/model/radio_station.dart';

class RadioTileListReorderableView extends StatefulWidget {
  const RadioTileListReorderableView(
      {super.key, required this.radioStationList});
  final List<RadioStation>? radioStationList;

  @override
  State<RadioTileListReorderableView> createState() =>
      _RadioTileListReorderableViewState();
}

class _RadioTileListReorderableViewState
    extends State<RadioTileListReorderableView> {
  //List<RadioStation>? radioList = List.empty(growable: true);
  bool isReorderClicked = false;
  @override
  void initState() {
    super.initState();
    // if (widget.radioStationList != null &&
    //     widget.radioStationList!.isNotEmpty) {
    //   radioList?.addAll(widget.radioStationList!);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedReorderableGridView(
      
        items: widget.radioStationList!,
        padding: EdgeInsets.all(0),
        longPressDraggable: true,
        sliverGridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1, childAspectRatio: 5.3),
        enterTransition: [SlideInDown()],
        exitTransition: [SlideInUp()],
        insertDuration: const Duration(milliseconds: 0),
        removeDuration: const Duration(milliseconds: 0),
        dragStartDelay: const Duration(milliseconds: 0),
        onReorder: (int oldIndex, int newIndex) {
          setState(() {
            final RadioStation station = widget.radioStationList!.removeAt(oldIndex);
            widget.radioStationList!.insert(newIndex, station);
          });
        },
        isSameItem: (a, b) => a.stationUuid == b.stationUuid,
        itemBuilder: (BuildContext context, int index) {
          var radio = widget.radioStationList![index];
          return Material(
            key: Key("${radio.stationUuid}_${widget.radioStationList?.indexOf(radio)}"),
            child: GFListTile(
              enabled: true,
              selected: true,
              color: Colors.grey.shade50,
              shadow: BoxShadow(
                  color: Colors.grey.shade400,
                  blurRadius: 1, // How blurry the shadow is
                  spreadRadius: 1,
                  offset: Offset(1, 1)),
              margin: EdgeInsets.all(4),
              key: Key("${radio.stationUuid}_${widget.radioStationList?.indexOf(radio)}"),
              avatar: GFAvatar(
                  child: Image.network(radio.favicon!,
                      errorBuilder: (context, error, stackTrace) =>
                          Image.asset("assets/music.jpg"))),
              title: Text(radio.name!,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline)),
              description: Text(radio.country!),
              icon: ReorderableDragStartListener(
                    key: ValueKey<int>(
                        widget.radioStationList!.indexOf(radio)),
                    index: widget.radioStationList!.indexOf(radio),
                    child: const Icon(Icons.drag_indicator_outlined),
                  ),
            ),
          );
        });
  }
}
