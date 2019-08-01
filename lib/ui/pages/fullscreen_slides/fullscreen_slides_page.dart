import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'fullscreen_slides_bloc.dart';

import '../oopt/oopt_page.dart';

import '../../dialogs/dialogs.dart';

import '../../resources/app_colors.dart';

import '../../../models/oopt.dart';
import '../../../models/oopt_image.dart';

class FullscreenSlidesPage extends StatefulWidget {
  FullscreenSlidesPage();

  @override
  FullscreenSlidesPageState createState() => FullscreenSlidesPageState();
}

class FullscreenSlidesPageState extends State<FullscreenSlidesPage> {

  final bloc = FullscreenSlidesBloc();

  Timer timer;

  PageController imagesController;

  @override
  void initState() {
    super.initState(); 

    imagesController = PageController();

    bloc.load();

    timer = Timer.periodic(Duration(seconds: 7), 
      (t) {
        if (bloc.play.value && mounted) {
          imagesController.nextPage(duration: Duration(seconds: 1), curve: Curves.ease);
        }
      }
    );

    hideOVerlay();
  }

  @override
  void dispose() {
    showOverlay();
    timer.cancel();
    super.dispose(); 
  }

  void showOverlay() {
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
  }

  void hideOVerlay() {
    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.landscapeRight,
        //DeviceOrientation.landscapeLeft,
      ]
    );
    SystemChrome.setEnabledSystemUIOverlays ([]);
  }

  void onInfo(OoptImage image) async {
    showOverlay();
    await Navigator.push(context, MaterialPageRoute<Null>(builder: (t) => OoptPage(bloc.ooptImages[image])));
    hideOVerlay();
  }

  void onPlay(bool value) {
    bloc.changePlay(value);
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
    return StreamBuilder(
      stream: bloc.images.stream,
      builder: (BuildContext context, AsyncSnapshot<List<OoptImage>> snapshot) {
        if (!snapshot.hasData) {
          return Container();
        } else {
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
                  children: List.generate(snapshot.data.length, 
                    (index) {
                      return Stack(
                        children: [
                          Image(
                            width: width,
                            height: height,
                            fit: BoxFit.cover,
                            image: AssetImage(snapshot.data[index].link),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          onInfo(snapshot.data[bloc.currentImage.value ?? 0]);
                        },
                        child: Container(
                          color: Colors.transparent,
                          margin: EdgeInsets.only(left: 15, right: 15, bottom: 10, top: 15),
                          child: Icon(Icons.menu,
                            color: Colors.white.withOpacity(0.75),
                            size: 28,
                          )
                        ),
                      ),
                      StreamBuilder(
                        stream: bloc.play.stream,
                        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) { 
                          final bool played = !snapshot.hasData || snapshot.data;
                          return InkWell(
                            onTap: () {
                              onPlay(!played);
                            },
                            child: Container(
                              margin: EdgeInsets.only(left: 15, right: 15, bottom: 10, top: 15),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(color: Colors.white),
                                shape: BoxShape.circle
                              ),
                              padding: EdgeInsets.all(5),
                              child: Icon(played ? Icons.pause : Icons.play_arrow,
                                color: Colors.white.withOpacity(0.75),
                                size: 22,
                              )
                            ),
                          );
                        }
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 15, right: 15, bottom: 10, top: 15),
                          padding: EdgeInsets.only(bottom: 5),
                          color: Colors.transparent,
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
      }
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