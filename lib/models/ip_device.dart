enum DeviceStatus { idle, checking, online, offline }

class IPDevice {
  final String id;
  final String ip;
  final String label;
  DeviceStatus status;
  double? pingMs;
  DateTime? lastChecked;

  IPDevice({
    required this.id,
    required this.ip,
    this.label = '',
    this.status = DeviceStatus.idle,
    this.pingMs,
    this.lastChecked,
  });

  IPDevice copyWith({
    String? id,
    String? ip,
    String? label,
    DeviceStatus? status,
    double? pingMs,
    DateTime? lastChecked,
  }) {
    return IPDevice(
      id: id ?? this.id,
      ip: ip ?? this.ip,
      label: label ?? this.label,
      status: status ?? this.status,
      pingMs: pingMs ?? this.pingMs,
      lastChecked: lastChecked ?? this.lastChecked,
    );
  }
}
