import 'package:equatable/equatable.dart';

class TransactionModel extends Equatable {
  final int? transactionId;
  final int? requestId;
  final double amount;
  final String? paymentMethod;
  final DateTime? transactionTime;

  const TransactionModel({
    this.transactionId,
    this.requestId,
    required this.amount,
    this.paymentMethod,
    this.transactionTime,
  });

  @override
  List<Object?> get props => [
        transactionId,
        requestId,
        amount,
        paymentMethod,
        transactionTime,
      ];

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      transactionId: json['transaction_id'] as int?,
      requestId: json['request_id'] as int?,
      amount: json['amount'] as double,
      paymentMethod: json['payment_method'] as String?,
      transactionTime: json['transaction_time'] == null
          ? null
          : DateTime.parse(json['transaction_time'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_id': transactionId,
      'request_id': requestId,
      'amount': amount,
      'payment_method': paymentMethod,
      'transaction_time': transactionTime?.toIso8601String(),
    };
  }

  TransactionModel copyWith({
    int? transactionId,
    int? requestId,
    double? amount,
    String? paymentMethod,
    DateTime? transactionTime,
  }) {
    return TransactionModel(
      transactionId: transactionId ?? this.transactionId,
      requestId: requestId ?? this.requestId,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionTime: transactionTime ?? this.transactionTime,
    );
  }
}
