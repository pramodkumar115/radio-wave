import 'package:http/http.dart' as http;
import "../commons/constants.dart" as Constants;

getTopHitStationDetails() async {
return await http.get(Uri.parse('${Constants.BASE_URL}stations/topvote/10'));
}