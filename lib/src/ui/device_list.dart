import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_reactive_ble_example/src/ble/ble_scanner.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../widgets.dart';
import 'device_detail/device_detail_screen.dart';

class DeviceListScreen extends StatelessWidget {
  const DeviceListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Consumer2<BleScanner, BleScannerState?>(
        builder: (_, bleScanner, bleScannerState, __) => _DeviceList(
          scannerState: bleScannerState ??
              const BleScannerState(
                discoveredDevices: [],
                scanIsInProgress: false,
              ),
          startScan: bleScanner.startScan,
          stopScan: bleScanner.stopScan,
        ),
      );
}

class _DeviceList extends StatefulWidget {
  const _DeviceList(
      {required this.scannerState,
      required this.startScan,
      required this.stopScan});

  final BleScannerState scannerState;
  final void Function(List<Uuid>) startScan;
  final VoidCallback stopScan;

  @override
  _DeviceListState createState() => _DeviceListState();
}

class _DeviceListState extends State<_DeviceList> {
  late TextEditingController _uuidController;

  late TextEditingController _c1;
  late TextEditingController _c2;
  late TextEditingController _c3;
  @override
  void initState() {
    super.initState();
    _uuidController = TextEditingController();
    _c1 = TextEditingController();
    _c2 = TextEditingController();
    _c3 = TextEditingController()..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    widget.stopScan();
    _uuidController.dispose();
    super.dispose();
  }

  bool _isValidUuidInput() {
    final uuidText = _uuidController.text;
    if (uuidText.isEmpty) {
      return true;
    } else {
      try {
        Uuid.parse(uuidText);
        return true;
      } on Exception {
        return false;
      }
    }
  }

  // void show_success_dialog(BuildContext context) {
  //   // print("hello");
  //   AwesomeDialog(
  //       context: context,
  //       animType: AnimType.LEFTSLIDE,
  //       headerAnimationLoop: false,
  //       dialogType: DialogType.SUCCES,
  //       title: 'Success',
  //       desc: 'Offer created and send successfully',
  //       btnOkOnPress: () {
  //         debugPrint("hello from success");
  //         Navigator.push<dynamic>(
  //             context,
  //             MaterialPageRoute<dynamic>(
  //                 builder: (context) => DeviceListScreen()));
  //       },
  //       btnOkIcon: Icons.check_circle,
  //       onDissmissCallback: () {
  //         debugPrint('Dialog Dissmiss from callback');
  //       }).show();
  // }

  // // ignore: non_constant_identifier_names
  // void show_error_dialog(BuildContext context) {
  //   AwesomeDialog(
  //           context: context,
  //           dialogType: DialogType.ERROR,
  //           animType: AnimType.RIGHSLIDE,
  //           headerAnimationLoop: false,
  //           title: 'Error',
  //           desc: 'Some error occured. Please try again.',
  //           btnOkOnPress: () {
  //             Navigator.push<dynamic>(
  //                 context,
  //                 MaterialPageRoute<dynamic>(
  //                     builder: (context) => DeviceListScreen()));
  //           },
  //           btnOkIcon: Icons.cancel,
  //           btnOkColor: Colors.red)
  //       .show();
  // }

  void _startScanning() {
    final text = _uuidController.text;
    widget.startScan(text.isEmpty ? [] : [Uuid.parse(_uuidController.text)]);
  }

  Widget _buildPopupDialog(BuildContext context) {
    String name = "";
    String desc = "";
    String type = "";
    return AlertDialog(
      title: const Text('Send Offer'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 16),
          const Text('Offer Name'),
          TextField(
            controller: _c1,
            enabled: !widget.scannerState.scanIsInProgress,
            decoration: InputDecoration(
                errorText: _uuidController.text.isEmpty || _isValidUuidInput()
                    ? null
                    : 'Invalid UUID format'),
            autocorrect: false,
          ),
          const SizedBox(height: 16),
          const Text('Offer Description'),
          TextField(
            controller: _c2,
            enabled: !widget.scannerState.scanIsInProgress,
            decoration: InputDecoration(
                errorText: _uuidController.text.isEmpty || _isValidUuidInput()
                    ? null
                    : 'Invalid UUID format'),
            autocorrect: false,
          ),
          const SizedBox(height: 16),
          const Text('Offer Type'),
          TextField(
            controller: _c3,
            enabled: !widget.scannerState.scanIsInProgress,
            decoration: InputDecoration(
                errorText: _uuidController.text.isEmpty || _isValidUuidInput()
                    ? null
                    : 'Invalid UUID format'),
            autocorrect: false,
          )
        ],
      ),
      actions: <Widget>[
        // ignore: deprecated_member_use
        FlatButton(
          onPressed: () async {
            // ignore: constant_identifier_names
            var URL =
                "http://cashopcust-env.eba-bpeepfcp.us-east-1.elasticbeanstalk.com";

            // ignore: prefer_interpolation_to_compose_strings
            var uri = URL + "/merchant/bluetooth/offer/";
            print(uri);
            // ignore: omit_local_variable_types
            final Map<String, String> requestBody = {
              "description": _c2.text,
              "category": _c3.text,
              "title": _c1.text
            };

            final body = json.encode(requestBody);
            print(requestBody);
            final response = await http.post(
              Uri.parse(uri),
              headers: {"Content-Type": "application/json"},
              body: body,
            );
            final dynamic responseBody = json.decode(response.body);
            if (responseBody["success"] == true) {
              showDialog<void>(
                  context: context,
                  builder: (_) => AlertDialog(
                        title: Text('Success'),
                        content: Text('Offer created and sent success'),
                      ));
            } else {
              showDialog<void>(
                  context: context,
                  builder: (_) => AlertDialog(
                        title: Text('Dialog Title'),
                        content: Text('This is my content'),
                      ));
            }
          },
          textColor: Theme.of(context).primaryColor,
          child: const Text('Send Offer'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Merchant App - Scan for customers'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Text('Id of the customer'),
                  TextField(
                    controller: _uuidController,
                    enabled: !widget.scannerState.scanIsInProgress,
                    decoration: InputDecoration(
                        errorText:
                            _uuidController.text.isEmpty || _isValidUuidInput()
                                ? null
                                : 'Invalid UUID format'),
                    autocorrect: false,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        child: const Text('Scan'),
                        onPressed: !widget.scannerState.scanIsInProgress &&
                                _isValidUuidInput()
                            ? _startScanning
                            : null,
                      ),
                      ElevatedButton(
                        child: const Text('Stop'),
                        onPressed: widget.scannerState.scanIsInProgress
                            ? widget.stopScan
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(!widget.scannerState.scanIsInProgress
                            ? 'Enter the Id of the customer for targeted order.'
                            : 'Tap a device to connect to it'),
                      ),
                      if (widget.scannerState.scanIsInProgress ||
                          widget.scannerState.discoveredDevices.isNotEmpty)
                        Padding(
                          padding:
                              const EdgeInsetsDirectional.only(start: 18.0),
                          child: Text(
                              'count: ${widget.scannerState.discoveredDevices.length}'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView(
                children: widget.scannerState.discoveredDevices
                    .map(
                      (device) => ListTile(
                        title: Text(device.name),
                        subtitle: Text("${device.id}\nRSSI: ${device.rssi}"),
                        leading: const BluetoothIcon(),
                        onTap: () async {
                          widget.stopScan();
                          await Navigator.push<void>(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      DeviceDetailScreen(device: device)));
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
            ElevatedButton(
                child: const Text('Send customized offer to All'),
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (BuildContext context) =>
                        _buildPopupDialog(context),
                  );
                })
          ],
        ),
      );
}
