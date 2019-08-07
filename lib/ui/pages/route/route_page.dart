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

  void onMapComplete(GoogleMapController controller, List<Point> places) {
    mapController = controller;
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
              if (snapshot.hasData && snapshot.data.isNotEmpty) {
                return StreamBuilder(
                  stream: bloc.polyline.stream,
                  builder: (BuildContext context, AsyncSnapshot<List<Point>> polySnapshot) {
                    if (polySnapshot.hasData) {
                      return Container(
                        width: width,
                        height: height * 0.6,
                        padding: EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 15),
                        child: Stack(
                          children: [ 
                            GoogleMap(
                              mapType: MapType.normal,
                              scrollGesturesEnabled: false,
                              zoomGesturesEnabled: false,
                              rotateGesturesEnabled: false,
                              tiltGesturesEnabled: false,
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
                                    icon: BitmapDescriptor.fromBytes(Markers().marker(OoptCategory.wildlifeSanctuary)),
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
                              //polygons: oopt.where((p) => p.points.isNotEmpty).map((p) => buildPolygon(p)).toSet(),
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