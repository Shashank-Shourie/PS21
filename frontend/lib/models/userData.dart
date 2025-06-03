// Future<UserData?> _getUserDetails(String userId, String token) async {
//   try {
//     print('Fetching user details for userId: $userId');
//     print('Using token: ${token.substring(0, 20)}...'); // Print partial token for security
    
//     final response = await http.get(
//       Uri.parse('$baseUrl/users/details/$userId'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//     );

//     print('User details response status: ${response.statusCode}');
//     print('User details response body: ${response.body}');

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       print('Parsed user data: $data');
      
//       // Debug: Print each field individually
//       print('id field: ${data['id']}');
//       print('userid field: ${data['userid']}');
//       print('name field: ${data['name']}');
//       print('email field: ${data['email']}');
//       print('submitted field: ${data['submitted']}');
//       print('percentage_matched field: ${data['percentage_matched']}');
//       print('organizationId field: ${data['organizationId']}');
      
//       final userData = UserData.fromJson(data, token);
//       print('Created UserData object - id: ${userData.id}, name: ${userData.name}');
      
//       return userData;
//     } else {
//       print('Failed to get user details: ${response.statusCode} - ${response.body}');
//       return null;
//     }
//   } catch (e) {
//     print('Error getting user details: $e');
//     return null;
//   }
// }

// Updated UserData.fromJson method to handle both 'id' and 'userid' fields
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
    print('UserData.fromJson input: $json');
    
    // Try both 'id' and 'userid' fields - login response uses 'userid', details response uses 'id'
    String userId = json['id'] ?? json['userid'] ?? '';
    print('Extracted userId: $userId');
    
    return UserData(
      id: userId,
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