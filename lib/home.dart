import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:orbit_radio/CountryFamous/country_famous_service.dart';
import 'package:orbit_radio/Favourites/favourites_view.dart';
import 'package:orbit_radio/FloatingPLayer/floating_player_view.dart';
import 'package:orbit_radio/Home/home_view.dart';
import 'package:orbit_radio/MyAddedStreams/my_added_streams_view.dart';
import 'package:orbit_radio/MyPlaylist/my_playlist_list_view.dart';
import 'package:orbit_radio/Notifiers/addedstreams_state_notifier.dart';
import 'package:orbit_radio/Notifiers/audio_player_notifier.dart';
import 'package:orbit_radio/Notifiers/country_state_notifier.dart';
import 'package:orbit_radio/Notifiers/favorites_state_notifier.dart';
import 'package:orbit_radio/Search/search_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> with TickerProviderStateMixin {
  int _selectedIndex = 0;

  String userCurrentCountry = "";

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      var country = await getUserCurrentCountry();
      if (country != null && country.isNotEmpty) {
        ref.read(countryProvider.notifier).updateCountry(country);
      }
      ref.read(favoritesDataProvider.notifier).build();
      ref.read(addedStreamsDataProvider.notifier).build();
    });
  }

  @override
  void dispose() {
    ref.watch(audioPlayerProvider.notifier).dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget showContent() {
    if (_selectedIndex == 1) {
      return FavouritesView();
    } else if (_selectedIndex == 2) {
      return MyPlaylistListView();
    } else if (_selectedIndex == 3) {
      return MyAddedStreamsView();
    } else {
      return HomeTabView();
    }
  }

  @override
  Widget build(BuildContext context) {
    // final double screenHeight = MediaQuery.of(context).size.height;
    // final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        extendBody: true,
        body: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                  const Color.fromARGB(255, 245, 242, 222),
                  const Color.fromARGB(95, 211, 203, 66),
                  const Color.fromARGB(95, 144, 246, 231),
                  const Color.fromARGB(95, 185, 245, 236),
                ])),
            child: SafeArea(
                child: Stack(children: [
              Container(
                padding: EdgeInsets.all(10),
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const GFAvatar(
                    backgroundImage: AssetImage('assets/AppIconNew.png'),
                    shape: GFAvatarShape.square,
                    backgroundColor: Color.fromRGBO(232, 237, 219, 0),
                    foregroundColor: Color.fromRGBO(232, 237, 219, 0),
                    size: 32,
                  ),
                  const Text("Orbit Radio",
                      style: TextStyle(
                          color: Color.fromARGB(255, 186, 8, 5),
                          fontSize: 22,
                          fontWeight: FontWeight.w800)),
                  GestureDetector(
                    child:
                        const Icon(Icons.search, size: 30, color: Colors.black),
                    onTap: () {
                      debugPrint("Came here");
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                            builder: (context) => const SearchView()),
                      );
                    },
                  )
                ],
              )),
              showContent(),
            ]))),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            FloatingPlayerView(),
            CurvedNavigationBar(
                backgroundColor: Colors.transparent,
                index: _selectedIndex,
                onTap: _onItemTapped,
                animationCurve: Curves.linear,
                items: [
                  _selectedIndex == 0
                      ? Icon(Icons.home,
                          size: 30,
                          color: Colors
                              .red) // FUI(SolidRounded.HOME, color: Colors.red)
                      : Icon(
                          Icons.home_outlined,
                          size: 30,
                        ), // FUI(RegularRounded.HOME, color: Colors.black),
                  _selectedIndex == 1
                      ? Icon(Icons.favorite,
                          size: 30,
                          color: Colors
                              .red) // FUI(SolidRounded.HEART, color: Colors.red)
                      : Icon(
                          Icons.favorite_border_outlined,
                          size: 30,
                        ), // FUI(RegularRounded.HEART, color: Colors.black),
                  _selectedIndex == 2
                      ? Icon(Icons.playlist_play_outlined,
                          size: 30,
                          color: Colors
                              .red) // FUI(SolidRounded.HEART, color: Colors.red)
                      : Icon(
                          Icons.playlist_play_outlined,
                          size: 30,
                        ),
                  _selectedIndex == 3
                      ? Icon(Icons.add_to_photos,
                          size: 30,
                          color: Colors
                              .red) // FUI(SolidRounded.HEART, color: Colors.red)
                      : Icon(
                          Icons.add_to_photos_outlined,
                          size: 30,
                        ),
                ])
          ]),
        ));
  }
}
