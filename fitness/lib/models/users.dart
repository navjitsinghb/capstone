
class User {
  final String name;
  final String email;
  // final String password;
  // final String phoneNumber;

  const User({
    required this.name,
    required this.email,
    // required this.password,
    // required this.phoneNumber,
  });

Map<String, dynamic> toJson() => {
      'name': name,
      'email': email,
      // 'password': password,
      // 'phoneNumber': phoneNumber,
  };

}