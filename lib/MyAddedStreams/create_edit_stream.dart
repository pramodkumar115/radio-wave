import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getwidget/getwidget.dart';
import 'package:orbit_radio/Notifiers/addedstreams_state_notifier.dart';
import 'package:orbit_radio/model/radio_station.dart';
import 'package:intl/intl.dart';

class CreateEditStream extends ConsumerStatefulWidget {
  const CreateEditStream(
      {super.key, required this.streams, required this.selected});
  final List<RadioStation> streams;
  final RadioStation? selected;

  @override
  ConsumerState<CreateEditStream> createState() => _CreateEditPlaylistState();
}

class _CreateEditPlaylistState extends ConsumerState<CreateEditStream> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _favIconController = TextEditingController();

  int index = -1;

  @override
  void initState() {
    super.initState();
    if (widget.selected != null) {
      setState(() {
        _nameController.text = widget.selected!.name!;
        _urlController.text = widget.selected!.url!;
        _countryController.text = widget.selected!.country!;
        _favIconController.text = widget.selected!.favicon!;
        if (widget.selected != null) {
          setState(() => index = widget.streams.indexOf(widget.selected!));
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  RadioStation getStation(bool isEdit) {
    return RadioStation(
        name: _nameController.text,
        country: _countryController.text,
        stationUuid: isEdit
            ? widget.selected!.stationUuid!
            : "ADDED_STREAM_${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}",
        url: _urlController.text,
        favicon: _favIconController.text);
  }

  void createStream(List<RadioStation> streams) async {
    if (_nameController.text.isEmpty || _urlController.text.isEmpty) {
      GFToast.showToast("Please enter name/url", context);
    } else {
      if (widget.selected != null) {
        streams[index] = getStation(true);
      } else {
        streams.add(getStation(false));
      }
      await ref
          .watch(addedStreamsDataProvider.notifier)
          .updateAddedStreams(streams);
      setState(() {
        _nameController.text = "";
        _countryController.text = "";
        _urlController.text = "";
        _favIconController.text = "";
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
        // Make the content scrollable
        child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context)
                  .viewInsets
                  .bottom, // Adjust padding based on keyboard height
            ),
            child: SizedBox(
                height: screenHeight * 0.5,
                width: screenWidth,
                child: Container(
                    margin: EdgeInsets.all(24),
                    width: screenWidth,
                    child: Column(
                      spacing: 20,
                      children: [
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Stream Name'),
                        ),
                        TextField(
                          controller: _urlController,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'URL of the Stream'),
                        ),
                        TextField(
                          controller: _countryController,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Country'),
                        ),
                        TextField(
                          controller: _favIconController,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Icon Url if any'),
                        ),
                        GFButton(
                            text: "Create / Save",
                            color: Colors.black,
                            fullWidthButton: true,
                            size: 60,
                            type: GFButtonType.solid,
                            shape: GFButtonShape.pills,
                            onPressed: () => createStream(widget.streams))
                      ],
                    )))));
  }
}
