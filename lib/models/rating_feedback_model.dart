import 'package:equatable/equatable.dart';

class RatingFeedbackModel extends Equatable {
  final int? ratingId;
  final int? userId;
  final int? requestId;
  final int rating;
  final String? feedback;
  final DateTime? ratingTime;

  const RatingFeedbackModel({
    this.ratingId,
    this.userId,
    this.requestId,
    required this.rating,
    this.feedback,
    this.ratingTime,
  });

  @override
  List<Object?> get props =>
      [ratingId, userId, requestId, rating, feedback, ratingTime];

  factory RatingFeedbackModel.fromJson(Map<String, dynamic> json) {
    return RatingFeedbackModel(
      ratingId: json['rating_id'] as int?,
      userId: json['user_id'] as int?,
      requestId: json['request_id'] as int?,
      rating: json['rating'] as int,
      feedback: json['feedback'] as String?,
      ratingTime: json['rating_time'] == null
          ? null
          : DateTime.parse(json['rating_time'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating_id': ratingId,
      'user_id': userId,
      'request_id': requestId,
      'rating': rating,
      'feedback': feedback,
      'rating_time': ratingTime?.toIso8601String(),
    };
  }

  RatingFeedbackModel copyWith({
    int? ratingId,
    int? userId,
    int? requestId,
    int? rating,
    String? feedback,
    DateTime? ratingTime,
  }) {
    return RatingFeedbackModel(
      ratingId: ratingId ?? this.ratingId,
      userId: userId ?? this.userId,
      requestId: requestId ?? this.requestId,
      rating: rating ?? this.rating,
      feedback: feedback ?? this.feedback,
      ratingTime: ratingTime ?? this.ratingTime,
    );
  }
}
