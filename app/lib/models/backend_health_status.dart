class BackendHealthStatus {
  const BackendHealthStatus({
    required this.status,
    required this.environment,
    required this.checkedAtUtc,
  });

  final String status;
  final String environment;
  final DateTime checkedAtUtc;

  factory BackendHealthStatus.fromJson(Map<String, dynamic> json) {
    final status = json['status'];
    final environment = json['environment'];
    final checkedAtUtc = json['checkedAtUtc'];

    if (status is! String ||
        environment is! String ||
        checkedAtUtc is! String) {
      throw const FormatException('Invalid health response.');
    }

    return BackendHealthStatus(
      status: status,
      environment: environment,
      checkedAtUtc: DateTime.parse(checkedAtUtc).toUtc(),
    );
  }
}
