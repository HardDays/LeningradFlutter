import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'route_list_bloc.dart';

import '../route/route_page.dart';

import '../../resources/app_colors.dart';
import '../../resources/markers.dart';

import '../../../models/route.dart' as r;

class RouteListPage extends StatefulWidget {
  const RouteListPage({Key key}) : super(key: key);

  @override
  RouteListPageState createState() => RouteListPageState();
}

class RouteListPageState extends State<RouteListPage>  with AutomaticKeepAliveClientMixin {
  final bloc = RouteListPageBloc();

  @override
  void initState() {
    super.initState(); 

    bloc.load();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;


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

  Widget buildSearch() {
    return Container(
      height: 35,
      margin: EdgeInsets.only(left: 7, right: 7, top: 10, bottom: 5),
      child: TextField(
        style: TextStyle(
          fontSize: 16
        ),
        onChanged: (text) {
          //bloc.search(text);
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(top: 8, bottom: 8, left: 10, right: 10),
          hintText: 'Поиск',
          focusedBorder: OutlineInputBorder(  
            borderRadius: BorderRadius.all(Radius.circular(5)),        
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),   
          ),
          enabledBorder: OutlineInputBorder(    
            borderRadius: BorderRadius.all(Radius.circular(5)),    
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),   
          ),   
        ),
      )
    );
  }

  Widget buildList(List<r.Route> list) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Expanded(
      child: Container(
        child: ListView(
          children: List.generate(list.length, 
            (index) {
              return InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute<Null>(builder: (t) => RoutePage(list[index])));
                },
                child: Container(
                  padding: EdgeInsets.only(left: 15, right: 15, top: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        height: height * 0.25,
                        width: width,
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          child: Image(
                            fit: BoxFit.cover,
                            image: list[index].image != null ? 
                            MemoryImage(list[index].image.compressedData) :
                            AssetImage('assets/images/intro/intro_pic8.jpg')
                          )
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 5, left: 5),
                        child: Text(list[index].name ?? 'Маршрут',
                          style: TextStyle(
                            fontSize: 18
                          ),
                        ),
                      ),
                      Divider()
                    ],
                  )
                )
              );
            }
          )
        ),
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
        stream: bloc.routes,
        builder: (BuildContext context, AsyncSnapshot<List<r.Route>> snapshot) { 
          if (snapshot.hasData) {
            return Column(
              children: [
                //buildSearch(),
                Padding(padding: EdgeInsets.only(top: 10)),
                buildList(snapshot.data)
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