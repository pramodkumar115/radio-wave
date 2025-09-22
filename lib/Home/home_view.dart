import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit_radio/CountryFamous/country_famous_view.dart';
import 'package:orbit_radio/Notifiers/country_state_notifier.dart';
import 'package:orbit_radio/RecentVisits/recents_visits_view.dart';
import 'package:orbit_radio/TopHits/top_hits_view.dart';
import 'package:velocity_x/velocity_x.dart';

class HomeTabView extends ConsumerStatefulWidget {
  const HomeTabView({super.key});

  @override
  ConsumerState<HomeTabView> createState() => _HomeTabViewState();
}

class _HomeTabViewState extends ConsumerState<HomeTabView> {
  @override
  Widget build(BuildContext context) {
    final country = ref.watch(countryProvider);
    return Container(
          margin: const EdgeInsets.only(top: 50),
          child: ListView(children: [
            const TopHitsView(),
            const RecentVisitsView(),
            country != "" ? const CountryFamousStationsView() : Container()
          ])).p12();
  }
}
