import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:indoor_navigation/services/ble_service.dart';
import 'package:indoor_navigation/services/gps_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rxdart/rxdart.dart';

class PositionService {
  static final BehaviorSubject<Pos> inject = BehaviorSubject<Pos>();

  static Stream<Pos> get observe => inject.stream;

  final GpsService gpsService = GpsService();
  final BleService bleService = BleService();

  Timer _t = Timer(const Duration(seconds: 0), () {});

  bool _bleActive = false;

  static List<Beacon> beaconSource = [
    Beacon('98:07:2D:A1:86:5B', Pos(53.54448396074, 10.02385242462)),
    Beacon('98:07:2D:A1:83:18', Pos(53.54451979202, 10.02387292292)),
    Beacon('98:07:2D:A1:86:D0', Pos(53.54452947607, 10.02380803307)),
    Beacon('98:07:2D:A1:74:4C', Pos(53.54444197587, 10.02377588459)),
    Beacon('98:07:2D:A1:86:B5', Pos(53.54441192181, 10.02375126021)),
    Beacon('98:07:2D:A1:74:66', Pos(53.54442336277, 10.02380597562))
  ];

  PositionService() {
    if (!kIsWeb) {
      bleService.setBeacons(beaconSource);
      GpsService.observe.listen(_newGpsPositon);
      BleService.observe.listen(_newBlePosition);
    }
  }

  void startPositioning() {
    if (!kIsWeb) {
      gpsService.startPositioning();
      bleService.startPositioning();
    }
  }

  void stopPositioning() {
    if (!kIsWeb) {
      gpsService.stopPositioning();
      bleService.stopPositioning();
    }
  }

  void setBeacons(List<Beacon> beacons) {
    bleService.setBeacons(beacons);
  }

  void _newGpsPositon(Position p) {
    if (!_bleActive) {
      inject.add(Pos(p.latitude, p.longitude));
    }
  }

  void _newBlePosition(Pos p) {
    inject.add(p);
    _resetTimer();
    _bleActive = true;
  }

  void _resetTimer() {
    _t.cancel();
    _t = Timer(const Duration(seconds: 20), () => _bleActive = false);
  }
}
