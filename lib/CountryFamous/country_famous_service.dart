import 'package:http/http.dart' as http;
import 'package:orbit_radio/commons/util.dart';
import 'package:geolocator/geolocator.dart';
import '../commons/constants.dart' as constants;

Future<dynamic> getCountryFamousStationDetails(String country) async {
  return await http
      .get(Uri.parse('${constants.BASE_URL}stations/bycountry/$country?limit=20'));
}

Future<String?> getUserCurrentCountry() async {
  Position? posn = await getCurrentLocation();
  if (posn != null) {
    String? country =
        await getCountryFromCoordinates(posn.latitude, posn.longitude);
    return country;
  }
  return null;
}
