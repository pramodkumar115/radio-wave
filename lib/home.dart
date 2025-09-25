import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:orbit_radio/CountryFamous/country_famous_service.dart';
import 'package:orbit_radio/CountryFamous/country_famous_view.dart';
import 'package:orbit_radio/Favourites/favourites_view.dart';
import 'package:orbit_radio/FloatingPLayer/floating_player_view.dart';
import 'package:orbit_radio/Home/home_view.dart';
import 'package:orbit_radio/MyAddedStreams/my_added_streams_view.dart';
import 'package:orbit_radio/MyPlaylist/my_playlist_list_view.dart';
import 'package:orbit_radio/Notifiers/addedstreams_state_notifier.dart';
import 'package:orbit_radio/Notifiers/audio_player_notifier.dart';
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
      ref.read(favoritesDataProvider.notifier).build();
      ref.read(recentVisitsDataProvider.notifier).build();
      ref.read(addedStreamsDataProvider.notifier).build();
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
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
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      extendBody: true,
        // backgroundColor: Color.fromARGB(255, 247, 247, 244),
        body: Container(
            decoration: BoxDecoration(
                // image: DecorationImage(
                //   image: AssetImage('assets/background5.jpg'), // Your image path
                //   fit: BoxFit.cover, // Adjust how the image fits the container
                // ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // HStack([
                  const GFAvatar(
                    backgroundImage: AssetImage('assets/AppIconNew.png'),
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
                        MaterialPageRoute<void>(
                            builder: (context) => const SearchView()),
                      );
                    },
                  )
                ],
              ).p12(),
              showContent(),
              // FloatingPlayerView()
            ]))),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            // border: Border(
            //   top: BorderSide(
            //       color: Colors.grey,
            //       width: 0.5), // Customize border color and width
            // ),
          ),
          child: VStack([
            FloatingPlayerView(),
            CurvedNavigationBar(
              backgroundColor: Colors.transparent,
              index: _selectedIndex,
              onTap: _onItemTapped,
              items: [
                FUI(_selectedIndex == 0 ? SolidRounded.HOME : RegularRounded.HOME),
                FUI(_selectedIndex == 1 ? SolidRounded.HEART : RegularRounded.HEART),
                FUI(_selectedIndex == 2 ? SolidRounded.LIST : RegularRounded.LIST),
                FUI(_selectedIndex == 3 ? SolidRounded.FOLDER : RegularRounded.FOLDER)
              ]
              // items: <BottomNavigationBarItem>[
              //   BottomNavigationBarItem(
              //     icon: FUI(
              //       _selectedIndex == 0
              //           ? SolidRounded.HOME
              //           : RegularRounded.HOME,
              //       color: _selectedIndex == 0
              //           ? Color.fromARGB(255, 188, 14, 1)
              //           : Colors.grey, // Optional: set the size
              //     ),
              //     label: 'Home',
              //   ),
              //   BottomNavigationBarItem(
              //     icon: FUI(
              //       _selectedIndex == 1
              //           ? SolidRounded.HEART
              //           : RegularRounded.HEART,
              //       color: _selectedIndex == 1
              //           ? Color.fromARGB(255, 188, 14, 1)
              //           : Colors.grey,
              //     ),
              //     label: 'Favourites',
              //   ),
              //   BottomNavigationBarItem(
              //     icon: FUI(
              //       _selectedIndex == 2
              //           ? SolidRounded.LIST
              //           : RegularRounded.LIST,
              //       color: _selectedIndex == 2
              //           ? Color.fromARGB(255, 188, 14, 1)
              //           : Colors.grey,
              //     ),
              //     label: 'My Playlist',
              //   ),
              //   BottomNavigationBarItem(
              //     icon: FUI(
              //       _selectedIndex == 3
              //           ? SolidRounded.FOLDER
              //           : RegularRounded.FOLDER,
              //       color: _selectedIndex == 3
              //           ? Color.fromARGB(255, 188, 14, 1)
              //           : Colors.grey,
              //     ),
              //     label: 'My Added Streams',
              //   ),
              // ],
              // currentIndex: _selectedIndex,
              // selectedItemColor: Colors.black,
              // onTap: _onItemTapped,
            )
          ]),
        ));
  }

  // Transform showIcon(isCurrentAudio, isPlaying) {
  //   if (isCurrentAudio) {
  //     return Transform.scale(
  //       scale: 2.0, // Doubles the size of the child icon
  //       child: (isPlaying != true)
  //           ? const Icon(Icons.play_arrow)
  //           : const Icon(Icons.stop_sharp),
  //     );
  //   } else {
  //     return Transform.scale(
  //         scale: 2.0, // Doubles the size of the child icon
  //         child: const Icon(Icons.play_arrow));
  //   }
  // }
}
