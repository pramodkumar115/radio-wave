import 'package:flutter_riverpod/flutter_riverpod.dart';

class CountryNotifier extends StateNotifier<String> {
  CountryNotifier() : super('');

  void updateCountry(String country) {
    state = country;
  }
}

final countryProvider = StateNotifierProvider<CountryNotifier, String>((ref) {
  return CountryNotifier();
});
