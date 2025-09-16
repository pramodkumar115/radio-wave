import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:orbit_radio/CountryFamous/country_famous_service.dart';
import 'package:orbit_radio/CountryFamous/country_famous_view.dart';
import 'package:orbit_radio/Notifiers/audio_player_notifier.dart';
import 'package:orbit_radio/Notifiers/country_state_notifier.dart';
import 'package:orbit_radio/Notifiers/favorites_state_notifier.dart';
import 'package:orbit_radio/Notifiers/recent_visits_notifier.dart';
import 'package:orbit_radio/RecentVisits/recents_visits_view.dart';
import 'package:orbit_radio/TopHits/top_hits_view.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Home extends ConsumerStatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  TabController? _tabController;

  String userCurrentCountry = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    Future.delayed(Duration.zero, () async {
      var country = await getUserCurrentCountry();
      ref.read(countryProvider.notifier).updateCountry(country);
      ref.read(favoritesDataProvider.notifier).fetchFavorites();
      ref.read(recentVisitsDataProvider.notifier).fetchRecentVisits();
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final country = ref.watch(countryProvider);

    return Scaffold(
      body: SafeArea(
          child: ListView(scrollDirection: Axis.vertical, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // HStack([
            const GFAvatar(
              backgroundImage: AssetImage('assets/OrbitRadio.png'),
              shape: GFAvatarShape.square,
              backgroundColor: Color.fromRGBO(232, 237, 219, 0),
              foregroundColor: Color.fromRGBO(232, 237, 219, 0),
              size: 32,
            ),
            const Text("Orbit Radio")
                .text
                .color(Colors.red[900])
                .scale(1.5)
                .extraBold
                .make(),
            // ]),
            const Icon(Icons.search_rounded)
          ],
        ),
        const TopHitsView(),
        const RecentVisitsView(),
        country != ""
            ? const CountryFamousStationsView()
            : const Text("User has not permitted us to use location details")
      ]).p12()),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey.shade200,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.red,
        onTap: _onItemTapped,
      ),
    );
  }
}
