import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:leningrad_green/models/oopt.dart';

import 'route_bloc.dart';

import '../route_map/route_map_page.dart';
import '../fullscreen_images/fullscreen_images_page.dart';

import '../../dialogs/dialogs.dart';

import '../../resources/markers.dart';
import '../../resources/app_colors.dart';

import '../../../models/route.dart' as r;
import '../../../models/place.dart';

import '../../../storage/repository.dart';

class RoutePage extends StatefulWidget {
  final r.Route route;
  
  RoutePage(this.route);

  @override
  RoutePageState createState() => RoutePageState();
}

class RoutePageState extends State<RoutePage> {

  final bloc = RoutePageBloc();

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
              child: Text(bloc.satelite.value ? 'Схема' : 'Спутник',
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

  Widget buildImage() {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Container(
      width: width,
      height: height * 0.3,
      child: Image(
        fit: BoxFit.cover,
        image: widget.route.image != null ? 
        MemoryImage(widget.route.image.compressedData) :
        AssetImage('assets/images/intro/intro_pic8.jpg')
      ),
    );
  }

  List<Polyline> buildPolylines(List<List<r.Point>> points) {
    List<Polyline> polylines = [];
    for (int i = 0; i < points.length; i++) {
      for (int k = 0; k < points[i].length - 1; k++) {
        polylines.add(
          Polyline(
            polylineId: PolylineId(i.toString() + k.toString()),
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

  Widget buildBody() {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 10, left: 15, right: 15),
            child: Text(widget.route.name ?? 'Маршрут',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 10, left: 15, right: 15),
            child: Text(widget.route.description ?? '',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black.withOpacity(0.75),
                fontWeight: FontWeight.w300
              ),
            ),
          ),
          StreamBuilder(
            stream: bloc.places.stream,
            builder: (BuildContext context, AsyncSnapshot<List<Place>> snapshot) {
              if (snapshot.hasData) {
                return StreamBuilder(
                  stream: bloc.polyline.stream,
                  builder: (BuildContext context, AsyncSnapshot<List<List<r.Point>>> polySnapshot) {
                    if (polySnapshot.hasData) {
                      return Container(
                        width: width,
                        height: height * 0.6,
                        padding: EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 15),
                        child: Stack(
                          children: [ 
                            StreamBuilder(
                              stream: bloc.satelite,
                              builder: (BuildContext context, AsyncSnapshot<bool> sateliteSnapshot) {
                                return GoogleMap(
                                  mapType: sateliteSnapshot.data == true ? MapType.satellite : MapType.normal,
                                  scrollGesturesEnabled: false,
                                  zoomGesturesEnabled: false,
                                  rotateGesturesEnabled: false,
                                  tiltGesturesEnabled: false,
                                  //myLocationEnabled: true,
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
                                        consumeTapEvents: true,
                                        infoWindow: InfoWindow(
                                          title: snapshot.data[index].name ?? 'Место',
                                          snippet: snapshot.data[index].description ?? ''
                                        )
                                      );
                                    }
                                  ).toSet(),
                                  polylines: polySnapshot.hasData ? 
                                  buildPolylines(polySnapshot.data).toSet() :
                                  Set()
                                  //polygons: oopt.where((p) => p.points.isNotEmpty).map((p) => buildPolygon(p)).toSet(),
                                );
                              }
                            ),
                            Container(
                              alignment: Alignment.bottomCenter,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute<Null>(builder: (t) => RouteMapPage(widget.route)));
                                },
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  margin: EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    color: AppColors.blue,
                                    borderRadius: BorderRadius.all(Radius.circular(10))
                                  ),
                                  child: Text('Открыть карту',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white
                                    ),
                                  ),
                                ),
                              ),
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
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            buildImage(),
            buildBody()
          ],
        )
      )
    );
  }
}