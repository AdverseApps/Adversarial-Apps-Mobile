import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser; // package:html

class CikService {
  // 1) This replicates the Python sanitize_search_term logic in a simpler manner
  String sanitizeSearchTerm(String searchTerm) {
    // Allow alphanumeric, &, -, ., ,, spaces
    final pattern = RegExp(r'[^A-Za-z0-9&\-., ]');
    // Remove invalid characters
    var sanitized = searchTerm.replaceAll(pattern, '');
    // Normalize multiple spaces to one
    sanitized = sanitized.replaceAll(RegExp(r'\s+'), ' ');
    return sanitized.trim();
  }

  /// 2) The main method that replicates `obtain_cik_number`.
  ///    - Returns list of { "name": "...", "cik": "..." } maps.
  Future<List<Map<String, String>>> obtainCikNumber(
      String rawSearchTerm) async {
    // Sanitize the search term
    final searchTerm = sanitizeSearchTerm(rawSearchTerm);

    final url = Uri.parse('https://www.sec.gov/cgi-bin/cik_lookup');
    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Accept':
          'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8',
      'User-Agent': 'JamesAllen <ja799793@ucf.edu> (Adversarial Apps)',
      'Referer': 'https://www.sec.gov/search-filings/cik-lookup',
    };

    // The Python code sends "company" as form data
    final formData = 'company=$searchTerm';

    // Make the POST request
    final response = await http.post(url, headers: headers, body: formData);

    if (response.statusCode == 200) {
      // 3) Parse the HTML
      final document = html_parser.parse(response.body);

      // 4) Grab all <pre> tags (Python code uses soup.find_all("pre"))
      final preTags = document.getElementsByTagName('pre');

      // We'll look for lines matching `(\d{10})\s+(.*?)\s*$` in each <pre>.
      final regex = RegExp(r'(\d{10})\s+(.*?)\s*$', multiLine: true);

      final List<Map<String, String>> cikData = [];

      for (var preTag in preTags) {
        final preText = preTag.text;
        final matches = regex.allMatches(preText);
        for (var match in matches) {
          final cik = match.group(1) ?? '';
          final companyName = match.group(2) ?? '';
          // Store data
          cikData.add({
            'name': companyName,
            'cik': cik,
          });
        }
      }

      // Return the extracted list
      return cikData;
    } else {
      throw Exception(
        'Failed to fetch data: ${response.statusCode} ${response.body}',
      );
    }
  }
}
