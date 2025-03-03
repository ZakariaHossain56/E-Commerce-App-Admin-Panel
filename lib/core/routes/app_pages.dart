import 'package:get/get_navigation/src/routes/get_route.dart';
import '../../screens/main/main_screen.dart';



class AppPages {
  static const HOME = '/';

  static final routes = [ //route definitions list. 1 GetPage object per route
    GetPage(
      name: HOME,
      fullscreenDialog: true,
      page: () => MainScreen()  //returns the MainScreen widget for this route
    ),

  ];
}
