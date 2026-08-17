import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  try {
    final response = await http.post(
      Uri.parse('https://humsafar.piyushassudani.in/api/v1/auth/login-pass'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': '9413879444', 'password': '300609'}),
    );
    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');
  } catch (e) {
    print('Error: $e');
  }
}
