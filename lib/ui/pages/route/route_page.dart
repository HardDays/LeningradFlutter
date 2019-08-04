import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'route_bloc.dart';

import '../map/map_page.dart';
import '../fullscreen_images/fullscreen_images_page.dart';

import '../../dialogs/dialogs.dart';

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

  final bloc = RouteListPageBloc();

  GoogleMapController mapController;
  
  @override
  void initState() {
    super.initState(); 

    bloc.load(widget.route.id);
  }

  void onMapComplete(GoogleMapController controller, List<Place> places) {
    mapController = controller;
    centerMap(places);
  }

  void centerMap(List<Place> places) {
    double minLat = 1000;
    double minLng = 1000;
    double maxLat = -1000;
    double maxLng = -1000;
    for (final place in places) {
      minLat = min(minLat, place.lat);
      minLng = min(minLng, place.lng);
      maxLat = max(maxLat, place.lat);
      maxLng = max(maxLng, place.lng);
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
                return Container(
                  width: width,
                  height: height * 0.6,
                  padding: EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 15),
                  child: Stack(
                    children: [ 
                      GoogleMap(
                        mapType: MapType.normal,
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
                          onMapComplete(controller, snapshot.data);
                        },
                        markers:  List.generate(snapshot.data.length,
                          (index) { 
                            return Marker(
                              markerId: MarkerId(index.toString()),
                              position: LatLng(snapshot.data[index].lat, snapshot.data[index].lng),
                              infoWindow: InfoWindow(
                                title: snapshot.data[index].name ?? 'Место',
                                snippet: snapshot.data[index].description ?? ''
                              )
                            );
                          }
                        ).toSet(),
                        polylines: List.generate(snapshot.data.length - 1, 
                          (index) {
                            return Polyline(
                              polylineId: PolylineId(index.toString()),
                              color: Colors.red,
                              width: 2,
                              patterns: [PatternItem.dash(15), PatternItem.gap(10)],
                              points: [
                                LatLng(snapshot.data[index].lat, snapshot.data[index].lng),
                                LatLng(snapshot.data[index + 1].lat, snapshot.data[index + 1].lng)
                              ]
                            );
                          }
                        ).toSet()
                        //polygons: oopt.where((p) => p.points.isNotEmpty).map((p) => buildPolygon(p)).toSet(),
                      ),
                      Container(
                        alignment: Alignment.bottomCenter,
                        child: InkWell(
                          onTap: () {
                            centerMap(snapshot.data);
                          },
                          child: Container(
                            padding: EdgeInsets.all(10),
                            margin: EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: AppColors.blue,
                              borderRadius: BorderRadius.all(Radius.circular(10))
                            ),
                            child: Text('Центрировать',
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