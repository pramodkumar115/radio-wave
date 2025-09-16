import 'package:http/http.dart' as http;
import 'package:orbit_radio/commons/util.dart';
import 'package:geolocator/geolocator.dart';
import '../commons/constants.dart' as constants;

getCountryFamousStationDetails(country) async {
  return await http
      .get(Uri.parse('${constants.BASE_URL}stations/bycountry/$country?limit=10'));
}

getUserCurrentCountry() async {
  Position? posn = await getCurrentLocation();
  // print("Positon details - $posn, ");
  if (posn != null) {
    String? country =
        await getCountryFromCoordinates(posn.latitude, posn.longitude);
    // print("Positon details - $posn, $country");
    return country;
  }
  return null;
}
