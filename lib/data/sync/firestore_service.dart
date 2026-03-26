import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> pushOperation({
    required String operation,
    required String payload,
  }) async {
    await _firestore
        .collection('sync_ops')
        .add({'operation': operation, 'payload': payload, 'ts': FieldValue.serverTimestamp()});
  }
}
