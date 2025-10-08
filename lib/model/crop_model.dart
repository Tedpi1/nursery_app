// lib/model/crop_model.dart
import 'package:flutter/material.dart';

class cropDetails {
  final String crop;
  final String partitions;
  final String sowingDate;
  final String plantingDate;
  final int seedsRequired;
  final int achieved;
  final String status;
  final List<BatchData> batches; // ✅ add this

  cropDetails({
    required this.crop,
    required this.partitions,
    required this.sowingDate,
    required this.plantingDate,
    required this.seedsRequired,
    required this.achieved,
    required this.status,
    required this.batches,
  });

  factory cropDetails.fromJson(Map<String, dynamic> json) {
    return cropDetails(
      crop: json['crop'] ?? '',
      partitions: json['partitions'] ?? '',
      sowingDate: json['sowingDate'] ?? '',
      plantingDate: json['plantingDate'] ?? '',
      seedsRequired: json['seedsRequired'] ?? 0,
      achieved: json['achieved'] ?? 0,
      status: json['status'] ?? 'Pending',
      batches: (json['batches'] as List<dynamic>?)
          ?.map((b) => BatchData.fromJson(b))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'crop': crop,
    'partitions': partitions,
    'sowingDate': sowingDate,
    'plantingDate': plantingDate,
    'seedsRequired': seedsRequired,
    'achieved': achieved,
    'status': status,
    'batches': batches.map((b) => b.toJson()).toList(),
  };
}

/// ✅ A single batch record under a crop
class BatchData {
  final String batchID;
  final String sowingDate;
  final String plantingDate;
  final int seedsRequired;
  final int achieved;
  final String status;

  BatchData({
    required this.batchID,
    required this.sowingDate,
    required this.plantingDate,
    required this.seedsRequired,
    required this.achieved,
    required this.status,
  });

  factory BatchData.fromJson(Map<String, dynamic> json) {
    return BatchData(
      batchID: json['batchID'] ?? '',
      sowingDate: json['sowingDate'] ?? '',
      plantingDate: json['plantingDate'] ?? '',
      seedsRequired: json['seedsRequired'] ?? 0,
      achieved: json['achieved'] ?? 0,
      status: json['status'] ?? 'Pending',
    );
  }

  Map<String, dynamic> toJson() => {
    'batchID': batchID,
    'sowingDate': sowingDate,
    'plantingDate': plantingDate,
    'seedsRequired': seedsRequired,
    'achieved': achieved,
    'status': status,
  };
}
