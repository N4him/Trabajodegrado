import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/like_entity.dart';

class LikeModel extends LikeEntity {
  const LikeModel({
    required super.userId,
    required super.likedAt,
  });

  factory LikeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LikeModel(
      userId: doc.id,
      likedAt: (data['likedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'likedAt': Timestamp.fromDate(likedAt),
    };
  }
}