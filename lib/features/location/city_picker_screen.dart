import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/location/city.dart';
import '../../core/location/device_location.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_settings.dart';
import '../../state/cities_provider.dart';

class CityPickerScreen extends ConsumerStatefulWidget {
  const CityPickerScreen({super.key});

  @override
  ConsumerState<CityPickerScreen> createState() => _CityPickerScreenState();
}

class _CityPickerScreenState extends ConsumerState<CityPickerScreen> {
  String _query = '';
  bool _locating = false;

  void _choose(SavedPlace place) {
    ref.read(settingsProvider.notifier).setPlace(place);
    Navigator.of(context).pop();
  }

  Future<void> _useDeviceLocation(List<City> cities) async {
    final l = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _locating = true);
    try {
      final here = await readDeviceLocation();
      if (!mounted) return;
      final near = nearestCity(cities, here.latitude, here.longitude);
      _choose(SavedPlace(
        name: near?.name ?? l.myLocation,
        countryCode: near?.countryCode ?? '',
        latitude: here.latitude,
        longitude: here.longitude,
        timeZone: here.timeZone,
        fromGps: true,
      ));
    } on DeviceLocationException catch (e) {
      final message = switch (e.failure) {
        DeviceLocationFailure.serviceDisabled => l.locationDisabled,
        DeviceLocationFailure.permissionDenied => l.locationDenied,
        DeviceLocationFailure.unavailable => l.locationFailed,
      };
      messenger.showSnackBar(SnackBar(content: Text(message)));
    } on Exception {
      messenger.showSnackBar(SnackBar(content: Text(l.locationFailed)));
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cities = ref.watch(citiesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.chooseCity)),
      body: cities.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (all) {
          final matches =
              _query.trim().length < 2 ? const <CityMatch>[] : searchCities(all, _query);
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: l.searchCity,
                    helperText: l.searchCityHint,
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
              ListTile(
                leading: _locating
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location),
                title: Text(l.useMyLocation),
                enabled: !_locating,
                onTap: () => _useDeviceLocation(all),
              ),
              const Divider(height: 1),
              Expanded(
                child: matches.isEmpty && _query.trim().length >= 2
                    ? Center(child: Text(l.noCitiesFound))
                    : ListView.builder(
                        itemCount: matches.length,
                        itemBuilder: (context, i) {
                          final m = matches[i];
                          final c = m.city;
                          final sameName = m.matchedName == c.name;
                          return ListTile(
                            title: Text(m.matchedName),
                            subtitle: Text(
                              sameName
                                  ? c.countryCode
                                  : '${c.name}, ${c.countryCode}',
                            ),
                            onTap: () => _choose(SavedPlace(
                              name: m.matchedName,
                              countryCode: c.countryCode,
                              latitude: c.latitude,
                              longitude: c.longitude,
                              timeZone: c.timeZone,
                              fromGps: false,
                            )),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
