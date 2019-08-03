import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
// import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';

import 'oopt_bloc.dart';

import '../map/map_page.dart';
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

  final categories = {
    OoptCategory.naturalPark: 'Природный парк',
    OoptCategory.naturalMonument: 'Памятник природы',
    OoptCategory.wildlifeSanctuary: 'Заказник',
  };

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

  void onMap() {
    Navigator.push(context, 
      MaterialPageRoute<Null>(
        builder: (t) => Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.blue,
            centerTitle: true,
            title: Text('Карта'),
          ),
          body: MapPage(
            oopt: widget.oopt,
            controller: MapPageController(),
          ),
        )
      )
    );
  }

  PreferredSize buildAppBar() {
    return PreferredSize( 
      preferredSize: Size(0, 50),
      child: AppBar(
        backgroundColor: AppColors.blue,
        centerTitle: true,
        title: Text('ООПТ'),
        actions: <Widget>[
           InkWell(
             onTap: onMap,
             child: Container(
               color: Colors.transparent,
               alignment: Alignment.center,
               padding: EdgeInsets.only(right: 10, top: 5, left: 5, bottom: 5),
               child: Text('На карте',
                 style: TextStyle(
                   color: Colors.white
                 ),
               )
             )
           )
         ]
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

  // Widget buildHtml() {
  //   return Expanded(
  //     child: InAppWebView(
  //       initialFile: widget.oopt.html,
  //       initialOptions: {
  //         'textZoom': 100,
  //         'useWideViewPort': false
  //       },
  //       onLoadStart: (controller, link) {
  //         try {
  //           final path = link.split('/').sublist(5).join('/');
  //           if (path != widget.oopt.html) {
  //             controller.stopLoading();
  //             controller.loadFile(widget.oopt.html);
  //           }
  //         } catch (ex) {
  //           controller.stopLoading();
  //           controller.loadFile(widget.oopt.html);
  //         }
  //       },
  //     )
  //   );
  // }

  Widget buildBody() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 10, left: 15, right: 15),
            child: Text(widget.oopt.name,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 3, left: 15, right: 15),
            child: Text(categories[widget.oopt.category],
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 10, left: 15, right: 15),
            child: Text(widget.oopt.annotation,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black.withOpacity(0.75),
                fontWeight: FontWeight.w300
              ),
            ),
          ),
          widget.oopt.objectives.isNotEmpty ? 
          Container(
            color: Colors.grey.withOpacity(0.3),
            margin: EdgeInsets.only(top: 10),
            padding: EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Основные цели заказника:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black.withOpacity(1),
                    fontWeight: FontWeight.w500
                  )
                ),
                Padding(padding: EdgeInsets.only(top: 3)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(widget.oopt.objectives.length, 
                    (index) {
                      return Container(
                        padding: EdgeInsets.only(top: 3),
                        child: Text('- ' + widget.oopt.objectives[index],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black.withOpacity(1),
                            fontWeight: FontWeight.w300
                          ),
                        )
                      );
                    }
                  )
                )
              ]
            )
          ) :
          Container(),
          widget.oopt.features == null ?
          Container() :
          Container(
            color: widget.oopt.objectives.isNotEmpty ? Colors.transparent : Colors.grey.withOpacity(0.3),
            margin: EdgeInsets.only(top: 10),
            padding: EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
            child: Text(widget.oopt.features,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black.withOpacity(1),
                fontWeight: FontWeight.w300
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 10, left: 15, right: 15),
            child: Text(widget.oopt.description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black.withOpacity(0.75),
                fontWeight: FontWeight.w300
              ),
            ),
          ),
          Container(
            color: Colors.grey.withOpacity(0.3),
            margin: EdgeInsets.only(top: 10),
            padding: EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),  
            width: MediaQuery.of(context).size.width,          
            child: Text('Правила для посетителей',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black.withOpacity(1),
                fontWeight: FontWeight.w500
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 10, left: 12, right: 12),
            child: Wrap(
              children: List.generate(widget.oopt.ruleImages.length, 
                (index) {
                  return Container(
                    padding: EdgeInsets.only(left: 3, right: 3, top: 3, bottom: 3),
                    child: Image(
                      width: MediaQuery.of(context).size.width * 0.2,
                      height: MediaQuery.of(context).size.width * 0.2,
                      image: AssetImage('assets/data/src/' + widget.oopt.ruleImages[index]),
                    )
                  );
                }
              )
            )
          ),
          Container(
            padding: EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('На территории запрещается: ',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black.withOpacity(1),
                    fontWeight: FontWeight.w500
                  )
                ),
                Padding(padding: EdgeInsets.only(top: 3)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(widget.oopt.rules.length, 
                    (index) {
                      return Container(
                        padding: EdgeInsets.only(top: 3),
                        child: Text('- ' + widget.oopt.rules[index],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black.withOpacity(1),
                            fontWeight: FontWeight.w300
                          ),
                        )
                      );
                    }
                  )
                )
              ]
            )
          ),
          Container(
            //color: Colors.grey.withOpacity(0.3),
            padding: EdgeInsets.only(top: 5, left: 15, right: 15),  
            width: MediaQuery.of(context).size.width,          
            child: Text(widget.oopt.law,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black.withOpacity(1),
                fontWeight: FontWeight.w300
              ),
            ),
          ),
          Container(
            color: Colors.grey.withOpacity(0.3),
            margin: EdgeInsets.only(top: 10),
            padding: EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),  
            width: MediaQuery.of(context).size.width,          
            child: Text('Нормативная правовая основа функционирования ООПТ',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black.withOpacity(1),
                fontWeight: FontWeight.w500
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 5, bottom: 20, left: 15, right: 15),  
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(widget.oopt.norm.length, 
                (index) {
                  return Container(
                    padding: EdgeInsets.only(top: 7),
                    child: Text(widget.oopt.norm[index],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black.withOpacity(1),
                        fontWeight: FontWeight.w300
                      ),
                    )
                  );
                }
              )
            )
          )
        ],
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
      body: SingleChildScrollView(
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            buildImages(),
            buildBody()
          ],
        )
      )
    );
  }
}