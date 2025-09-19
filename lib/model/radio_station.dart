// This data model class represents a radio station object, converting JSON data
// into a type-safe Dart object.
class RadioStation {
  final String? changeUuid;
  final String? stationUuid;
  final String? serverUuid;
  final String? name;
  final String? url;
  final String? urlResolved;
  final String? homepage;
  final String? favicon;
  final String? tags;
  final String? country;
  final String? countrycode;
  final String? iso3166_2;
  final String? state;
  final String? language;
  final String? languagecodes;
  final int? votes;
  // final DateTime? lastchangetime;
  // final String? codec;
  // final int? bitrate;
  // final int? hls;
  // final int? lastcheckok;
  // final DateTime? lastchecktime;
  // final DateTime? lastcheckoktime;
  // final DateTime? lastlocalchecktime;
  // final DateTime? clicktimestamp;
  // final int? clickcount;
  // final int? clicktrend;
  // final int? sslError;
  // final double? geoLat;
  // final double? geoLong;
  // final double? geoDistance;
  // final bool? hasExtendedInfo;

  RadioStation({
    this.changeUuid,
    this.stationUuid,
    this.serverUuid,
    this.name,
    this.url,
    this.urlResolved,
    this.homepage,
    this.favicon,
    this.tags,
    this.country,
    this.countrycode,
    this.iso3166_2,
    this.state,
    this.language,
    this.languagecodes,
    this.votes,
    // this.lastchangetime,
    // this.codec,
    // this.bitrate,
    // this.hls,
    // this.lastcheckok,
    // this.lastchecktime,
    // this.lastcheckoktime,
    // this.lastlocalchecktime,
    // this.clicktimestamp,
    // this.clickcount,
    // this.clicktrend,
    // this.sslError,
    // this.geoLat,
    // this.geoLong,
    // this.geoDistance,
    // this.hasExtendedInfo,
  });

  // Factory constructor to create a RadioStation instance from a JSON map.
  factory RadioStation.fromJson(Map<String, dynamic> json) {
    return RadioStation(
      changeUuid: json['changeuuid'] as String?,
      stationUuid: json['stationuuid'] as String?,
      serverUuid: json['serveruuid'] as String?,
      name: json['name'] as String?,
      url: json['url'] as String?,
      urlResolved: json['url_resolved'] as String?,
      homepage: json['homepage'] as String?,
      favicon: json['favicon'] as String?,
      tags: json['tags'] as String?,
      country: json['country'] as String?,
      countrycode: json['countrycode'] as String?,
      iso3166_2: json['iso_3166_2'] as String?,
      state: json['state'] as String?,
      language: json['language'] as String?,
      languagecodes: json['languagecodes'] as String?,
      votes: json['votes'] as int?,
      // lastchangetime: json['lastchangetime_iso8601'] != null
      //     ? DateTime.tryParse(json['lastchangetime_iso8601'])
      //     : null,
      // codec: json['codec'] as String?,
      // bitrate: json['bitrate'] as int?,
      // hls: json['hls'] as int?,
      // lastcheckok: json['lastcheckok'] as int?,
      // lastchecktime: json['lastchecktime_iso8601'] != null
      //     ? DateTime.tryParse(json['lastchecktime_iso8601'])
      //     : null,
      // lastcheckoktime: json['lastcheckoktime_iso8601'] != null
      //     ? DateTime.tryParse(json['lastcheckoktime_iso8601'])
      //     : null,
      // lastlocalchecktime: json['lastlocalchecktime_iso8601'] != null
      //     ? DateTime.tryParse(json['lastlocalchecktime_iso8601'])
      //     : null,
      // clicktimestamp: json['clicktimestamp_iso8601'] != null
      //     ? DateTime.tryParse(json['clicktimestamp_iso8601'])
      //     : null,
      // clickcount: json['clickcount'] as int?,
      // clicktrend: json['clicktrend'] as int?,
      // sslError: json['ssl_error'] as int?,
      // geoLat: json['geo_lat'] as double?,
      // geoLong: json['geo_long'] as double?,
      // geoDistance: json['geo_distance'] as double?,
      // hasExtendedInfo: json['has_extended_info'] as bool?,
    );
  }

  // Method to convert a RadioStation instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'changeuuid': changeUuid,
      'stationuuid': stationUuid,
      'serveruuid': serverUuid,
      'name': name,
      'url': url,
      'url_resolved': urlResolved,
      'homepage': homepage,
      'favicon': favicon,
      'tags': tags,
      'country': country,
      'countrycode': countrycode,
      'iso_3166_2': iso3166_2,
      'state': state,
      'language': language,
      'languagecodes': languagecodes,
      'votes': votes
    };
  }
}
