import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser; // package:html

class CikService {
  String sanitizeSearchTerm(String searchTerm) {
    final pattern = RegExp(r'[^A-Za-z0-9&\-., ]');
    var sanitized = searchTerm.replaceAll(pattern, '');
    sanitized = sanitized.replaceAll(RegExp(r'\s+'), ' ');
    return sanitized.trim();
  }

  /// Matches our Web Apps call
  Future<List<Map<String, String>>> obtainCikNumber(
      String rawSearchTerm) async {
    final searchTerm = sanitizeSearchTerm(rawSearchTerm);

    final url = Uri.parse('https://www.sec.gov/cgi-bin/cik_lookup');
    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Accept':
          'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8',
      'User-Agent': 'JamesAllen <ja799793@ucf.edu> (Adversarial Apps)',
      'Referer': 'https://www.sec.gov/search-filings/cik-lookup',
    };

    final formData = 'company=$searchTerm';

    final response = await http.post(url, headers: headers, body: formData);

    if (response.statusCode == 200) {
      final document = html_parser.parse(response.body);

      final preTags = document.getElementsByTagName('pre');

      final regex = RegExp(r'(\d{10})\s+(.*?)\s*$', multiLine: true);

      final List<Map<String, String>> cikData = [];

      for (var preTag in preTags) {
        final preText = preTag.text;
        final matches = regex.allMatches(preText);
        for (var match in matches) {
          final cik = match.group(1) ?? '';
          final companyName = match.group(2) ?? '';
          cikData.add({
            'name': companyName,
            'cik': cik,
          });
        }
      }

      return cikData;
    } else {
      throw Exception(
        'Failed to fetch data: ${response.statusCode} ${response.body}',
      );
    }
  }
}
