import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getwidget/components/toast/gf_toast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:orbit_radio/home.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:flutter/services.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:velocity_x/velocity_x.dart';

Future<void> main() async {
  final bool isConnected = await InternetConnection().hasInternetAccess;
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_audio_channel',
    androidNotificationChannelName: 'Background audio playback',
    androidNotificationOngoing: true,
  );
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(ProviderScope(child: MyApp(isConnectedToInternet: isConnected)));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.isConnectedToInternet});

  final bool isConnectedToInternet;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Orbit Radio',
      theme: ThemeData(
        textTheme: GoogleFonts.latoTextTheme(
          Theme.of(context).textTheme,
        ),
        useMaterial3: true,
      ),
      home: isConnectedToInternet
          ? const MyHomePage()
          : Center(
              child: Text("This app requires internet connection.").text.xl.bold.amber100.underline.make(),
            ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    // context.read<OrbitRadioProvider>().loadData();
    return const Home();
  }
}
