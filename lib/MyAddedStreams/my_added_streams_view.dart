import 'dart:io';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getwidget/getwidget.dart';
import 'package:intl/intl.dart';
import 'package:orbit_radio/Notifiers/addedstreams_state_notifier.dart';
import 'package:orbit_radio/components/create_new_stream_button.dart';
import 'package:orbit_radio/components/radio_tile.dart';
import 'package:orbit_radio/model/radio_station.dart';

class MyAddedStreamsView extends ConsumerStatefulWidget {
  const MyAddedStreamsView({super.key});

  @override
  ConsumerState<MyAddedStreamsView> createState() => _MyAddedStreamsViewState();
}

class _MyAddedStreamsViewState extends ConsumerState<MyAddedStreamsView> {
  bool _isLoading = true;
  late FilePickerResult? _filePickerResult;
  int startIndex = 0, endIndex = 10;

  @override
  void initState() {
    super.initState();
    _filePickerResult = null;
  }

  Future<void> pickFile() async {
    _filePickerResult = await FilePicker.platform.pickFiles(
      type: FileType
          .custom, // Or FileType.image, FileType.video, FileType.audio, FileType.any
      allowedExtensions: [
        'xlsx',
        'numbers'
      ], // Specify allowed extensions for FileType.custom
      allowMultiple: false, // Set to true for multiple file selection
    );

    if (_filePickerResult != null) {
      String? filePath = _filePickerResult!.files.single.path;
      if (filePath != null) {
        File file = File(filePath);
        var bytes = await file.readAsBytes();
        print("bytes - ${bytes.length}");
        _readExcelData(bytes);
      }
    } else {
      // User canceled the picker
      print('File picking canceled');
    }
  }

  void _readExcelData(Uint8List? bytes) {
    if (bytes == null) return;

    var excel = Excel.decodeBytes(bytes);

    print("In read excel");

    for (var table in excel.tables.keys) {
      print("Sheet Name: $table");
      print("Max Columns: ${excel.tables[table]!.maxColumns}");
      print("Max Rows: ${excel.tables[table]!.maxRows}");
      List<RadioStation> stations = List.empty(growable: true);
      var firstRow = excel.tables[table]!.rows[0];
      int slNoIndex = -1,
          nameIndex = -1,
          urlIndex = -1,
          countryIndex = -1,
          favIconIndex = -1;
      for (var cell in firstRow) {
        var cellValue = cell?.value.toString().toLowerCase() ?? "";
        if (cellValue == 'sl no') {
          slNoIndex = firstRow.indexOf(cell);
        }
        if (cellValue == 'name') {
          nameIndex = firstRow.indexOf(cell);
        }
        if (cellValue == 'url') {
          urlIndex = firstRow.indexOf(cell);
        }
        if (cellValue == 'country') {
          countryIndex = firstRow.indexOf(cell);
        }
        if (cellValue == 'favicon') {
          favIconIndex = firstRow.indexOf(cell);
        }
      }

      for (var index = 1; index < excel.tables[table]!.rows.length; index++) {
        var row = excel.tables[table]!.rows[index];
        var rowIndex = excel.tables[table]!.rows.indexOf(row);
        print(rowIndex);
        if (rowIndex == 0) {
          continue;
        }
        var name = "", url = "", favIcon = "", country = "India";
        for (var cell in row) {
          if (nameIndex != -1 && row.indexOf(cell) == nameIndex) {
            name = cell?.value?.toString() ?? "";
          }
          if (urlIndex != -1 && row.indexOf(cell) == urlIndex) {
            url = cell?.value?.toString() ?? "";
          }
          if (countryIndex != -1 && row.indexOf(cell) == countryIndex) {
            country = cell?.value?.toString() ?? "";
          }
          if (favIconIndex != -1 && row.indexOf(cell) == favIconIndex) {
            favIcon = cell?.value?.toString() ?? "";
          }
        }
        stations.add(RadioStation(
            name: name,
            url: url,
            country: country,
            stationUuid:
                "ADDED_STREAM_${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}_$index",
            favicon: favIcon));
      }
      ref.watch(addedStreamsDataProvider.notifier).updateAddedStreams(stations);
    }
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
      debugPrint("In loading");
      return CircularProgressIndicator();
    });
  }

  Widget showContent(BuildContext context, List<RadioStation> streams) {
    // final double screenHeight = MediaQuery.of(context).size.height;
    debugPrint('playlist length - ${streams.length}');
    return Container(
        margin: const EdgeInsets.only(top: 70),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: _isLoading
            ? ListView(children: [Center(child: Text("Please wait"))])
            : ListView(children: [
                CreateNewStreamButton(items: streams),
                GFButton(
                    color: Colors.black87,
                    shape: GFButtonShape.pills,
                    onPressed: pickFile,
                    text:
                        "Upload streams as a file (name, url mandatory columns)"),
                getWidget(streams)
              ]));
  }

  Widget getWidget(List<RadioStation> streams) {
    if (streams.isNotEmpty) {
      return Column(children: [
        ...streams
            .sublist(startIndex,
                streams.length - 1 > endIndex ? endIndex : streams.length - 1)
            .map((stream) => RadioTile(
                radio: stream, radioStations: [...streams], from: 'STREAMS', isReorderClicked: false)),
        Padding(
            padding: EdgeInsetsGeometry.all(20),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  startIndex >= 10
                      ? GFButton(
                          type: GFButtonType.transparent,
                          text: 'Previous',
                          textColor: Colors.black,
                          icon: Icon(Icons.arrow_back),
                          onPressed: () {
                            setState(() {
                              startIndex = startIndex - 10;
                              endIndex = endIndex - 10;
                            });
                          })
                      : Container(),
                  streams.length >= endIndex
                      ? GFButton(
                          type: GFButtonType.transparent,
                          text: 'Next',
                          icon: Icon(Icons.arrow_forward),
                          textColor: Colors.black,
                          onPressed: () {
                            setState(() {
                              startIndex = startIndex + 10;
                              endIndex = endIndex + 10;
                            });
                          })
                      : Container(),
                ]))
      ]);
    } else {
      return Center(child: Text("No Radio streams added by you."));
    }
  }
}
