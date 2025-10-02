import 'package:flutter/material.dart';
import 'package:orbit_radio/RadioPlayer/radio_player_view.dart';
import 'package:orbit_radio/commons/util.dart';
import 'package:orbit_radio/model/radio_station.dart';

class RadioStationListView extends StatefulWidget {
  final List<RadioStation> stationList;

  const RadioStationListView({super.key, required this.stationList});

  @override
  State<RadioStationListView> createState() => _RadioStationListViewState();
}

class _RadioStationListViewState extends State<RadioStationListView> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 190,
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
                      backgroundColor: Colors.grey.shade100,
                      builder: (BuildContext context) {
                        return RadioPlayerView(
                            radioStationsList: widget.stationList,
                            selectedRadioId: s.stationUuid!);
                      },
                    );
                  },
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 120,
                          height: 100,
                            child: Card(
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                    color: Color.fromARGB(255, 226, 226,
                                        227), // Specify border color
                                    width: 0.5, // Specify border width
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      5.0), // Optional: for rounded corners
                                ),
                                margin: const EdgeInsets.all(8),
                                color: Colors.white,
                                surfaceTintColor: Colors.white,
                                elevation: 1,
                                child: Container(
                                    padding: const EdgeInsets.all(12),
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
                                                  width: 200, height: 100),
                                    )))),
                        SizedBox(
                            width: 120,
                            child: Text(
                                '${getStationName(s.name)} ${getStationCountry(s.country)}',
                                softWrap: true,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold))),
                      ])))
              .toList(),
        ));
  }
}
