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
    return GestureDetector(
      child: favIds.contains(station!.stationUuid!)
          ? const FUI(SolidRounded.HEART, color: Color.fromARGB(255, 0, 29, 10))
          : const FUI(RegularRounded.HEART, color: Color.fromARGB(255, 0, 29, 10)),
      onTap: () => addToFavorites(favIds, widget.station),
    );
  }
}
