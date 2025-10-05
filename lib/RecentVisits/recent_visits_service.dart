import 'package:http/http.dart' as http;
import '../commons/constants.dart' as constants;

Future<http.Response> getRecentVisitsList() async {
return await http.get(Uri.parse('${constants.BASE_URL}stations/topvote/10'));
}