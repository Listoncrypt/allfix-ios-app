import 'package:url_launcher/url_launcher.dart';
import '../constants/app_strings.dart';

class UrlLauncherHelper {
  UrlLauncherHelper._();

  /// Launches WhatsApp with specified or default prefilled message
  static Future<bool> launchWhatsApp({String? customMessage}) async {
    final message = customMessage ?? 'Hello ALLFIX Xpress, I need assistance with a service.';
    final encodedMessage = Uri.encodeComponent(message);
    final urlString = 'https://wa.me/${AppStrings.whatsappRawNumber}?text=$encodedMessage';
    final uri = Uri.parse(urlString);

    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Fallback to universal link
      return await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
  }

  /// Launch WhatsApp for a specific Service Request confirmation
  static Future<bool> launchRequestDispatch({
    required String requestId,
    required String category,
  }) async {
    final message =
        'Hello ALLFIX Support, I just submitted request $requestId for $category. Can you connect me with a specialist?';
    return await launchWhatsApp(customMessage: message);
  }

  /// Launch WhatsApp for a Property Listing inquiry
  static Future<bool> launchPropertyInquiry({
    required String propertyTitle,
    required String location,
    required String propertyId,
  }) async {
    final message =
        'Hello ALLFIX Properties, I am inquiring about $propertyTitle in $location (Ref: $propertyId). Is it available for inspection?';
    return await launchWhatsApp(customMessage: message);
  }

  /// Dial the official hotline directly
  static Future<bool> callHotline() async {
    final uri = Uri.parse('tel:+2347058099045');
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri);
    }
    return false;
  }

  /// Send email to official support
  static Future<bool> sendSupportEmail({String? subject, String? body}) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: AppStrings.supportEmail,
      query: <String, String>{
        if (subject != null) 'subject': subject,
        if (body != null) 'body': body,
      }.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&'),
    );
    if (await canLaunchUrl(emailUri)) {
      return await launchUrl(emailUri);
    }
    return false;
  }

  /// Open external URL (e.g. Facebook, Instagram, TikTok)
  static Future<bool> openExternalUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}
