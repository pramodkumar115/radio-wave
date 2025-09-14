import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:orbit_radio/CountryFamous/country_famous_service.dart';
import 'package:orbit_radio/CountryFamous/country_famous_view.dart';
import 'package:orbit_radio/RecentVisits/recents_visits_view.dart';
import 'package:orbit_radio/TopHits/top_hits_view.dart';
import 'package:orbit_radio/commons/util.dart';
import 'package:velocity_x/velocity_x.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  TabController? _tabController;
  String? userCurrentCountry;
  List<dynamic>? favoritesData;
  List<dynamic>? playList;
  List<dynamic>? userPreferences;

  @override
  void initState() {
    super.initState();
    loadData();
    _tabController = TabController(length: 3, vsync: this);
  }

  Future<void> loadData() async {
    var country = await getUserCurrentCountry();
    var favoritesDataFromFile = await getFavoritesFromFile();
    print("favorites - $favoritesDataFromFile");
    // var platListInfo = getPlayListDataFromFile();
    
    setState(() {
      userCurrentCountry = country;
      favoritesData = favoritesDataFromFile;
    });
    print("Came here in loaddata - $country");
    
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
        TopHitsView(favoritesData:favoritesData, loadAllData: loadData),
        RecentVisitsView(favoritesData:favoritesData, loadAllData: loadData),
        userCurrentCountry != null
            ? CountryFamousStationsView(favoritesData:favoritesData, countryName: userCurrentCountry, loadAllData: loadData)
            : const Text("User has not permitted us to use location details")
      ]).p12()),
      bottomNavigationBar: BottomNavigationBar(
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
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
