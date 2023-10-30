import 'dart:async';

import 'dart:math';
import 'package:intl/intl.dart';
import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';


void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;

  bool _connected = false;
  BluetoothDevice? _device;
  String tips = 'no device connect';

  List<Item> items = [
    Item("3pc Vacuum Pack", 30.00, 8, 240.00),
    Item("Item 2", 10.00, 5, 50.00),
    // Add more items here
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => initBluetooth());
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initBluetooth() async {
    bluetoothPrint.startScan(timeout: Duration(seconds: 4));

    bool isConnected=await bluetoothPrint.isConnected??false;

    bluetoothPrint.state.listen((state) {
      print('******************* cur device status: $state');

      switch (state) {
        case BluetoothPrint.CONNECTED:
          setState(() {
            _connected = true;
            tips = 'connect success';
          });
          break;
        case BluetoothPrint.DISCONNECTED:
          setState(() {
            _connected = false;
            tips = 'disconnect success';
          });
          break;
        default:
          break;
      }
    });

    if (!mounted) return;

    if(isConnected) {
      setState(() {
        _connected=true;
      });
    }
  }

  String generatedReceiptId() {
    final random = Random();
    int min = 0; // Smallest 5-digit number
    int max = 99999; // Largest 5-digit number
    int randomNumber = min + random.nextInt(max - min + 1);
    return randomNumber.toString().padLeft(5, '0');
  }

  String getCurrentDateTime() {
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('BluetoothPrint example app'),
        ),
        body: RefreshIndicator(
          onRefresh: () =>
              bluetoothPrint.startScan(timeout: Duration(seconds: 4)),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      child: Text(tips),
                    ),
                  ],
                ),
                Divider(),
                StreamBuilder<List<BluetoothDevice>>(
                  stream: bluetoothPrint.scanResults,
                  initialData: [],
                  builder: (c, snapshot) => Column(
                    children: snapshot.data!.map((d) => ListTile(
                      title: Text(d.name??''),
                      subtitle: Text(d.address??''),
                      onTap: () async {
                        setState(() {
                          _device = d;
                        });
                      },
                      trailing: _device!=null && _device!.address == d.address?Icon(
                        Icons.check,
                        color: Colors.green,
                      ):null,
                    )).toList(),
                  ),
                ),
                Divider(),
                Container(
                  padding: EdgeInsets.fromLTRB(20, 5, 20, 10),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          OutlinedButton(
                            child: Text('connect'),
                            onPressed:  _connected?null:() async {
                              if(_device!=null && _device!.address !=null){
                                setState(() {
                                  tips = 'connecting...';
                                });
                                await bluetoothPrint.connect(_device!);
                              }else{
                                setState(() {
                                  tips = 'please select device';
                                });
                                print('please select device');
                              }
                            },
                          ),
                          SizedBox(width: 10.0),
                          OutlinedButton(
                            child: Text('disconnect'),
                            onPressed:  _connected?() async {
                              setState(() {
                                tips = 'disconnecting...';
                              });
                              await bluetoothPrint.disconnect();
                            }:null,
                          ),
                        ],
                      ),
                      Divider(),
                      OutlinedButton(
                        child: Text('print receipt(esc)'),
                        onPressed:  _connected?() async {
                          print(generatedReceiptId());
                          Map<String, dynamic> config = Map();

                          List<LineText> list = [];

                          list.add(LineText(type: LineText.TYPE_TEXT, content: '--------------------------------', weight: 1, align: LineText.ALIGN_CENTER,linefeed: 1));

                          list.add(LineText(type: LineText.TYPE_TEXT, content: 'Mega Mart', weight: 1, align: LineText.ALIGN_CENTER, fontZoom: 2, linefeed: 1));
                          list.add(LineText(linefeed: 1));

                          list.add(LineText(type: LineText.TYPE_TEXT, content: '3rd Floor,No.101,Olcott Mawatha,Colombo 11', weight: 1, align: LineText.ALIGN_CENTER, linefeed: 1));
                          list.add(LineText(type: LineText.TYPE_TEXT, content: 'Tel: 011-2424922 | 077-7145347', weight: 1, align: LineText.ALIGN_CENTER, linefeed: 1));
                          list.add(LineText(type: LineText.TYPE_TEXT, content: '--------------------------------', weight: 1, align: LineText.ALIGN_CENTER, linefeed: 1));
                          list.add(LineText(type: LineText.TYPE_TEXT, content: 'Receipt No:', weight: 1, align: LineText.ALIGN_LEFT, x: 0, relativeX: 0, linefeed: 0));
                          list.add(LineText(type: LineText.TYPE_TEXT, content: generatedReceiptId(), weight: 1, align: LineText.ALIGN_LEFT, x: 140, relativeX: 0, linefeed: 1));
                          list.add(LineText(type: LineText.TYPE_TEXT, content: 'Cashier:', weight: 1, align: LineText.ALIGN_LEFT, x: 0, relativeX: 0, linefeed: 0));
                          list.add(LineText(type: LineText.TYPE_TEXT, content: "ShahiruE", weight: 1, align: LineText.ALIGN_LEFT, x: 110, relativeX: 0, linefeed: 1));
                          list.add(LineText(type: LineText.TYPE_TEXT, content: getCurrentDateTime(), weight: 1, align: LineText.ALIGN_LEFT, x: 0, relativeX: 0, linefeed: 1));
                          list.add(LineText(type: LineText.TYPE_TEXT, content: 'Payment Type:', weight: 1, align: LineText.ALIGN_LEFT, x: 0, relativeX: 0, linefeed: 0));
                          list.add(LineText(type: LineText.TYPE_TEXT, content: "Cash", weight: 1, align: LineText.ALIGN_LEFT, x: 165, relativeX: 0, linefeed: 1));
                          list.add(LineText(type: LineText.TYPE_TEXT, content: '--------------------------------', weight: 1, align: LineText.ALIGN_CENTER,linefeed: 1));

                          list.add(LineText(type: LineText.TYPE_TEXT, content: 'Item Price', weight: 1, align: LineText.ALIGN_LEFT, x: 0, relativeX: 0, linefeed: 0));
                          list.add(LineText(type: LineText.TYPE_TEXT, content: 'Qty', weight: 1, align: LineText.ALIGN_LEFT, x: 155, relativeX: 0, linefeed: 0));
                          list.add(LineText(type: LineText.TYPE_TEXT, content: "Total(Rs)", weight: 1, align: LineText.ALIGN_LEFT, x: 255, relativeX: 0, linefeed: 1));
                          list.add(LineText(linefeed: 1));

                          // Add items to the receipt
                          for (Item item in items) {
                            list.add(LineText(
                                type: LineText.TYPE_TEXT,
                                content: '1. ${item.name}',
                                weight: 1,
                                align: LineText.ALIGN_LEFT,
                                x: 0,
                                relativeX: 0,
                                linefeed: 1));
                            list.add(LineText(
                                type: LineText.TYPE_TEXT,
                                content: item.price.toString(),
                                weight: 1,
                                align: LineText.ALIGN_LEFT,
                                x: 5,
                                relativeX: 0,
                                linefeed: 0));
                            list.add(LineText(
                                type: LineText.TYPE_TEXT,
                                content: item.quantity.toString(),
                                weight: 1,
                                align: LineText.ALIGN_LEFT,
                                x: 160,
                                relativeX: 0,
                                linefeed: 0));
                            list.add(LineText(
                                type: LineText.TYPE_TEXT,
                                content: item.total.toString(),
                                weight: 1,
                                align: LineText.ALIGN_LEFT,
                                x: 260,
                                relativeX: 0,
                                linefeed: 1));
                          }

                          list.add(LineText(type: LineText.TYPE_TEXT, content: '--------------------------------', weight: 1, align: LineText.ALIGN_CENTER,linefeed: 1));
                          list.add(LineText(linefeed: 1));

                          await bluetoothPrint.printReceipt(config, list);
                        }:null,
                      ),

                      OutlinedButton(
                        child: Text('print selftest'),
                        onPressed:  _connected?() async {
                          await bluetoothPrint.printTest();
                        }:null,
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        floatingActionButton: StreamBuilder<bool>(
          stream: bluetoothPrint.isScanning,
          initialData: false,
          builder: (c, snapshot) {
            if (snapshot.data == true) {
              return FloatingActionButton(
                child: Icon(Icons.stop),
                onPressed: () => bluetoothPrint.stopScan(),
                backgroundColor: Colors.red,
              );
            } else {
              return FloatingActionButton(
                  child: Icon(Icons.search),
                  onPressed: () => bluetoothPrint.startScan(timeout: Duration(seconds: 4)));
            }
          },
        ),
      ),
    );
  }
}

class Item {
  final String name;
  final double price;
  final int quantity;
  final double total;

  Item(this.name, this.price, this.quantity, this.total);
}