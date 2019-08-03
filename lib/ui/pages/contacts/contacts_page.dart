import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
// import 'package:webview_flutter/webview_flutter.dart';

import '../fullscreen_images/fullscreen_images_page.dart';

import '../../dialogs/dialogs.dart';

import '../../resources/app_colors.dart';

import '../../../storage/repository.dart';

class ContactsPage extends StatefulWidget  {
  
  ContactsPage();

  @override
  ContactsPageState createState() => ContactsPageState();
}

class ContactsPageState extends State<ContactsPage> with AutomaticKeepAliveClientMixin {

  @override
  void initState() {
    super.initState(); 
  }

  @override
  bool get wantKeepAlive => true;

  Widget buildHtml() {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Container(
      padding: EdgeInsets.only(top: 10),
      child: Column(
        children: <Widget>[
          ExpansionTile(
            title: Container(
              child: Text('Дирекция особо охраняемых природных территорий Ленинградской области филиал Ленинградского областного государственного казенного учреждения Управление лесами Ленинградской области',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14
                ),
              ),
            ),
            children: <Widget>[ 
              Container(
                child: Image(
                  image: AssetImage('assets/data/src/logo_4.jpg'),
                ),
              ),
            ]
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildHtml();
  }
}