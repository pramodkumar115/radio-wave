import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:orbit_radio/CountryFamous/country_famous_service.dart';
import 'package:orbit_radio/CountryFamous/country_famous_view.dart';
import 'package:orbit_radio/Notifiers/country_state_notifier.dart';
import 'package:orbit_radio/Notifiers/favorites_state_notifier.dart';
import 'package:orbit_radio/Notifiers/recent_visits_notifier.dart';
import 'package:orbit_radio/RecentVisits/recents_visits_view.dart';
import 'package:orbit_radio/Search/search_view.dart';
import 'package:orbit_radio/TopHits/top_hits_view.dart';
import 'package:fui_kit/fui_kit.dart';
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
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 247, 247, 244),
        body: SafeArea(
            child: Stack(children: [
          ListView(scrollDirection: Axis.vertical, children: [
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
                GestureDetector(
                  child: const FUI(BoldRounded.SEARCH, width: 25, height: 25),
                  onTap: () {
                    print("Came here");
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(builder: (context) => const SearchView()),
                    );
                  },
                )
              ],
            ),
            const TopHitsView(),
            const RecentVisitsView(),
            country != "" ? const CountryFamousStationsView() : Container()
          ]).p12(),
          Positioned(
            //width: screenWidth,
            bottom: 8,
            left: 10,
            right: 10,
            child: GFListTile(
                color: Colors.grey.shade50,
                avatar: const GFAvatar(),
                titleText: 'Title',
                subTitleText:
                    'Lorem ipsum dolor sit amet, consectetur adipiscing',
                icon: Icon(Icons.favorite)),
          ),
        ])),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(
                  color: Colors.grey,
                  width: 0.5), // Customize border color and width
            ),
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: FUI(
                  _selectedIndex == 0 ? SolidRounded.HOME : RegularRounded.HOME,
                  color: _selectedIndex == 0
                      ? Color.fromARGB(255, 188, 14, 1)
                      : Colors.grey, // Optional: set the size
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: FUI(
                  _selectedIndex == 1
                      ? SolidRounded.HEART
                      : RegularRounded.HEART,
                  color: _selectedIndex == 1
                      ? Color.fromARGB(255, 188, 14, 1)
                      : Colors.grey,
                ),
                label: 'Favourites',
              ),
              BottomNavigationBarItem(
                icon: FUI(
                  _selectedIndex == 2 ? RegularRounded.LIST : SolidRounded.LIST,
                  color: _selectedIndex == 2
                      ? Color.fromARGB(255, 188, 14, 1)
                      : Colors.grey,
                ),
                label: 'My Playlist',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.black,
            onTap: _onItemTapped,
          ),
        ));
  }

  Transform showIcon(isCurrentAudio, isPlaying) {
    if (isCurrentAudio) {
      return Transform.scale(
        scale: 2.0, // Doubles the size of the child icon
        child: (isPlaying != true)
            ? const Icon(Icons.play_arrow)
            : const Icon(Icons.stop_sharp),
      );
    } else {
      return Transform.scale(
          scale: 2.0, // Doubles the size of the child icon
          child: const Icon(Icons.play_arrow));
    }
  }
}
