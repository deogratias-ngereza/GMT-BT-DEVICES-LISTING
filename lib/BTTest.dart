import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';


class BTTest extends StatefulWidget {
  const BTTest({Key? key}) : super(key: key);

  @override
  State<BTTest> createState() => _BTTestState();
}

class _BTTestState extends State<BTTest> {

  PrinterBluetoothManager printerManager = PrinterBluetoothManager();
  List<PrinterBluetooth> _devices = [];

  @override
  void initState() {
    super.initState();
    permisionRequest();
    printerManager.scanResults.listen((devices) async {
       print('UI: Devices found ${devices.length}');
      setState(() {
        _devices = devices;
      });
    });
    _startScanDevices();
  }

  void permisionRequest() async{
    // You can can also directly ask the permission about its status.
    if (await Permission.location.isRestricted) {
      // The OS restricts access, for example because of parental controls.
      print("----- RESTRICTED LOCATION PERMISSION ---- ");
    }else{
      print("-- PERMISSION LOCATION OK -- ");
    }

    if (await Permission.bluetooth.isRestricted) {
      print("----- RESTRICTED bluetooth PERMISSION ---- ");
    }else{
      print("-- PERMISSION bluetooth OK -- ");
    }

    if (await Permission.bluetoothScan.isRestricted) {
      print("----- RESTRICTED bluetoothScan PERMISSION ---- ");
    }else{
      print("-- PERMISSION bluetoothScan OK -- ");
    }

    if (await Permission.bluetoothAdvertise.isRestricted) {
      print("----- RESTRICTED bluetoothAdvertise PERMISSION ---- ");
    }else{
      print("-- PERMISSION bluetoothAdvertise OK -- ");
    }

    // You can request multiple permissions at once.
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.bluetooth,
    ].request();
  }

  void _startScanDevices() {
    setState(() {
      _devices = [];
    });
    printerManager.startScan(Duration(seconds: 4));
  }

  void _stopScanDevices() {
    printerManager.stopScan();
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: new Scaffold(
        appBar: AppBar(title: Text("GMT-BT-TEST"),centerTitle: true),
        body: Container(
          child: Column(
            children: [
              Expanded(child: Container(
                child: ListView.builder(
                  itemCount: _devices.length,
                  itemBuilder: (BuildContext context,int index){
                    return ListTile(
                      leading: Icon(Icons.bluetooth),
                      title: Text(_devices[index].name.toString()),
                    );
                  },
                ),
              ),),

              StreamBuilder<bool>(
                stream: printerManager.isScanningStream,
                initialData: false,
                builder: (c, snapshot) {
                  if (snapshot.data!) {
                    return TextButton(onPressed: (){
                      _stopScanDevices();
                    }, child: Text("STOP",style: TextStyle(color: Colors.red),),);
                  } else {
                    return TextButton(onPressed: (){
                      _startScanDevices();
                    }, child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("SCAN"),
                        SizedBox(width: 20,),
                        Icon(Icons.search)
                      ],
                    ));
                  }
                },
              ),

            ],
          ),
        ),


      ),
    );
  }
}
