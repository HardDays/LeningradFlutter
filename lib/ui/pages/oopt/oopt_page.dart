import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
// import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';

import 'oopt_bloc.dart';

import '../fullscreen_images/fullscreen_images_page.dart';

import '../../dialogs/dialogs.dart';

import '../../resources/app_colors.dart';

import '../../../models/oopt.dart';
import '../../../models/oopt_image.dart';

import '../../../storage/repository.dart';

class OoptPage extends StatefulWidget {
  final Oopt oopt;
  
  OoptPage(this.oopt);

  @override
  OoptPageState createState() => OoptPageState();
}

class OoptPageState extends State<OoptPage> {

  final bloc = OoptPageBloc();

  final imagesController = PageController();

  //WebViewController controller;

  @override
  void initState() {
    super.initState(); 
  }

  void onInfo(OoptImage image) {
    Dialogs.showMessage(context, 'Автор', image.author, 'Закрыть');
  }

  void onFullScreen() {
    Navigator.push(context, MaterialPageRoute<Null>(builder: (t) => FullscreenImagesPage(widget.oopt, bloc.currentImage.value ?? 0)));
  }

  PreferredSize buildAppBar() {
    return PreferredSize( 
      preferredSize: Size(0, 50),
      child: AppBar(
        backgroundColor: AppColors.blue,
        centerTitle: true,
        title: Text('ООПТ'),
      )
    );
  }

  Widget buildImages() {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Container(
      width: width,
      height: height * 0.3,
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
                      height: height * 0.3,
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
                  onTap: onFullScreen,
                  child: Container(
                    padding: EdgeInsets.only(bottom: 5),
                    child: Icon(CupertinoIcons.fullscreen,
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

  Widget buildHtml() {
    return Expanded(
      child: InAppWebView(
        initialFile: widget.oopt.html,
        initialOptions: {
          'textZoom': 100,
          'useWideViewPort': false
        },
        onLoadStart: (controller, link) {
          try {
            final path = link.split('/').sublist(5).join('/');
            if (path != widget.oopt.html) {
              controller.stopLoading();
              controller.loadFile(widget.oopt.html);
            }
          } catch (ex) {
            controller.stopLoading();
            controller.loadFile(widget.oopt.html);
          }
        },
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    for (final image in widget.oopt.images) {
      precacheImage(AssetImage(image.link), context);
    }
    return Scaffold(
      appBar: buildAppBar(),
      body: Column(
        children: <Widget>[
          buildImages(),
          buildHtml()
        ],
      )
    );
  }
}