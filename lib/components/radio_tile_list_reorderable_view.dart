import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:orbit_radio/model/radio_station.dart';

class RadioTileListReorderableView extends StatefulWidget {
  const RadioTileListReorderableView(
      {super.key,
      required this.radioStationList,
      required this.selectedRadios,
      required this.setSelectedRadios});
  final List<RadioStation>? radioStationList;
  final List<RadioStation> selectedRadios;
  final Function setSelectedRadios;

  @override
  State<RadioTileListReorderableView> createState() =>
      _RadioTileListReorderableViewState();
}

class _RadioTileListReorderableViewState
    extends State<RadioTileListReorderableView> {
  bool isReorderClicked = false;
  // List<RadioStation> stateSelectedRadios = List.empty(growable: true);

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final RadioStation item = widget.radioStationList!.removeAt(oldIndex);
      widget.radioStationList!.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    print("In = ${jsonEncode(widget.selectedRadios)}");
    return ReorderableListView.builder(
        itemCount: widget.radioStationList!.length,
        onReorder: _onReorder,
        buildDefaultDragHandles: false, // Disable default drag handles
        itemBuilder: (BuildContext context, int index) {
          final RadioStation radio = widget.radioStationList![index];
          return ReorderableDelayedDragStartListener(
              key: ValueKey(radio.name), // Unique key for each item
              index: index,
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
                key: Key(
                    "${radio.stationUuid}_${widget.radioStationList?.indexOf(radio)}"),
                avatar: GFAvatar(
                    child: Image.network(radio.favicon!,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset("assets/music.jpg"))),
                title: Text(radio.name!,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline)),
                description: Text(radio.country!),
                icon: Row(
                  children: [
                    Checkbox(
                        value: widget.selectedRadios
                            .where((e) => e.stationUuid == radio.stationUuid)
                            .isNotEmpty,
                        onChanged: (value) {
                          if (value == true) {
                            widget.selectedRadios.add(radio);
                          } else {
                            widget.selectedRadios.remove(radio);
                          }
                          widget.setSelectedRadios(widget.selectedRadios);
                        }),
                    ReorderableDragStartListener(
                      key: ValueKey<int>(
                          widget.radioStationList!.indexOf(radio)),
                      index: widget.radioStationList!.indexOf(radio),
                      child: const Icon(Icons.drag_indicator_outlined),
                    )
                  ],
                ),
              ));
        });
  }
}
