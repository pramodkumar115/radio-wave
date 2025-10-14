import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:getwidget/getwidget.dart';
import 'package:orbit_radio/Notifiers/favorites_state_notifier.dart';
import 'package:orbit_radio/commons/util.dart';
import 'package:orbit_radio/components/radio_tile_list_reorderable_view.dart';
import 'package:orbit_radio/components/radio_tile_list_view.dart';

class FavouritesView extends ConsumerStatefulWidget {
  const FavouritesView({super.key});

  @override
  ConsumerState<FavouritesView> createState() => _FavouritesViewState();
}

class _FavouritesViewState extends ConsumerState<FavouritesView> {
  bool isReorderClicked = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var favoritesData = ref.watch(favoritesDataProvider);
    return favoritesData.when(
        data: (favIds) {
          return showContent(favIds);
        },
        error: (error, stackTrace) => showContent(List.empty()),
        loading: () => CircularProgressIndicator());
  }

  Widget showContent(List<String> favIds) {
    return Container(
        margin: const EdgeInsets.only(top: 50),
        padding: EdgeInsets.all(10),
        child: FutureBuilder(
            future: getStationsListForUUIDs(favIds),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var radioList = snapshot.data;
                return radioList != null && radioList.isNotEmpty
                    ? Column(children: [
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
                                    onPressed: () async {
                                      List<String> ids = radioList
                                          .map((e) => e.stationUuid!)
                                          .toList();
                                      await ref
                                          .watch(favoritesDataProvider.notifier)
                                          .updateFavorites(ids);

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
                                        // print(jsonEncode(radioList));
                                        isReorderClicked = false;
                                      });
                                    },
                                    text: "Cancel",
                                  )
                                ],
                        ),
                        Expanded(
                            child: isReorderClicked
                                ? RadioTileListReorderableView(
                                    radioStationList: radioList,
                                    selectedRadios: [],
                                    setSelectedRadios: () {},
                                    showCheckBox: false,
                                  )
                                : RadioTileListView(
                                    radioStationList: radioList))
                      ])
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                            Center(
                                child: Text(
                                    "You have not added any radio stations to your Favourites list",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20)))
                          ]);
              } else {
                return SkeletonListView();
              }
            }));
  }
}
