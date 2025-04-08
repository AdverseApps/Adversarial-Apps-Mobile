import 'package:http/http.dart' as http;
import 'dart:convert';

class SamService {
  Future<Map<String, dynamic>> getCompanyDetails(String uei) async {
    final url = Uri.parse('https://adversarialapps.com/api/call-python-api');

    final body = jsonEncode({
      "action": "fetch_sam_data",
      "uei": uei,
    });

    final response = await http.post(url, body: body);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      if (responseData['status'] == 'success') {
        // Assuming the API returns a structure like { status: "success", company: { ... } }
        return responseData['company'];
      } else {
        throw Exception('Invalid response structure: ${response.body}');
      }
    } else {
      throw Exception(
          'Failed to fetch data: ${response.statusCode} ${response.body}');
    }
  }
}
