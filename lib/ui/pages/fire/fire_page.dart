import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import 'fire_bloc.dart';

import '../../dialogs/dialogs.dart';

import '../../resources/app_colors.dart';
import '../../resources/markers.dart';

import '../../../storage/repository.dart';

class FirePage extends StatefulWidget {
  const FirePage({Key key}) : super(key: key);

  @override
  FirePageState createState() => FirePageState();
}

class FirePageState extends State<FirePage>  with AutomaticKeepAliveClientMixin {
  GoogleMapController mapController;
  final bloc = FirePageBloc();
  final markers = Markers();

  @override
  void initState() {
    super.initState(); 

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        Timer(Duration(seconds: 4),
          () {
            if (!bloc.repository.readFireMessage && mounted) {
              Dialogs.showMessage(context, 'Сообщение о пожаре', 'Если функция определения местоположения активна, Вы можете отправить уведомление о пожаре, нажав на маркер краного "цвета. В появившемся информационном окне нажмите кнопку отправить для того чтобы проинформировать РПДУ о возникновении пожара в пределах вашего текущего местоположения.', 'Закрыть');
              bloc.readMessage();
            }
          }
        );
      }
    );
    //bloc.load();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  void onMapComplete(GoogleMapController controller) {
    bloc.load();
    mapController = controller;
    if (bloc.position.value != null) {
      controller.moveCamera(CameraUpdate.newLatLng(LatLng(bloc.position.value.latitude, bloc.position.value.longitude)));
      //bloc.load();
    }
  }

  void onMarkerClick() async {
    final geolocator = Geolocator();
    final status = await geolocator.checkGeolocationPermissionStatus();
    final enabled = await geolocator.isLocationServiceEnabled();
    if (status == GeolocationStatus.granted && enabled) {
      final point = await geolocator.getCurrentPosition();
      Dialogs.showYesNo(context, 'Уведомление о пожаре', 
        'Ваши координаты: \n${point.latitude.toStringAsFixed(6)}; ${point.longitude.toStringAsFixed(6)} \nВыберите способ отправки сообщения (оплата сообщения происходит в соответствии с тарифом вашего оператора)\nУказанные Вами координаты будут отправлены в региональный пункт диспетчерского управления (РПДУ) для принятия мер по устранению очага возгорания', 
        'SMS', 'EMAIL',
        () {
          launch('sms:89219089111?body=Координаты: ${point.latitude.toStringAsFixed(6)}; ${point.longitude.toStringAsFixed(6)}');
        },
        () {
          launch('mailto:forestfire_logbu@mail.ru?subject=Уведомление о пожаре&body=Координаты: ${point.latitude.toStringAsFixed(6)}; ${point.longitude.toStringAsFixed(6)}');
        }
      );
    }
  }

  Marker buildMarker(Position pos) {
    final fire = 'fire';
    return Marker(
      markerId: MarkerId(fire),
      icon: BitmapDescriptor.fromBytes(markers.marker(fire)),
      position: LatLng(pos.latitude, pos.longitude),
      onTap: onMarkerClick
    );
  }


  Widget buildMap() {
    return StreamBuilder(
      stream: bloc.position.stream,
      builder: (BuildContext context, AsyncSnapshot<Position> snapshot) { 
        if (snapshot.hasData) {
          mapController?.moveCamera(CameraUpdate.newLatLng(LatLng(snapshot.data.latitude, snapshot.data.longitude)));
        }
        return GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
            target: snapshot.hasData ? LatLng(snapshot.data.latitude, snapshot.data.longitude) : LatLng(59.90271, 30.24700),
            zoom: 15,
          ),
          onTap: (p) {
            //bloc.hideInfoWindow();
          },
          myLocationEnabled: true,
          onCameraMove: (p) {
            //bloc.hideInfoWindow();
          },
          onMapCreated: onMapComplete,
          markers: snapshot.hasData ? [buildMarker(snapshot.data)].toSet() : Set(),
        );
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
      child: Stack(
         children: [
           buildMap(),
         ]
      )
    );
  }
}