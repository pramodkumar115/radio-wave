import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../commons/constants.dart' as constants;

getSearchResults(String text, String searchType, int startIndex, int endIndex) async {
  debugPrint('${constants.BASE_URL}stations/$searchType/${text.toLowerCase()}?offset=$startIndex&limit=$endIndex');
return await http.get(Uri.parse('${constants.BASE_URL}stations/$searchType/${text.toLowerCase()}?offset=$startIndex&limit=$endIndex'));
}