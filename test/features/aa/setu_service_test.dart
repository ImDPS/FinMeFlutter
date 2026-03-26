import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:finme/features/aa/data/setu_service.dart';

class MockSetuService extends Mock implements SetuService {}

void main() {
  late MockSetuService mockService;

  setUp(() {
    mockService = MockSetuService();
    when(() => mockService.createConsentRequest(phoneNumber: any(named: 'phoneNumber')))
        .thenAnswer((_) async => 'https://setu.co/consent?id=test-123');
  });

  group('SetuService', () {
    test('createConsentRequest returns a URL', () async {
      final url = await mockService.createConsentRequest(phoneNumber: '+919876543210');
      expect(url, isNotEmpty);
      expect(url, contains('https://'));
    });
  });
}
