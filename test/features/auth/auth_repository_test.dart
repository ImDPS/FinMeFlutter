import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:finme/features/auth/data/auth_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late AuthRepository repo;

  setUp(() {
    repo = MockAuthRepository();
    when(() => repo.hashPin('1234')).thenReturn('hashed_1234');
    when(() => repo.verifyPin('1234', 'hashed_1234')).thenReturn(true);
    when(() => repo.verifyPin('0000', 'hashed_1234')).thenReturn(false);
  });

  group('AuthRepository', () {
    test('hashPin returns a non-empty string', () {
      final hash = repo.hashPin('1234');
      expect(hash.isNotEmpty, true);
    });

    test('verifyPin returns true for correct PIN', () {
      expect(repo.verifyPin('1234', 'hashed_1234'), true);
    });

    test('verifyPin returns false for wrong PIN', () {
      expect(repo.verifyPin('0000', 'hashed_1234'), false);
    });
  });
}
