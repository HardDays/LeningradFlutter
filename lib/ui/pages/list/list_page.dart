import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'list_bloc.dart';

import '../oopt/oopt_page.dart';

import '../../resources/app_colors.dart';
import '../../resources/markers.dart';

import '../../../models/oopt.dart';

class ListPage extends StatefulWidget {
  const ListPage({Key key}) : super(key: key);

  @override
  ListPageState createState() => ListPageState();
}

class ListPageState extends State<ListPage>  with AutomaticKeepAliveClientMixin {
  final bloc = ListPageBloc();

  final categories = {
    OoptCategory.naturalPark: 'Природный парк',
    OoptCategory.naturalMonument: 'Памятник природы',
    OoptCategory.wildlifeSanctuary: 'Заказник',
  };

  final circleColors = {
    OoptCategory.naturalPark: Colors.yellow,
    OoptCategory.naturalMonument: Colors.green,
    OoptCategory.wildlifeSanctuary: Colors.blue,
  };

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

  void onOopt(Oopt oopt) {
    Navigator.push(context, MaterialPageRoute<Null>(builder: (t) => OoptPage(oopt)));
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

  Widget buildSearch() {

  }

  Widget buildList(List<Oopt> list) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: List.generate(list.length, 
            (index) {
              final oopt = list[index];
              return Container(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: InkWell(
                  onTap: () {
                    onOopt(oopt);
                  },
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            child: Image(
                              width: width * 0.3,
                              height: width * 0.3,
                              fit: BoxFit.cover,
                              image: AssetImage(oopt.images.first.link),
                            ),
                          ),
                          Flexible(
                            child: Container(
                              padding: EdgeInsets.only(left: 7, right: 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Flexible(
                                        child: Text(oopt.name,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600
                                          ),
                                        )
                                      ),
                                      Container(
                                        width: 12,
                                        height: 12,
                                        margin: EdgeInsets.only(top: 5),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: circleColors[oopt.category]
                                        ),
                                      )
                                    ]
                                  ),
                                  Padding(padding: EdgeInsets.only(top: 5)),
                                  Text(categories[oopt.category],
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400
                                    ),
                                  ),
                                  Padding(padding: EdgeInsets.only(top: 7)),
                                  Text('Местоположение: ',
                                    style: TextStyle(
                                      color: Colors.black.withOpacity(0.7),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w300
                                    ),
                                  ),
                                  Padding(padding: EdgeInsets.only(top: 2)),
                                  Text('Дата создания: ${DateFormat('dd.MM.yyy').format(oopt.date)}',
                                    style: TextStyle(
                                      color: Colors.black.withOpacity(0.7),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w300
                                    ),
                                  ),
                                  Padding(padding: EdgeInsets.only(top: 2)),
                                  Text('Площадь: ${oopt.square} га',
                                    style: TextStyle(
                                      color: Colors.black.withOpacity(0.7),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w300
                                    ),
                                  ),
                                ],
                              ),
                            )
                          )
                        ]
                      ),
                      Divider()
                    ],
                  )
                )
              );
            }
          )
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
            return Column(
              children: [
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