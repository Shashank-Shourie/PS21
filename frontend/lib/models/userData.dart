class UserData {
  final String id;
  final String name;
  final String email;
  final String organizationId;
  final String token;
  final bool submitted;
  final double percentageMatched;

  UserData({
    required this.id,
    required this.name,
    required this.email,
    required this.organizationId,
    required this.token,
    required this.submitted,
    required this.percentageMatched,
  });

  factory UserData.fromJson(Map<String, dynamic> json, String token) {
    return UserData(
      id: json['userid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      organizationId: json['organizationId'] ?? '',
      token: token,
      submitted: json['submitted'] ?? false,
      percentageMatched: (json['percentage_matched'] ?? -1).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'organizationId': organizationId,
      'token': token,
      'submitted': submitted,
      'percentageMatched': percentageMatched,
    };
  }
}
