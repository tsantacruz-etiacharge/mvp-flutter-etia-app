import 'dart:io' show Platform;

import 'package:url_launcher/url_launcher.dart';

Future<void> openMapsTravel(double lat, double lng) async {
  final coords = '$lat,$lng';

  final Uri url;
  if (Platform.isIOS) {
    url = Uri.https('maps.apple.com', '/', {'daddr': coords, 'dirflg': 'd'});
  } else {
    url = Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'destination': coords,
      'travelmode': 'driving',
    });
  }

  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }
}
