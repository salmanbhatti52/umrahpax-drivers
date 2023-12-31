import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:umrahcar_driver/utils/colors.dart';
import 'package:umrahcar_driver/widgets/tabbar_bookings.dart';

import '../../models/get_all_system_data_model.dart';
import '../../models/update_driver_location_model.dart';
import '../../service/rest_api_service.dart';
import '../homepage_screen.dart';

class BookingsPage extends StatefulWidget {
  int? indexNmbr=0;
   BookingsPage({super.key,this.indexNmbr});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
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
        setState(() {
          //refresh the UI
        });

        getLocation();
      }
    }else{
      print("GPS Service is not enabled, turn on GPS location");
    }

    setState(() {
      //refresh the UI
    });
  }

  getLocation() async {
    position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print(position.longitude); //Output: 80.24599079
    print(position.latitude);
    print("hiiiiiiiiiii");//Output: 29.6593457

    long = position.longitude.toString();
    lat = position.latitude.toString();


    if(long.isNotEmpty && lat.isNotEmpty){
      updateDriverLocation();

    }

    setState(() {
      //refresh UI
    });

    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );

    StreamSubscription<Position> positionStream = Geolocator.getPositionStream(
        locationSettings: locationSettings).listen((Position position) {
      print(position.longitude); //Output: 80.24599079
      print(position.latitude); //Output: 29.6593457
      print("bye");//Output: 29.6593457

      long = position.longitude.toString();
      lat = position.latitude.toString();

      if(long.isNotEmpty && lat.isNotEmpty){
        updateDriverLocation();

      }
      setState(() {

      });
    });
  }
  UpdateDriverLocationModel updateDriverLocationModel=UpdateDriverLocationModel();
  updateDriverLocation()async{
    print(lat);
    print(long);
    print(userId);
    print("done");
    var jsonData={
      "users_drivers_id":"${userId.toString()}",
      "longitude":long,
      "lattitude":lat
    };

    updateDriverLocationModel = await DioClient().updateDriverLocation(jsonData, context);
    if(updateDriverLocationModel !=null){
      print("message of location: ${updateDriverLocationModel.message}");
    }
  }
  GetAllSystemData getAllSystemData = GetAllSystemData();

  getSystemAllData() async {
    getAllSystemData = await DioClient().getSystemAllData(context);
    if (getAllSystemData != null) {
      print("GETSystemAllData: ${getAllSystemData.data}");
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
        print("Setting time= $pickSettingsData");
      }

      for (int i = 0; i < pickSettingsData.length; i++) {
        if (pickSettingsData[i].type == "map_refresh_time") {
          timerCount = int.parse(pickSettingsData[i].description!);
          print("timer refresh: ${timerCount}");
          checkGps();
          timer =
              Timer.periodic( Duration(minutes: timerCount), (timer) => checkGps());
          setState(() {});


        }
      }
    }
  }

  @override
  void initState() {
    print("bookingPage: ${widget.indexNmbr}");
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
            'Bookings',
            style: TextStyle(
                color: Colors.black,
                fontSize: 26,
                fontFamily: 'Montserrat-Regular',
                fontWeight: FontWeight.w700),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: size.height * 0.02),
               TabbarBookings( indexNmbr: widget.indexNmbr),
            ],
          ),
        ),
      ),
    );
  }
}
