
import 'package:flutter/material.dart';

import 'main_bloc.dart';

import '../map/map_page.dart';

import '../../resources/app_colors.dart';

class MainPage extends StatefulWidget {

  MainPage();

  @override
  MainPageState createState() => MainPageState();

  static MainPageState of(BuildContext context) {
    return context.ancestorStateOfType(TypeMatcher<MainPageState>());
  }
}

class MainPageState extends State<MainPage> with AutomaticKeepAliveClientMixin  {

  final onIcons = [
    'assets/images/icons/menu_icon1c.png',
    'assets/images/icons/menu_icon2c.png',
    'assets/images/icons/menu_icon6c.png',
    'assets/images/icons/menu_icon3c.png',
    'assets/images/icons/menu_icon4c.png',
    'assets/images/icons/menu_icon5c.png',
  ];
  final offIcons = [
    'assets/images/icons/menu_icon1.png',
    'assets/images/icons/menu_icon2.png',
    'assets/images/icons/menu_icon6.png',
    'assets/images/icons/menu_icon3.png',
    'assets/images/icons/menu_icon4.png',
    'assets/images/icons/menu_icon5.png',
  ];

  final bloc = MainPageBloc();
  final pageController = PageController(initialPage: 0);

  List<Widget> pages;
    
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    pages = [MapPage(), MapPage(), MapPage(), MapPage(), MapPage(), MapPage()];

  }

  
  @override
  void reassemble() {
    super.reassemble();
    
   // onPageChanged(page);
  }

  void onPageInit() {
    // setState((){
    //   appBar = pages[page].appBar;
    // });
  }

  void onBottomItemPressed(int index) {
    // setState((){
    //   page = index;
    // });
    // onPageInit();
    pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 400),
      curve: Curves.fastOutSlowIn,
    );
    bloc.changePage(index);
  }

  PreferredSize buildAppBar() {
    return PreferredSize( 
      preferredSize: Size(0, 50),
      child: AppBar(
        backgroundColor: AppColors.blue,
        centerTitle: true,
        title: Text('Карта'),
      )
    );
  }

  BottomNavigationBarItem buildIcon(String title, int index, int page) {
    return BottomNavigationBarItem(
      title: Text(title,
        style: TextStyle(
          fontSize: 12,
          color: page == index ? (index == 3 ? Colors.red : AppColors.blue) : Colors.grey.withOpacity(0.9),
        ),
      ),
      icon: Container(
        child: Image(
          image: AssetImage(page == index ? onIcons[index] : offIcons[index]),
          width: 30,
        )
      ),
    );
  }

  Widget build(BuildContext context) {
    for (final image in onIcons) {
      precacheImage(AssetImage(image), context);
    }
    for (final image in offIcons) {
      precacheImage(AssetImage(image), context);
    }
    return SafeArea(
      top: false,
      bottom: true,
      minimum: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: buildAppBar(),
        body: PageView(
          physics: NeverScrollableScrollPhysics(),
          controller: pageController,
          children: pages
        ),
        bottomNavigationBar: StreamBuilder(
          stream: bloc.page,
          builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
            final page = snapshot.data ?? 0;
            return Container(
              height: 60,
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                fixedColor: AppColors.blue,
                currentIndex:page,
                onTap: onBottomItemPressed,
                items:  <BottomNavigationBarItem>[
                  buildIcon('Карта', 0, page),
                  buildIcon('ООПТ', 1, page),
                  buildIcon('Маршруты', 2, page),
                  buildIcon('Пожар', 3, page),
                  buildIcon('Слайды', 4, page),
                  buildIcon('Контакты', 5, page),
                ]
              )
            );
          }
        )
      )
    );
  }
}
