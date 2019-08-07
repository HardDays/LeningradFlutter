import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission/permission.dart';

import 'map_bloc.dart';

import '../oopt/oopt_page.dart';

import '../../resources/app_colors.dart';
import '../../resources/markers.dart';

import '../../../models/oopt.dart';

class MapPageController {

  bool satellite = false;
  Function onMapChange;

  void changeMap() {
    satellite = !satellite;
    onMapChange();
  }
}

class MapPage extends StatefulWidget {
  final MapPageController controller;
  final Oopt oopt;
  const MapPage({Key key, this.controller, this.oopt}) : super(key: key);

  @override
  MapPageState createState() => MapPageState();
}

class MapPageState extends State<MapPage>  with AutomaticKeepAliveClientMixin {
  final mapController = Completer();
  final bloc = MapPageBloc();
  final markers = Markers();

  final polyColors = {
    OoptCategory.naturalPark: Colors.yellow,
    OoptCategory.naturalMonument: Colors.green,
    OoptCategory.wildlifeSanctuary: Colors.blue,
  };

  final categories = {
    OoptCategory.naturalPark: 'Природный парк',
    OoptCategory.naturalMonument: 'Памятник природы',
    OoptCategory.wildlifeSanctuary: 'Заказник',
  };

  @override
  void initState() {
    super.initState(); 

    widget.controller.onMapChange = () {
      bloc.changeMapType();
    };

    bloc.load();

    Permission.requestPermissions([PermissionName.Location]);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  void onMapComplete(GoogleMapController controller) {
    if (!mapController.isCompleted) {
      mapController.complete(controller);
      if (widget.oopt != null) {
        controller.moveCamera(CameraUpdate.newLatLng(LatLng(widget.oopt.lat, widget.oopt.lng)));
        bloc.showInfoWindow(widget.oopt);
      }
      bloc.load();
    }
  }

  void onMarkerClick(Oopt oopt) {
    bloc.showInfoWindow(oopt);
  }

  void onOopt(Oopt oopt) {
    Navigator.push(context, MaterialPageRoute<Null>(builder: (t) => OoptPage(oopt)));
  }

  Marker buildMarker(Oopt oopt) {
    return Marker(
      markerId: MarkerId(oopt.id.toString()),
      icon: BitmapDescriptor.fromBytes(markers.marker(oopt.category)),
      position: LatLng(oopt.lat, oopt.lng),
      onTap: () {
        onMarkerClick(oopt);
      }
    );
  }

  Polygon buildPolygon(Oopt oopt) {
    final color = polyColors[oopt.category];
    return Polygon(
      polygonId: PolygonId(oopt.id.toString()),
      strokeColor: color,
      strokeWidth: 3,
      fillColor: color.withOpacity(0.25),
      points: oopt.points.map((p) => LatLng(p.x, p.y)).toList()
    );
  }

  Widget buildMap(List<Oopt> oopt) {
    return StreamBuilder(
      stream: bloc.satelite,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        return GoogleMap(
          myLocationEnabled: true,
          mapType: snapshot.data == true ? MapType.satellite : MapType.normal,
          initialCameraPosition: CameraPosition(
            target: LatLng(59.90271, 30.24700),
            zoom: widget.oopt == null ? 7 : 11,
          ),
          onTap: (p) {
            bloc.hideInfoWindow();
          },
          onCameraMove: (p) {
            bloc.hideInfoWindow();
          },
          onMapCreated: onMapComplete,
          markers: oopt.map((p) => buildMarker(p)).toSet(),
          polygons: oopt.where((p) => p.points.isNotEmpty).map((p) => buildPolygon(p)).toSet(),
        );
      }
    );
  }

  Widget buildInfoWindow() {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return StreamBuilder(
      stream: bloc.infowindow,
      builder: (BuildContext context, AsyncSnapshot<Oopt> snapshot) {
        if (snapshot.hasData) {
          final oopt = snapshot.data;
          return Container(
            height: height * 0.5,
            alignment: Alignment.bottomCenter,
            padding: EdgeInsets.only(bottom: 110, left: 40, right: 40),
            child: InkWell(
              onTap: () {
                onOopt(oopt);
              },
              child: Container(
                width: width * 0.6,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10))
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children:[ 
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.only(topRight: Radius.circular(10), topLeft: Radius.circular(10)),
                            child: Image(
                              width: width * 0.6,
                              height: height * 0.2,
                              fit: BoxFit.cover,
                              image: AssetImage(oopt.images.first.link),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 3),
                            child: Text(snapshot.data.name,
                              maxLines: 2,
                              overflow: TextOverflow.clip,
                              style: TextStyle(
                                fontSize: 18
                              ),
                            )
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 5, right: 5, bottom: 10),
                            child: Text(categories[oopt.category],
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey
                              ),
                            )
                          )
                        ]
                      )
                    )
                  ]
                ),
              )
            )
          );
        } else {
          return Container();
        }
      }
    );
  }

  Widget buildLoader() {
    return Container(
      alignment: Alignment.center,
      child: Container(
        child: CircularProgressIndicator(
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation(AppColors.blue)
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Container(
      width: width,
      height: height,
      child: StreamBuilder(
        stream: bloc.ootp,
        builder: (BuildContext context, AsyncSnapshot<List<Oopt>> snapshot) { 
          if (snapshot.hasData) {
            return Stack(
              children: [
                buildMap(snapshot.data),
                buildInfoWindow()
              ]
            );
          } else {
            return buildLoader();
          } 
        }
      )
    );
  }
}