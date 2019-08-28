import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:leningrad_green/models/oopt.dart';

import 'route_map_bloc.dart';

import '../map/map_page.dart';
import '../fullscreen_images/fullscreen_images_page.dart';

import '../../dialogs/dialogs.dart';

import '../../resources/markers.dart';
import '../../resources/app_colors.dart';

import '../../../models/route.dart' as r;
import '../../../models/place.dart';

import '../../../storage/repository.dart';

class RouteMapPage extends StatefulWidget {
  final r.Route route;
  
  RouteMapPage(this.route);

  @override
  RouteMapPageState createState() => RouteMapPageState();
}

class RouteMapPageState extends State<RouteMapPage> {

  final bloc = RouteMapPageBloc();

  GoogleMapController mapController;
  
  @override
  void initState() {
    super.initState(); 

    bloc.load(widget.route);
  }

  void onMapComplete(GoogleMapController controller, List<List<r.Point>> places) async {
    mapController = controller;
    await Future.delayed(Duration(seconds: 1));
    centerMap(places);
  }

  void centerMap(List<List<r.Point>> places) {
    double minLat = 1000;
    double minLng = 1000;
    double maxLat = -1000;
    double maxLng = -1000;
    for (final pp in places) {
      for (final place in pp) {
        minLat = min(minLat, place.x);
        minLng = min(minLng, place.y);
        maxLat = max(maxLat, place.x);
        maxLng = max(maxLng, place.y);
      }
    }
    mapController.moveCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          northeast: LatLng(maxLat, maxLng),
          southwest: LatLng(minLat, minLng)
        ),
      50)
    );
  }

  PreferredSize buildAppBar() {
    return PreferredSize( 
      preferredSize: Size(0, 50),
      child: AppBar(
        backgroundColor: AppColors.blue,
        centerTitle: true,
        title: Text('Маршрут'),
        actions: <Widget>[
         InkWell(
            onTap: () {
              bloc.changeMapType();
            },
            child: Container(
              color: Colors.transparent,
              alignment: Alignment.center,
              padding: EdgeInsets.only(right: 10, top: 5, left: 5, bottom: 5),
              child: Text(bloc.satelite.value && bloc.satelite.hasValue ? 'Схема' : 'Спутник',
                style: TextStyle(
                  color: Colors.white
                ),
              )
            )
          )
        ]
      )
    );
  }

  List<Polyline> buildPolylines(List<List<r.Point>> points) {
    List<Polyline> polylines = [];
    for (int i = 0; i < points.length; i++) {
      for (int k = 0; k < points[i].length - 1; k++) {
        polylines.add(
          Polyline(
            polylineId: PolylineId('poly' + i.toString() + k.toString()),
            color: AppColors.blue,
            patterns: [PatternItem.dash(15), PatternItem.gap(10)],
            points: [
              LatLng(points[i][k].x, points[i][k].y),
              LatLng(points[i][k + 1].x, points[i][k + 1].y)
            ]
          )
        );
      }
    }
    return polylines;
  }

  List<Marker> buildMarkers(List<Place> places, List<List<r.Point>> points) {
    final markers = List.generate(places.length,
      (index) {
        return Marker(
          anchor: Offset(0.5, 0.5),
          markerId: MarkerId(index.toString()),
          icon: BitmapDescriptor.fromBytes(Markers().marker(places[index].type)),
          position: LatLng(places[index].lat, places[index].lng),
          infoWindow: InfoWindow(
            title: places[index].name ?? 'Место',
            snippet: places[index].description ?? ''
          )
        );
      }
    );
    int cur = 0;
    for (int i = 0; i < points.length; i++) {
      for (int k = 0; k < points[i].length; k++) {
        if (cur % 5 == 0 && points[i][k].angle != null) {
          markers.add(
            Marker(
              anchor: Offset(0.5, 0.5),
              markerId: MarkerId('direction' + i.toString() + k.toString()),
              icon: BitmapDescriptor.fromBytes(Markers().marker('direction')),
              position: LatLng(points[i][k].x, points[i][k].y),
              rotation: points[i][k].angle
            )
          );
        }
        cur++;
      }
    }
    return markers;
  }

  Widget buildBody() {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Container(
      child: StreamBuilder(
        stream: bloc.places.stream,
        builder: (BuildContext context, AsyncSnapshot<List<Place>> snapshot) {
          if (snapshot.hasData) {
            return StreamBuilder(
              stream: bloc.polyline.stream,
              builder: (BuildContext context, AsyncSnapshot<List<List<r.Point>>> polySnapshot) {
                if (polySnapshot.hasData) {
                 return StreamBuilder(
                    stream: bloc.satelite,
                    builder: (BuildContext context, AsyncSnapshot<bool> sateliteSnapshot) {
                      return Container(
                        width: width,
                        //padding: EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 15),
                        child: Stack(
                          children: [
                            GoogleMap(
                              mapType: sateliteSnapshot.hasData && sateliteSnapshot.data ? MapType.satellite : MapType.normal,
                              myLocationEnabled: true,
                              initialCameraPosition: CameraPosition(
                                target: LatLng(59.90271, 30.24700),
                                zoom: 10,
                              ),
                              onTap: (p) {
                                //bloc.hideInfoWindow();
                              },
                              onCameraMove: (p) {
                                //bloc.hideInfoWindow();
                              },
                              onMapCreated: (controller) {
                                onMapComplete(controller, polySnapshot.data);
                              },
                              markers: buildMarkers(snapshot.data ?? [], polySnapshot.data ?? []).toSet(),
                              polylines: polySnapshot.hasData ?
                              buildPolylines(polySnapshot.data).toSet() :
                              Set()
                            )
                          ]
                        )
                      );
                    }
                  );
                } else {
                  return Container();
                }
              }
            );
          } else {
            return Container();
          }
        }
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: buildBody()
    );
  }
}