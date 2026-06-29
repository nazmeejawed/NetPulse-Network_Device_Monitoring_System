import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ip_device.dart';
import '../services/ping_service.dart';
import '../services/file_parser_service.dart';

enum FilterMode { all, online, offline }

class IPCheckerProvider extends ChangeNotifier {
  final List<IPDevice> _devices = [];
  bool _isDisposed = false;

  IPCheckerProvider() {
    _loadDevices();
  }

  static const String _storageKey = 'saved_devices';

  Future<void> _loadDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_storageKey);
    if (jsonStr != null) {
      final List<dynamic> jsonList = jsonDecode(jsonStr);
      _devices.clear();
      _devices.addAll(jsonList.map((j) => IPDevice.fromJson(j)).toList());
      notifyListeners();
    }
  }

  Future<void> _saveDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _devices.map((d) => d.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  FilterMode _filterMode = FilterMode.all;
  String _searchQuery = '';
  bool _sortByStatus = false;

  bool _isAutoMonitoring = false;
  Timer? _autoMonitorTimer;

  bool _isPinging = false;
  int _pingedCount = 0;
  String? _errorMessage;
  String? _successMessage;

  // Getters
  List<IPDevice> get devices => _devices;
  FilterMode get filterMode => _filterMode;
  String get searchQuery => _searchQuery;
  bool get isPinging => _isPinging;
  bool get isAutoMonitoring => _isAutoMonitoring;
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

  List<dynamic> get groupedListItems {
    final Map<String, List<IPDevice>> grouped = {};
    for (var device in filteredDevices) {
      grouped.putIfAbsent(device.category, () => []).add(device);
    }
    
    final sortedKeys = grouped.keys.toList()..sort();
    
    final List<dynamic> items = [];
    for (var key in sortedKeys) {
      items.add(key); // String represents category header
      items.addAll(grouped[key]!); // IPDevice represents row
    }
    return items;
  }

  void toggleSortByStatus() {
    _sortByStatus = !_sortByStatus;
    notifyListeners();
  }

  void toggleAutoMonitoring(bool value) {
    _isAutoMonitoring = value;
    notifyListeners();

    if (_isAutoMonitoring) {
      _autoMonitorTimer?.cancel();
      _autoMonitorTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (!_isPinging && _devices.isNotEmpty) {
          pingAll();
        }
      });
      if (!_isPinging && _devices.isNotEmpty) {
        pingAll();
      }
    } else {
      _autoMonitorTimer?.cancel();
      _autoMonitorTimer = null;
    }
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _autoMonitorTimer?.cancel();
    super.dispose();
  }

  void _triggerDesktopAlert(String ip, String label) {
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      final title = "Netpulse Alert";
      final message = label.isNotEmpty ? "Device $ip ($label) went OFFLINE!" : "Device $ip went OFFLINE!";
      
      LocalNotification notification = LocalNotification(
        title: title,
        body: message,
      );
      notification.show();
      
      // Still play a sound if we want, or local_notifier might do it?
      // local_notifier doesn't inherently play a sound on macOS unless configured. Let's still use afplay for the sound just to be sure.
      if (Platform.isMacOS) {
         Process.run('afplay', ['/System/Library/Sounds/Basso.aiff']);
      }
    }
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
        
        int addedCount = 0;
        for (var newDevice in newDevices) {
          if (!_devices.any((d) => d.ip == newDevice.ip)) {
            _devices.add(newDevice);
            addedCount++;
          }
        }
        _saveDevices();
        _successMessage = "$addedCount new devices added from file";
        notifyListeners();
        Future.delayed(const Duration(seconds: 3), () {
          clearMessages();
        });
      }
    } catch (e) {
      _errorMessage = "Error reading file: $e";
      notifyListeners();
    }
  }

  void addManualIP(String ip, String label, String category) {
    if (_devices.any((d) => d.ip == ip)) {
      _errorMessage = "IP address already exists!";
      notifyListeners();
      return;
    }
    final newDevice = IPDevice(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      ip: ip,
      label: label,
      category: category,
    );
    _devices.add(newDevice);
    _saveDevices();
    notifyListeners();
    pingOne(newDevice.id);
  }

  void editDevice(String id, String newIp, String newLabel, String newCategory) {
    final index = _devices.indexWhere((d) => d.id == id);
    if (index != -1) {
      _devices[index] = IPDevice(
        id: id,
        ip: newIp,
        label: newLabel,
        category: newCategory,
        status: DeviceStatus.idle,
      );
      _saveDevices();
      notifyListeners();
      pingOne(id);
    }
  }

  void removeDevice(String id) {
    _devices.removeWhere((d) => d.id == id);
    _saveDevices();
    notifyListeners();
  }

  void clearAll() {
    _devices.clear();
    _saveDevices();
    _pingedCount = 0;
    _isPinging = false;
    notifyListeners();
  }

  Future<void> pingOne(String id) async {
    final index = _devices.indexWhere((d) => d.id == id);
    if (index == -1) return;

    final wasOnline = _devices[index].status == DeviceStatus.online;
    _devices[index].status = DeviceStatus.checking;
    notifyListeners();

    final ip = _devices[index].ip;
    final result = await PingService.ping(ip);

    final checkIndex = _devices.indexWhere((d) => d.id == id);
    if (checkIndex != -1) {
      final isOnline = result.isOnline;
      _devices[checkIndex].status = isOnline ? DeviceStatus.online : DeviceStatus.offline;
      
      if (wasOnline && !isOnline) {
         _triggerDesktopAlert(ip, _devices[checkIndex].label);
      }
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
    
    final Map<String, bool> wasOnlineMap = {};
    for (var device in _devices) {
      wasOnlineMap[device.id] = device.status == DeviceStatus.online;
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
          final isOnline = result.isOnline;
          _devices[checkIndex].status = isOnline ? DeviceStatus.online : DeviceStatus.offline;
          
          if (wasOnlineMap[device.id] == true && !isOnline) {
             _triggerDesktopAlert(device.ip, _devices[checkIndex].label);
          }
          _devices[checkIndex].pingMs = result.pingMs;
          _devices[checkIndex].lastChecked = DateTime.now();
          _pingedCount++;
          notifyListeners();
        }
      }));
    }

    _isPinging = false;
    if (_pingedCount == _devices.length && !_isAutoMonitoring) {
       _successMessage = "Scan Complete — $onlineCount Online, $offlineCount Offline out of ${_devices.length} devices";
       Future.delayed(const Duration(seconds: 3), () {
         clearMessages();
       });
    }
    notifyListeners();
  }
}
