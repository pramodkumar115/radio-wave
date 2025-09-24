import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit_radio/Notifiers/addedstreams_state_notifier.dart';
import 'package:orbit_radio/Notifiers/playlist_state_notifier.dart';
import 'package:orbit_radio/components/create_new_playlist_button.dart';
import 'package:orbit_radio/components/create_new_stream_button.dart';
import 'package:orbit_radio/components/playlist_tile.dart';
import 'package:orbit_radio/components/radio_tile.dart';
import 'package:orbit_radio/model/playlist_item.dart';
import 'package:orbit_radio/model/radio_station.dart';
import 'package:velocity_x/velocity_x.dart';

class MyAddedStreamsView extends ConsumerStatefulWidget {
  const MyAddedStreamsView({super.key});

  @override
  ConsumerState<MyAddedStreamsView> createState() => _MyAddedStreamsViewState();
}

class _MyAddedStreamsViewState extends ConsumerState<MyAddedStreamsView> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.read(addedStreamsDataProvider.notifier).build();
    final addedStreams = ref.watch(addedStreamsDataProvider);
    return addedStreams.when(data: (streams) {
      setState(() {
        _isLoading = false;
      });
      return showContent(context, streams);
    }, error: (error, stacktrace) {
      setState(() => setState(() => _isLoading = false));
      return Center(child: Text("Error getting data"));
    }, loading: () {
      setState(() => _isLoading = true);
      print("In loading");
      return CircularProgressIndicator();
    });
  }

  Widget showContent(
      BuildContext context, List<RadioStation> streams) {
    final double screenHeight = MediaQuery.of(context).size.height;
    print('playlist length - ${streams.length}');
    return Container(
            margin: const EdgeInsets.only(top: 50),
            child: _isLoading
                ? ListView(children: [Center(child: Text("Please wait"))])
                : ListView(children: [
                    CreateNewStreamButton(items: streams),
                    ...getWidget(streams)
                  ]))
        .p12();
  }

  List<Widget> getWidget(List<RadioStation> streams) {
    if (streams.isNotEmpty) {
      return streams
          .map((stream) => RadioTile(radio: stream, radioStations: [...streams], isAddedStream: true))
          .toList();
    } else {
      [Center(child: Text("No Radio streams added by you."))];
    }
    return [Container()];
  }
}
