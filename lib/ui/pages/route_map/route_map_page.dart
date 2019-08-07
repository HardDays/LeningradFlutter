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

  void onMapComplete(GoogleMapController controller, List<Point> places) async {
    mapController = controller;
    await Future.delayed(Duration(seconds: 1));
    centerMap(places);
  }

  void centerMap(List<Point> places) {
    double minLat = 1000;
    double minLng = 1000;
    double maxLat = -1000;
    double maxLng = -1000;
    for (final place in places) {
      minLat = min(minLat, place.x);
      minLng = min(minLng, place.y);
      maxLat = max(maxLat, place.x);
      maxLng = max(maxLng, place.y);
    }

    if (places.length == 1) {
      mapController.moveCamera(CameraUpdate.newLatLngZoom(LatLng(maxLat, maxLng), 12));
    } else {
      mapController.moveCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            northeast: LatLng(maxLat, maxLng), 
            southwest: LatLng(minLat, minLng)
          ), 
        50)
      );
    }
  }

  PreferredSize buildAppBar() {
    return PreferredSize( 
      preferredSize: Size(0, 50),
      child: AppBar(
        backgroundColor: AppColors.blue,
        centerTitle: true,
        title: Text('Маршрут'),
        actions: <Widget>[
         
        ]
      )
    );
  }

  Widget buildBody() {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Container(
      child: StreamBuilder(
        stream: bloc.places.stream,
        builder: (BuildContext context, AsyncSnapshot<List<Place>> snapshot) {
          if (snapshot.hasData && snapshot.data.isNotEmpty) {
            return StreamBuilder(
              stream: bloc.polyline.stream,
              builder: (BuildContext context, AsyncSnapshot<List<Point>> polySnapshot) {
                if (polySnapshot.hasData) {
                  return Container(
                    width: width,
                    //padding: EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 15),
                    child: Stack(
                      children: [ 
                        GoogleMap(
                          mapType: MapType.normal,
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
                          markers:  List.generate(snapshot.data.length,
                            (index) { 
                              return Marker(
                                markerId: MarkerId(index.toString()),
                                icon: BitmapDescriptor.fromBytes(Markers().marker(snapshot.data[index].type)),
                                position: LatLng(snapshot.data[index].lat, snapshot.data[index].lng),
                                infoWindow: InfoWindow(
                                  title: snapshot.data[index].name ?? 'Место',
                                  snippet: snapshot.data[index].description ?? ''
                                )
                              );
                            }
                          ).toSet(),
                          polylines: polySnapshot.hasData ? 
                          List.generate(polySnapshot.data.length - 1, 
                            (index) {
                              return Polyline(
                                polylineId: PolylineId(index.toString()),
                                color: AppColors.blue,
                                //width: 1,
                                patterns: [PatternItem.dash(15), PatternItem.gap(10)],
                                points: [
                                  LatLng(polySnapshot.data[index].x, polySnapshot.data[index].y),
                                  LatLng(polySnapshot.data[index + 1].x, polySnapshot.data[index + 1].y)
                                ]
                              );
                            }
                          ).toSet() :
                          Set()
                        )
                      ]
                    )
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