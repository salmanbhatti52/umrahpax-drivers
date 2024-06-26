import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:umrahcar_driver/utils/colors.dart';
import 'package:flutter_switch/flutter_switch.dart';

import '../models/get_all_system_data_model.dart';
import '../models/update_driver_location_model.dart';
import '../service/rest_api_service.dart';
import 'homepage_screen.dart';
import 'login_screen.dart';

class SetttingsPage extends StatefulWidget {
  const SetttingsPage({super.key});

  @override
  State<SetttingsPage> createState() => _SetttingsPageState();
}

class _SetttingsPageState extends State<SetttingsPage> {
  bool status = false;
  bool servicestatus = false;
  bool haspermission = false;
  late LocationPermission permission;
  late Position position;
  String long = "", lat = "";
  Timer? timer;

  late StreamSubscription<Position> positionStream;
  checkGps() async {
    servicestatus = await Geolocator.isLocationServiceEnabled();
    if(servicestatus){
      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
        }else if(permission == LocationPermission.deniedForever){
          print("'Location permissions are permanently denied");
        }else{
          haspermission = true;
        }
      }else{
        haspermission = true;
      }

      if(haspermission){
        if(mounted){
          setState(() {
            //refresh the UI
          });
          getLocation();
        }
      }
    }else{
      print("GPS Service is not enabled, turn on GPS location");
    }
    if(mounted){
      setState(() {
        //refresh the UI
      });
    }
  }

  getLocation() async {
    position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    // print(position.longitude); //Output: 80.24599079
    // print(position.latitude);
    // print("hiiiiiiiiiii");//Output: 29.6593457

    long = position.longitude.toString();
    lat = position.latitude.toString();



    if(mounted){
      if(long.isNotEmpty && lat.isNotEmpty){
        updateDriverLocation();

      }
      setState(() {
        //refresh UI
      });
    }

    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );

    StreamSubscription<Position> positionStream = Geolocator.getPositionStream(
        locationSettings: locationSettings).listen((Position position) {
      // print(position.longitude); //Output: 80.24599079
      // print(position.latitude); //Output: 29.6593457
      // print("bye");//Output: 29.6593457

      long = position.longitude.toString();
      lat = position.latitude.toString();


      if(mounted){
        if(long.isNotEmpty && lat.isNotEmpty){
          updateDriverLocation();

        }
        setState(() {

        });
      }

    });
  }
  UpdateDriverLocationModel updateDriverLocationModel=UpdateDriverLocationModel();
  updateDriverLocation()async{
    // print(lat);
    // print(long);
    // print(userId);
    // print("done");
    var jsonData={
      "users_drivers_id":"${userId.toString()}",
      "longitude":long,
      "lattitude":lat
    };

    updateDriverLocationModel = await DioClient().updateDriverLocation(jsonData, context);
    print("message of location: ${updateDriverLocationModel.message}");
    }
  GetAllSystemData getAllSystemData = GetAllSystemData();

  getSystemAllData() async {
    if(mounted){
      getAllSystemData = await DioClient().getSystemAllData(context);
      // print("GETSystemAllData: ${getAllSystemData.data}");
      setState(() {
        getSettingsData();
      });
    }
  }

  late List<Setting> pickSettingsData = [];
  int timerCount=3;
  getSettingsData() {
    if (getAllSystemData!.data! != null) {
      for (int i = 0; i < getAllSystemData!.data!.settings!.length; i++) {
        pickSettingsData.add(getAllSystemData!.data!.settings![i]);
        // print("Setting time= $pickSettingsData");
      }

      for (int i = 0; i < pickSettingsData.length; i++) {
        if (pickSettingsData[i].type == "map_refresh_time") {
          timerCount = int.parse(pickSettingsData[i].description!);
          print("timer refresh: ${timerCount}");
          if(mounted){
            checkGps();
            timer =
                Timer.periodic( Duration(minutes: timerCount), (timer) => checkGps());
            setState(() {});
          }
        }
      }
    }
  }

  @override
  void initState() {
    getSystemAllData();
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: mainColor,
        appBar: AppBar(
          backgroundColor: mainColor,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text(
            'Settings',
            style: TextStyle(
                color: Colors.black,
                fontSize: 26,
                fontFamily: 'Montserrat-Regular',
                fontWeight: FontWeight.w700),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.08),
                const Text(
                  'Notifications',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontFamily: 'Montserrat-Regular',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: size.height * 0.04),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/images/notification-icon.svg',
                      width: 25,
                      height: 25,
                    ),
                    SizedBox(width: size.width * 0.04),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Push Notifications',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: 'Montserrat-Regular',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: size.height * 0.002),
                        const Text(
                          'Turn on Push Notifications',
                          style: TextStyle(
                            color: Color(0xFF565656),
                            fontSize: 12,
                            fontFamily: 'Montserrat-Regular',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // SizedBox(width: size.width * 0.2),
                    FlutterSwitch(
                      width: 45,
                      height: 25,
                      activeColor: const Color(0xFFFFB940),
                      inactiveColor: const Color(0xFF565656).withOpacity(0.2),
                      activeToggleColor: Colors.white,
                      inactiveToggleColor: const Color(0xFF565656),
                      toggleSize: 25,
                      value: status,
                      borderRadius: 50,
                      padding: 2,
                      onToggle: (val) {
                        setState(() {
                          status = val;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.03),
                Divider(
                  color: const Color(0xFF929292).withOpacity(0.3),
                  thickness: 1,
                  indent: 10,
                  endIndent: 10,
                ),
                SizedBox(height: size.height * 0.03),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/images/account-icon.svg',
                    ),
                    SizedBox(width: size.width * 0.05),
                    const Text(
                      'Account Settings',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Montserrat-Regular',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: SvgPicture.asset(
                        'assets/images/left-arrow-icon.svg',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.03),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/images/about-us-icon.svg',
                    ),
                    SizedBox(width: size.width * 0.05),
                    const Text(
                      'About Us',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Montserrat-Regular',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: SvgPicture.asset(
                        'assets/images/left-arrow-icon.svg',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.03),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/images/contact-us-icon.svg',
                    ),
                    SizedBox(width: size.width * 0.05),
                    const Text(
                      'Contact Us',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Montserrat-Regular',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: SvgPicture.asset(
                        'assets/images/left-arrow-icon.svg',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.03),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/images/terms-icon.svg',
                    ),
                    SizedBox(width: size.width * 0.05),
                    const Text(
                      'Terms And Conditions',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Montserrat-Regular',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: SvgPicture.asset(
                        'assets/images/left-arrow-icon.svg',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.03),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/images/privacy-icon.svg',
                    ),
                    SizedBox(width: size.width * 0.05),
                    const Text(
                      'Privacy Policy',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Montserrat-Regular',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: SvgPicture.asset(
                        'assets/images/left-arrow-icon.svg',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.12),
                InkWell(
                  onTap: ()async {
                    SharedPreferences preferences = await SharedPreferences.getInstance();
                    await preferences.clear();
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const LogInPage()));
                  },
                  child: Center(
                    child: Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 20,
                        color: primaryColor,
                        fontFamily: 'Montserrat-Regular',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.03),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
