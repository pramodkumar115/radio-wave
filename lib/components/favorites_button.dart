import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fui_kit/fui_kit.dart';
import 'package:getwidget/getwidget.dart';
import 'package:orbit_radio/Notifiers/favorites_state_notifier.dart';
import 'package:orbit_radio/model/radio_station.dart';

class FavoritesButton extends ConsumerStatefulWidget {
  const FavoritesButton({super.key, required this.station});
  final RadioStation station;

  @override
  ConsumerState<FavoritesButton> createState() => _FavoritesButtonState();
}

class _FavoritesButtonState extends ConsumerState<FavoritesButton> {
  Future<void> addToFavorites(
      List<String> favoritesUUIDs, selectedRadioStation) async {
    var message = "";
    if (!favoritesUUIDs.contains(selectedRadioStation!.stationUuid!)) {
      favoritesUUIDs = [...favoritesUUIDs, selectedRadioStation!.stationUuid!];
      message = 'Station added to favorites';
    } else {
      favoritesUUIDs = favoritesUUIDs
          .where((element) => element != selectedRadioStation!.stationUuid!)
          .toList();
      message = 'Station removed from favorites';
    }
    ref.read(favoritesDataProvider.notifier).updateFavorites(favoritesUUIDs);
    GFToast.showToast(message, context);
  }

  @override
  Widget build(BuildContext context) {
    final favoritesUUIDs = ref.watch(favoritesDataProvider);
    return favoritesUUIDs.when(
        data: (favIds) {
          return showContent(favIds, widget.station);
        },
        loading: () => showContent([], widget.station),
        error: (error, stackTrace) => Center(child: Text('Error: $error')));
  }

  Widget showContent(List<String> favIds, RadioStation station) {
    return InkWell(
      child: favIds.contains(station!.stationUuid!)
          ? const FUI(
              SolidRounded.HEART,
              color: Color.fromRGBO(248, 1, 26, 1),
              width: 25,
              height: 25,
            )
          : const FUI(
              RegularRounded.HEART,
              color: Color.fromARGB(255, 250, 3, 3),
              width: 25,
              height: 25,
            ),
      onTap: () => addToFavorites(favIds, widget.station),
    );
  }
}
