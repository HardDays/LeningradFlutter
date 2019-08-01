import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';

import 'fullscreen_images_bloc.dart';

import '../../dialogs/dialogs.dart';

import '../../resources/app_colors.dart';

import '../../../models/oopt.dart';
import '../../../models/oopt_image.dart';

class FullscreenImagesPage extends StatefulWidget {
  final int currentImage;
  final Oopt oopt;
  
  FullscreenImagesPage(this.oopt, this.currentImage);

  @override
  FullscreenImagesPageState createState() => FullscreenImagesPageState();
}

class FullscreenImagesPageState extends State<FullscreenImagesPage> {

  final bloc = FullscreenImagesBloc();

  PageController imagesController;

  @override
  void initState() {
    super.initState(); 

    imagesController = PageController(initialPage: widget.currentImage);
    bloc.changeImage(widget.currentImage);

    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.landscapeRight,
        //DeviceOrientation.landscapeLeft,
      ]
    );
    SystemChrome.setEnabledSystemUIOverlays ([]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitUp,
      ]
    );
    SystemChrome.setEnabledSystemUIOverlays(
      [
        SystemUiOverlay.top,
        SystemUiOverlay.bottom
      ]
    );
    super.dispose(); 
  }

  void onInfo(OoptImage image) {
    Dialogs.showMessage(context, 'Автор', image.author, 'Закрыть');
  }

  PreferredSize buildAppBar() {
    return PreferredSize( 
      preferredSize: Size(0, 0),
      child: AppBar()
    );
  }

  Widget buildImages() {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Container(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView(
            onPageChanged: (index) {
              bloc.changeImage(index);
            },
            controller: imagesController,
            children: List.generate(widget.oopt.images.length, 
              (index) {
                return Stack(
                  children: [
                    Image(
                      width: width,
                      height: height,
                      fit: BoxFit.cover,
                      image: AssetImage(widget.oopt.images[index].link),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withOpacity(0.25)
                          ]
                        )
                      ),
                    ),
                  ]
                );
              }
            )
          ),
          Container(
            padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    onInfo(widget.oopt.images[bloc.currentImage.value ?? 0]);
                  },
                  child: Container(
                    child: Icon(CupertinoIcons.info,
                      color: Colors.white.withOpacity(0.75),
                      size: 28,
                    )
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.oopt.images.length, 
                    (index) {
                      return StreamBuilder(
                        stream: bloc.currentImage.stream,
                        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                          return Container(
                            width: 11,
                            height: 11,
                            margin: EdgeInsets.only(right: 2, left: 2),
                            decoration: BoxDecoration(
                              color: snapshot.hasData && snapshot.data == index ? AppColors.blue : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withOpacity(0.75), width: 1)
                            ),
                          );
                        }
                      );
                    }
                  )
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: EdgeInsets.only(bottom: 5),
                    child: Icon(CupertinoIcons.fullscreen_exit,
                      color: Colors.white.withOpacity(0.75),
                      size: 28,
                    )
                  ),
                ),
              ]
            ),
          )
        ]
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: Column(
        children: <Widget>[
          Expanded(child: buildImages())
        ],
      )
    );
  }
}