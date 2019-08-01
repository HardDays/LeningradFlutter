import 'dart:async';

import 'package:flutter/material.dart';

import 'start_bloc.dart';

import '../oopt/oopt_page.dart';

import '../main/main_page.dart';

import '../../resources/app_colors.dart';

import '../../../providers/oopt_provider.dart';

class StartPage extends StatefulWidget {
  const StartPage({Key key}) : super(key: key);

  @override
  StartPageState createState() => StartPageState();
}

class StartPageState extends State<StartPage> with SingleTickerProviderStateMixin {

  final images = [
    'assets/images/intro/intro_pic4.jpg',
    'assets/images/intro/intro_pic5.jpg',
    'assets/images/intro/intro_pic6.jpg',
    'assets/images/intro/intro_pic7.jpg',
    'assets/images/intro/intro_pic8.jpg',
    'assets/images/intro/intro_pic9.jpg',
    'assets/images/intro/intro_pic10.jpg',
    'assets/images/intro/intro_pic11.jpg',
  ];

  final controller = PageController();

  final bloc = StartPageBloc();

  //Timer timer;

  @override
  void initState() {
    super.initState(); 

    // timer = Timer.periodic(Duration(seconds: 5), 
    //   (t) {
    //     controller.animateToPage((controller.page.toInt() + 1) % images.length, duration: Duration(milliseconds: 700), curve: Curves.easeIn);
    //   }
    // );

    WidgetsBinding.instance.addPostFrameCallback((_) => bloc.preloadImages(context, images));
  }

  @override
  void dispose() {
    bloc.timer.cancel();
    super.dispose();
  }

  void onContinue() {
    //OoptProvider.loadArea(1);
    Navigator.pushReplacement(context, MaterialPageRoute<Null>(builder: (t) => MainPage()));
  }

  Widget buildSplash() {
    return Container(
      child: Center(
        child: Icon(Icons.category),
      ),
    );
  }

  Widget buildBackground() {
    final height = MediaQuery.of(context).size.height;
    // return PageView(
    //   controller: controller,
    //   children: List.generate(images.length,
    //     (index) {
    //       return Image(
    //         fit: BoxFit.cover,
    //         height: height,
    //         image: AssetImage(images[index])
    //       );
    //     }
    //   )
    // );
    return StreamBuilder(
      stream: bloc.image,
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) { 
        //ебучие костыли, т.к. нет нормального виджета с этой анимацией
        String first = images.first;
        String second = images[1];
        bool odd = false;
        if (snapshot.hasData) {
          first = images[snapshot.data];
          second = images[snapshot.data - 1 >= 0 ? snapshot.data - 1 : images.length - 1];
          odd = snapshot.data.isOdd;
          if (snapshot.data.isEven) {
            final temp = first;
            first = second;
            second = temp;
          }
        }
        return AnimatedCrossFade(
          duration: Duration(milliseconds: 500),
          crossFadeState: odd ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          firstChild: Image(
            fit: BoxFit.cover,
            height: height,
            image: AssetImage(first)
          ),
          secondChild: Image(
            fit: BoxFit.cover,
            height: height,
            image: AssetImage(second)
          )
        );
      }
    );
  }

  Widget buildLayer() {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.only(top: 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.35),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(0.2),
          ]
        )
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 15, top: 10, right: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      child: Image(
                        width: width * 0.175,
                        image: AssetImage('assets/images/logo/herb1.png'),
                      )
                    ),
                    Container(
                      width: 1,
                      height: width * 0.18,
                      color: Colors.white,
                      margin: EdgeInsets.only(left: 10, right: 10),
                    ),
                    Container(
                      child: Image(
                        width: width * 0.19,
                        image: AssetImage('assets/images/logo/herb2.png'),
                      )
                    ),
                  ]
                ),
                Container(
                  child: Text('ОСОБО ОХРАНЯЕМЫЕ \nПРИРОДНЫЕ ТЕРРИТОРИИ \nЛЕНИНГРАДСКОЙ ОБЛАСТИ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  )
                )
              ],
            )
          ),
          Column(
            children: [
              Container(
                margin: EdgeInsets.only(bottom: height * 0.1),
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: onContinue,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.blue,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(7),
                        bottomLeft: Radius.circular(7),
                      )
                    ),
                    padding: EdgeInsets.only(left: 15, right: 15, top: 7, bottom: 7),
                    child: Text('Продолжить',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18
                      ),
                    ),
                  ),
                )
              ),
              Container(
                padding: EdgeInsets.only(bottom: 3),
                child: Text('Версия приложения: 0.1',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w300
                  ),
                ),
              )
            ]
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: bloc.loaded,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.hasData) {
          return Material(
            child: Stack(
              children: <Widget>[
                buildBackground(),
                buildLayer()
              ],
            )
          );
        } else {
          return Material(
            child: buildSplash(),
          );
        }
      }
    );
  }
}