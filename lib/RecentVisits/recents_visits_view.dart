import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getwidget/getwidget.dart';
import 'package:orbit_radio/Notifiers/recent_visits_notifier.dart';
import 'package:orbit_radio/RadioStations/radio_station_list.dart';
import 'package:orbit_radio/RecentVisits/recent_visits_service.dart';
import 'package:orbit_radio/commons/shimmer.dart';
import 'package:orbit_radio/model/radio_station.dart';
import 'package:velocity_x/velocity_x.dart';

class RecentVisitsView extends ConsumerStatefulWidget {
  const RecentVisitsView({super.key});
  @override
  ConsumerState<RecentVisitsView> createState() => _RecentVisitsViewState();
}

class _RecentVisitsViewState extends ConsumerState<RecentVisitsView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final recentVisitedStations = ref.watch(recentVisitsDataProvider);
    return recentVisitedStations.when(
        data: (stationList) {
          return showContent(context, stationList);
        },
        loading: () => GFShimmer(child: emptyBlock),
        error: (error, stackTrace) => Center(child: Text('Error: $error')));
  }

  Widget showContent(BuildContext context, List<RadioStation> stationList) {
    return stationList.isNotEmpty ? VStack([
          const Text("Recent Visits").text.scale(1.1).bold.make(),
          RadioStationListView(stationList: stationList)
        ]) : Container();
  }
}
