import 'package:http/http.dart' as http;

getTopHitStationDetails() async {
return await http.get(Uri.parse('http://152.53.85.3/json/stations/topvote/5'));

}