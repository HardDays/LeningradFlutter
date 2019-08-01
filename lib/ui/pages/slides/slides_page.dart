import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';

import '../fullscreen_slides/fullscreen_slides_page.dart';

import '../../dialogs/dialogs.dart';

import '../../resources/app_colors.dart';

import '../../../storage/repository.dart';

class SlidesPage extends StatefulWidget {
  
  SlidesPage();

  @override
  SlidesPageState createState() => SlidesPageState();
}

class SlidesPageState extends State<SlidesPage> {

  @override
  void initState() {
    super.initState(); 
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Container(
      child: Stack(
        children: <Widget>[
          Image(
            fit: BoxFit.cover,
            width: width,
            height: height,
            image: AssetImage('assets/images/intro/intro_pic8.jpg'),
          ),
          Container(
            width: width,
            height: height,
            alignment: Alignment.center,
            padding: EdgeInsets.only(bottom: 40),
            child: InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute<Null>(builder: (t) => FullscreenSlidesPage()));
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.blue,
                      shape: BoxShape.circle
                    ),
                    padding: EdgeInsets.all(5),
                    child: Icon(Icons.play_arrow,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.blue,
                      borderRadius: BorderRadius.all(Radius.circular(10))
                    ),
                    margin: EdgeInsets.only(top: 12),
                    padding: EdgeInsets.all(10),
                    child: Text('Начать показ',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white
                      ),
                    ),
                  )
                ],
              )
            ),
          )
        ],
      ),
    );
  }
}