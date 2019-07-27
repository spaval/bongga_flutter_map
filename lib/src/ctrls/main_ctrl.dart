import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:rxdart/rxdart.dart';
import 'package:bongga_flutter_map/src/states/polygon_state.dart';
import 'package:bongga_flutter_map/src/states/marker_state.dart';
import 'package:bongga_flutter_map/src/states/line_state.dart';
import 'package:bongga_flutter_map/src/states/map_state.dart';
import 'package:bongga_flutter_map/src/models/main_ctrl_model.dart';
import 'package:latlong/latlong.dart';

class MainController {
  final MapController mapCtrl;
  final Completer<Null> _completer = Completer<Null>();
  final _subject = PublishSubject<MainControllerChange>();

  MapOptions mapOpts;
  MapState _mapState;
  MarkerState _markerState;
  LineState _lineState;
  PolygonState _polygonState;

  MainController({ @required this.mapCtrl }) : assert(mapCtrl != null) {

    _markerState = MarkerState(mapController: mapCtrl, notify: notify);
    _lineState = LineState(notify: notify);
    _polygonState = PolygonState(notify: notify);

    _mapState = MapState(
      mapController: mapCtrl,
      notify: notify,
      markerState: _markerState
    );

    mapCtrl.onReady.then((_) {
      // fire the map is ready callback
      if (!_completer.isCompleted) {
        _completer.complete();
      }
    });
  }

  /// On ready callback: this is fired when the contoller is ready
  Future<Null> get onReady => _completer.future;

  /// A stream with changes occuring on the map
  Observable<MainControllerChange> get changes => _subject.distinct();

  /// The map zoom value
  double get zoom => mapCtrl.zoom;

  /// The map center value
  LatLng get center => mapCtrl.center;

  /// The markers present on the map
  List<Marker> get markers => _markerState.markers;

  /// The markers present on the map and their names
  Map<String, Marker> get namedMarkers => _markerState.namedMarkers;

  /// The lines present on the map
  List<Polyline> get lines => _lineState.lines;

  /// The polygons present on the map
  List<Polygon> get polygons => _polygonState.polygons;

  /// Zoom in one level
  Future<void> zoomIn() => _mapState.zoomIn();

  /// Zoom out one level
  Future<void> zoomOut() => _mapState.zoomOut();

  /// Zoom to level
  Future<void> zoomTo(double value) => _mapState.zoomTo(value);

  /// Center the map on a [LatLng]
  Future<void> centerOnPoint(LatLng point) => _mapState.centerOnPoint(point);

  /// The callback used to handle gestures and keep the state in sync
  void onPositionChanged(MapPosition pos, bool gesture) {
    _mapState.onPositionChanged(pos, gesture);
  }
    
  /// Add a marker on the map
  Future<void> addMarker({ @required Marker marker, @required String name }) async {
    _markerState.addMarker(marker: marker, name: name);
  }
    
  /// Remove a marker from the map
  Future<void> removeMarker({@required String name}) async {
    _markerState.removeMarker(name: name);
  }
      

  /// Add multiple markers to the map
  Future<void> addMarkers({@required Map<String, Marker> markers}) async {
     _markerState.addMarkers(markers: markers);
  }

  /// Remove multiple makers from the map
  Future<void> removeMarkers({@required List<String> names}) async {
    _markerState.removeMarkers(names: names);
  }
      
  /// Add a line on the map
  Future<void> addLine({ 
    @required String name,
    @required List<LatLng> points,
    double width = 1.0,
    Color color = Colors.green,
    bool isDotted = false
  }) async {
    _lineState.addLine(
      name: name,
      points: points,
      color: color,
      width: width,
      isDotted: isDotted
    );
  }

  /// Add a polygon on the map
  Future<void> addPolygon({
    @required String name,
    @required List<LatLng> points,
    Color color = const Color(0xFF00FF00),
    double borderWidth = 0.0,
    Color borderColor = const Color(0xFFFFFF00)
  }) async {
    _polygonState.addPolygon(
      name: name,
      points: points,
      color: color,
      borderWidth: borderWidth,
      borderColor: borderColor
    );
  }
    
  /// Notify to the stream
  void notify(String name, dynamic value, Function from) {
    final change = MainControllerChange(
      name: name, 
      value: value, 
      from: from
    );
    
    _subject.add(change);
  }
}