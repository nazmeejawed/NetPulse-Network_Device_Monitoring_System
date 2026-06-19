import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import '../models/ip_device.dart';
import '../services/ping_service.dart';
import '../services/file_parser_service.dart';

enum FilterMode { all, online, offline }

class IPCheckerProvider extends ChangeNotifier {
  final List<IPDevice> _devices = [];
  FilterMode _filterMode = FilterMode.all;
  String _searchQuery = '';
  bool _sortByStatus = false;

  bool _isPinging = false;
  int _pingedCount = 0;
  String? _errorMessage;
  String? _successMessage;

  // Getters
  List<IPDevice> get devices => _devices;
  FilterMode get filterMode => _filterMode;
  String get searchQuery => _searchQuery;
  bool get isPinging => _isPinging;
  int get pingedCount => _pingedCount;
  int get totalPingCount => _devices.length;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  int get onlineCount => _devices.where((d) => d.status == DeviceStatus.online).length;
  int get offlineCount => _devices.where((d) => d.status == DeviceStatus.offline).length;
  
  double get avgPingMs {
    final onlineDevices = _devices.where((d) => d.status == DeviceStatus.online && d.pingMs != null);
    if (onlineDevices.isEmpty) return 0;
    final total = onlineDevices.fold(0.0, (sum, item) => sum + item.pingMs!);
    return total / onlineDevices.length;
  }

  List<IPDevice> get filteredDevices {
    var list = _devices.where((d) {
      if (_filterMode == FilterMode.online && d.status != DeviceStatus.online) return false;
      if (_filterMode == FilterMode.offline && d.status != DeviceStatus.offline) return false;
      
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return d.ip.toLowerCase().contains(query) || d.label.toLowerCase().contains(query);
      }
      return true;
    }).toList();

    if (_sortByStatus) {
      list.sort((a, b) {
        if (a.status == DeviceStatus.online && b.status != DeviceStatus.online) return -1;
        if (a.status != DeviceStatus.online && b.status == DeviceStatus.online) return 1;
        if (a.status == DeviceStatus.offline && b.status != DeviceStatus.offline) return 1;
        if (a.status != DeviceStatus.offline && b.status == DeviceStatus.offline) return -1;
        return 0;
      });
    }

    return list;
  }

  // Actions
  void setFilterMode(FilterMode mode) {
    _filterMode = mode;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleSortByStatus() {
    _sortByStatus = !_sortByStatus;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<void> loadFile() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'xlsx', 'xls'],
      );

      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        final newDevices = await FileParserService.parseFile(path);
        
        _devices.addAll(newDevices);
        _successMessage = "${newDevices.length} devices found in file";
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = "Error reading file: $e";
      notifyListeners();
    }
  }

  void addManualIP(String ip, String label) {
    final newDevice = IPDevice(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      ip: ip,
      label: label,
    );
    _devices.add(newDevice);
    notifyListeners();
    pingOne(newDevice.id);
  }

  void removeDevice(String id) {
    _devices.removeWhere((d) => d.id == id);
    notifyListeners();
  }

  void clearAll() {
    _devices.clear();
    _pingedCount = 0;
    _isPinging = false;
    notifyListeners();
  }

  Future<void> pingOne(String id) async {
    final index = _devices.indexWhere((d) => d.id == id);
    if (index == -1) return;

    _devices[index].status = DeviceStatus.checking;
    notifyListeners();

    final ip = _devices[index].ip;
    final result = await PingService.ping(ip);

    final checkIndex = _devices.indexWhere((d) => d.id == id);
    if (checkIndex != -1) {
      _devices[checkIndex].status = result.isOnline ? DeviceStatus.online : DeviceStatus.offline;
      _devices[checkIndex].pingMs = result.pingMs;
      _devices[checkIndex].lastChecked = DateTime.now();
      notifyListeners();
    }
  }

  Future<void> pingAll() async {
    if (_isPinging || _devices.isEmpty) return;

    _isPinging = true;
    _pingedCount = 0;
    _successMessage = null;
    
    for (var device in _devices) {
      device.status = DeviceStatus.checking;
    }
    notifyListeners();

    const chunkSize = 10;
    for (int i = 0; i < _devices.length; i += chunkSize) {
      if (!_isPinging) break;

      final end = (i + chunkSize < _devices.length) ? i + chunkSize : _devices.length;
      final chunk = _devices.sublist(i, end);

      await Future.wait(chunk.map((device) async {
        final result = await PingService.ping(device.ip);
        final checkIndex = _devices.indexWhere((d) => d.id == device.id);
        if (checkIndex != -1) {
          _devices[checkIndex].status = result.isOnline ? DeviceStatus.online : DeviceStatus.offline;
          _devices[checkIndex].pingMs = result.pingMs;
          _devices[checkIndex].lastChecked = DateTime.now();
          _pingedCount++;
          notifyListeners();
        }
      }));
    }

    _isPinging = false;
    if (_pingedCount == _devices.length) {
       _successMessage = "Scan Complete — $onlineCount Online, $offlineCount Offline out of ${_devices.length} devices";
    }
    notifyListeners();
  }
}
