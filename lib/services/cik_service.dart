import 'package:http/http.dart' as http;
import 'dart:convert';

class CikService {
  Future<List<Map<String, dynamic>>> obtainCikNumber(String searchTerm) async {
    // Define the API endpoint
    final url = Uri.parse('https://adversarialapps.com/api/call-python-api');

    // Prepare the request body
    final body = jsonEncode({
      "action": "obtain_cik_number",
      "search_term": searchTerm,
    });

    // Make the POST request
    final response = await http.post(url, body: body);

    // Parse the response
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      if (responseData['status'] == 'success' &&
          responseData['companies'] != null) {
        final data = responseData['companies'] as List;

        return data.map((item) {
          return {
            'name': item['Company Name'] ?? '',
            'cik': item['CIK'] ?? '',
          };
        }).toList();
      } else {
        throw Exception('Invalid response structure: ${response.body}');
      }
    } else {
      throw Exception(
          'Failed to fetch data: ${response.statusCode} ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getCompanyDetails(String cik) async {
    final url = Uri.parse('https://adversarialapps.com/api/call-python-api');

    final body = jsonEncode({
      "action": "get_sec_data",
      "search_term": cik,
    });

    final response = await http.post(url, body: body);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      if (responseData['status'] == 'success') {
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
