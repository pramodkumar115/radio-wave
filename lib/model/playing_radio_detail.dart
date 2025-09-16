// This data model class represents a radio station object, converting JSON data
// into a type-safe Dart object.
class PlayingRadioDetail {
  String stationUuid = "";
  bool isPlaying = false;

  PlayingRadioDetail({
    required this.stationUuid,
    required this.isPlaying
  });
}