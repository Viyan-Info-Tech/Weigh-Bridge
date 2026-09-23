// Generated from address.md - List of Indian States & Union Territories and their Cities
//
// This file combines the state and union territory data from
// indian_states.dart and indian_union_territories.dart into a single
// map for consumption by the rest of the app.

import 'indian_states.dart';
import 'indian_union_territories.dart';

const Map<String, List<String>> indianStatesAndCities = {
  ...indianStatesData,
  ...indianUnionTerritoriesData,
};

List<String> get indianStates => indianStatesAndCities.keys.toList();

List<String> getCitiesForState(String? state) {
  if (state == null || state.isEmpty) return const [];
  return indianStatesAndCities[state] ?? const [];
}
