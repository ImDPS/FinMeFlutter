import 'package:cloud_functions/cloud_functions.dart';

class SetuService {
  SetuService({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instanceFor(region: 'asia-south1');

  final FirebaseFunctions _functions;

  /// Calls the `createConsentRequest` Cloud Function.
  /// Returns the Setu redirect URL to show in a WebView.
  Future<String> createConsentRequest({required String phoneNumber}) async {
    final result = await _functions
        .httpsCallable('createConsentRequest')
        .call<Map<String, dynamic>>({'phoneNumber': phoneNumber});
    return result.data['redirectUrl'] as String;
  }
}
