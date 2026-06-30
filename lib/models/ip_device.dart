enum DeviceStatus { idle, checking, online, offline }

// Sentinel to distinguish "not passed" from "explicitly null"
const _sentinel = Object();

class IPDevice {
  final String id;
  final String ip;
  final String label;
  final String category;
  DeviceStatus status;
  double? pingMs;
  DateTime? lastChecked;

  IPDevice({
    required this.id,
    required this.ip,
    this.label = '',
    this.category = 'General',
    this.status = DeviceStatus.idle,
    this.pingMs,
    this.lastChecked,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ip': ip,
      'label': label,
      'category': category,
    };
  }

  factory IPDevice.fromJson(Map<String, dynamic> json) {
    return IPDevice(
      id: json['id'] as String,
      ip: json['ip'] as String,
      label: (json['label'] as String?) ?? '',
      category: (json['category'] as String?) ?? 'General',
    );
  }

  IPDevice copyWith({
    String? id,
    String? ip,
    String? label,
    String? category,
    DeviceStatus? status,
    Object? pingMs = _sentinel,
    Object? lastChecked = _sentinel,
  }) {
    return IPDevice(
      id: id ?? this.id,
      ip: ip ?? this.ip,
      label: label ?? this.label,
      category: category ?? this.category,
      status: status ?? this.status,
      pingMs: pingMs == _sentinel ? this.pingMs : pingMs as double?,
      lastChecked: lastChecked == _sentinel ? this.lastChecked : lastChecked as DateTime?,
    );
  }
}

