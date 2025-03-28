import 'package:universal_ble/universal_ble.dart';
import 'package:web_view_ble/src/services/logger.dart';
import 'dart:typed_data';

class BleScanFilter {
  bool acceptAllDevices = false;
  List services = [];
  List namePrefix = [];
  List<ManufacturerDataScanFilter> manufacturerData = [];

  void fromJson(Map<String, dynamic>? data) {
    try {
      var filters = data?['filters'];
      acceptAllDevices = data?['acceptAllDevices'] ?? false;
      if (filters == null || filters is! List || filters.isEmpty) {
        acceptAllDevices = true;
        return;
      }

      for (Map<String, dynamic> filter in filters) {
        String filterType = filter.keys.first;
        var filterData = filter[filterType];
        switch (filterType) {
          // services -> List<String>
          case 'services':
            if (filterData is List) {
              services.addAll(filterData);
            } else {
              services.add(filterData);
            }
            break;
          // name , namePrefix -> String
          case 'name':
          case 'namePrefix':
            if (filterData is List) {
              namePrefix.addAll(filterData);
            } else {
              namePrefix.add(filterData);
            }
            break;
          // manufacturerData -> companyIdentifier, payloadPrefix, payloadMask
          case 'manufacturerData':
            if (filterData is List) {
              for (Map<String, dynamic> mfd in filterData) {
                manufacturerData.add(ManufacturerDataScanFilter.fromJson(mfd));
              }
            }
            logWarning("ManufacturerDataFilter is not fully supported yet");
            break;
          default:
            logError("$filterType is not supported yet");
        }
      }
    } catch (e) {
      logError('ScanFilterError: $e');
      acceptAllDevices = true;
    }
  }

  @override
  String toString() {
    return 'BleScanFilter(acceptAllDevices: $acceptAllDevices, services: $services, namePrefix: $namePrefix  manufacturerData: $manufacturerData)';
  }
}

class ManufacturerDataScanFilter {
  int? companyIdentifier;
  Uint8List? payloadPrefix;
  Uint8List? payloadMask;

  ManufacturerDataScanFilter(
      this.companyIdentifier, this.payloadPrefix, this.payloadMask);

  factory ManufacturerDataScanFilter.fromJson(Map<String, dynamic>? data) {
    try {
      return ManufacturerDataScanFilter(
        data?['companyIdentifier'],
        Uint8List.fromList([data?['dataPrefix']['0'], data?['dataPrefix']['1']]),
        data?['payloadMask'],
      );
    } catch (e) {
      logError('ManufacturerDataScanFilter: $e');
      return ManufacturerDataScanFilter(null, null, null);
    }
  }

  ManufacturerDataFilter toMfdFilter() {
    return ManufacturerDataFilter(
      companyIdentifier: companyIdentifier!,
      payloadPrefix: payloadPrefix,
      payloadMask: payloadMask
    );
  }

  @override
  String toString() {
    return 'ManufacturerDataScanFilter(companyIdentifier: $companyIdentifier, payloadPrefix: $payloadPrefix, payloadMask: $payloadMask)';
  }
}
