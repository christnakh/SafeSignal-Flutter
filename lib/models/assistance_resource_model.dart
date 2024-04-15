import 'package:equatable/equatable.dart';

class AssistanceResourceModel extends Equatable {
  final int? resourceId;
  final String? title;
  final String? content;
  final String? category;

  const AssistanceResourceModel({
    this.resourceId,
    this.title,
    this.content,
    this.category,
  });

  @override
  List<Object?> get props => [resourceId, title, content, category];

  factory AssistanceResourceModel.fromJson(Map<String, dynamic> json) {
    return AssistanceResourceModel(
      resourceId: json['resource_id'] as int?,
      title: json['title'] as String?,
      content: json['content'] as String?,
      category: json['category'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resource_id': resourceId,
      'title': title,
      'content': content,
      'category': category,
    };
  }

  AssistanceResourceModel copyWith({
    int? resourceId,
    String? title,
    String? content,
    String? category,
  }) {
    return AssistanceResourceModel(
      resourceId: resourceId ?? this.resourceId,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
    );
  }
}
