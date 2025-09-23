import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit_radio/Notifiers/favorites_state_notifier.dart';
import 'package:orbit_radio/commons/util.dart';
import 'package:orbit_radio/components/radio_tile.dart';
import 'package:orbit_radio/model/radio_station.dart';
import 'package:velocity_x/velocity_x.dart';

class FavouritesView extends ConsumerStatefulWidget {
  const FavouritesView({super.key});

  @override
  ConsumerState<FavouritesView> createState() => _FavouritesViewState();
}

class _FavouritesViewState extends ConsumerState<FavouritesView> {
  List<RadioStation>? radioList;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => _isLoading = true);
    await ref.read(favoritesDataProvider.notifier).fetchFavorites();
    final favoritesUUIDs = ref.watch(favoritesDataProvider);
    print("favoritesUUIDs - $favoritesUUIDs");
    favoritesUUIDs.when(
        data: (stationIds) async {
          print("In fav - $stationIds");
          final rList = await getStationsListForUUIDs(stationIds);
          if (rList.isNotEmpty) {
            setState(() {
              radioList = [...rList];
              _isLoading = false;
            });
          }
        },
        error: (error, stacktrace) {
          setState(() => _isLoading = false);
        },
        loading: () => setState(() => _isLoading = true));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
            margin: const EdgeInsets.only(top: 50),
            child: _isLoading
                ? ListView(children: [Center(child: Text("Please wait"))])
                : ((radioList != null && radioList!.isNotEmpty)
                    ? ListView(
                        children: radioList!.map((radio) {
                        return RadioTile(
                            radio: radio, radioStations: radioList!);
                      }).toList())
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                            Center(
                                child: Text(
                                        "You have not added any radio stations to your Favourites list")
                                    .text
                                    .bold
                                    .xl2
                                    .make())
                          ])))
        .p12();
  }
}
