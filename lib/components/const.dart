import 'package:url_launcher/url_launcher.dart';

const String portfolioUrl = 'https://houssameddine.netlify.app';
Future<void> launchURL() async {
  final Uri url = Uri.parse(portfolioUrl);
  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
}
