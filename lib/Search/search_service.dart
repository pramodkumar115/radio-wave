import 'package:http/http.dart' as http;
import '../commons/constants.dart' as constants;

getSearchResults(String text, String searchType, int startIndex, int endIndex) async {
  print({text, searchType, startIndex, endIndex});
  print('${constants.BASE_URL}stations/$searchType/${text.toLowerCase()}?offset=$startIndex&limit=$endIndex');
return await http.get(Uri.parse('${constants.BASE_URL}stations/$searchType/${text.toLowerCase()}?offset=$startIndex&limit=$endIndex'));
}