import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getwidget/getwidget.dart';
import 'package:orbit_radio/Notifiers/favorites_state_notifier.dart';
import 'package:orbit_radio/commons/util.dart';
import 'package:orbit_radio/components/radio_tile_list_reorderable_view.dart';
import 'package:orbit_radio/components/radio_tile_list_view.dart';
import 'package:orbit_radio/model/radio_station.dart';

class FavouritesView extends ConsumerStatefulWidget {
  const FavouritesView({super.key});

  @override
  ConsumerState<FavouritesView> createState() => _FavouritesViewState();
}

class _FavouritesViewState extends ConsumerState<FavouritesView> {
  List<RadioStation>? radioList;
  bool _isLoading = false;
  bool isReorderClicked = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => _isLoading = true);
    await ref.read(favoritesDataProvider.notifier).fetchFavorites();
    setStateWithData();
  }

  void setStateWithData() {
    final favoritesUUIDs = ref.watch(favoritesDataProvider);
    // debugPrint("favoritesUUIDs - $favoritesUUIDs");
    favoritesUUIDs.when(
        data: (stationIds) async {
          // debugPrint("In fav - $stationIds");
          List<RadioStation> aList = await getAddedStreamsFromFile();
          List<RadioStation> list = List.empty(growable: true);

          for (String radioId in stationIds) {
            if (radioId.startsWith("ADDED")) {
              list.addAll(
                  aList.where((a) => radioId == a.stationUuid).toList());
            } else {
              list.addAll(await getStationsListForUUIDs([radioId]));
            }
          }
          setState(() {
            radioList = [...list];
            _isLoading = false;
          });
        },
        error: (error, stacktrace) {
          setState(() => _isLoading = false);
        },
        loading: () => setState(() => _isLoading = true));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(favoritesDataProvider, (previous, next) {
      setStateWithData();
    });
    return Container(
        margin: const EdgeInsets.only(top: 50),
        padding: EdgeInsets.all(10),
        child: _isLoading
            ? ListView(children: [Center(child: Text("Please wait"))])
            : ((radioList != null && radioList!.isNotEmpty)
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
                                  List<String> ids = radioList!
                                      .map((e) => e.stationUuid!)
                                      .toList();
                                  await ref
                                      .watch(favoritesDataProvider.notifier)
                                      .updateFavorites(ids);
                                  loadData();
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
                              )
                            : RadioTileListView(radioStationList: radioList))
                  ])
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                        Center(
                            child: Text(
                                "You have not added any radio stations to your Favourites list",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20)))
                      ])));
  }
}
