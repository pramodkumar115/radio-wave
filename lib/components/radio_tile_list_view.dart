import 'package:animated_reorderable_list/animated_reorderable_list.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/getwidget.dart';
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
    return Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 5,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: !isReorderClicked
                ? [
                    GFButton(
                      color: Colors.black,
                      shape: GFButtonShape.pills,
                      onPressed: () {
                        setState(() {
                          isReorderClicked = true;
                        });
                      },
                      text: "Reorder list",
                    )
                  ]
                : [
                    GFButton(
                      color: Colors.black,
                      shape: GFButtonShape.pills,
                      onPressed: () {
                        setState(() {
                          isReorderClicked = false;
                        });
                      },
                      text: "Save",
                    ),
                    GFButton(
                      color: Colors.black,
                      shape: GFButtonShape.pills,
                      type: GFButtonType.outline,
                      onPressed: () {
                        setState(() {
                          isReorderClicked = false;
                        });
                      },
                      text: "Cancel",
                    )
                  ],
          ),
          Expanded(
              child: isReorderClicked ? getAnimatedReorderList() : getList())
        ]);
  }

  Widget getAnimatedReorderList() {
    return AnimatedReorderableGridView(
        items: radioList!,
        padding: EdgeInsets.all(0),
        longPressDraggable: true,
        sliverGridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1, childAspectRatio: 4.5),
        enterTransition: [SlideInDown()],
        exitTransition: [SlideInUp()],
        insertDuration: const Duration(milliseconds: 0),
        removeDuration: const Duration(milliseconds: 0),
        dragStartDelay: const Duration(milliseconds: 0),
        onReorder: (int oldIndex, int newIndex) {
          setState(() {
            final RadioStation station = radioList!.removeAt(oldIndex);
            radioList!.insert(newIndex, station);
          });
        },
        isSameItem: (a, b) => a.stationUuid == b.stationUuid,
        itemBuilder: (BuildContext context, int index) {
          var radio = radioList![index];
          return Material(
              key: Key("${radio.stationUuid}_${radioList?.indexOf(radio)}"),
              child: RadioTile(
                  key: Key("${radio.stationUuid}_${radioList?.indexOf(radio)}"),
                  radio: radio,
                  radioStations: radioList!,
                  from: 'FAVOURITES', isReorderClicked: true));
        });
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
