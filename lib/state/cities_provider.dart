import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/location/city.dart';

/// The bundled city list, parsed once off the UI thread and kept in memory.
final citiesProvider = FutureProvider<List<City>>((ref) async {
  final tsv = await rootBundle.loadString('assets/cities.tsv');
  return compute(parseCities, tsv);
});
