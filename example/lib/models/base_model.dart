import 'package:kr_extensions/date_format.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

@immutable
abstract class BaseModel {
  final String id;
  final DateTime createdAt;

  BaseModel({
    required String? id,
    required DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  @mustCallSuper
  @mustBeOverridden
  @useResult
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': createdAt.stamp,
    };
  }

  BaseModel.fromMap(Map<String, dynamic> data)
      : id = data['id'],
        createdAt = data['createdAt'].toDate();
}

@immutable
abstract class BaseUserModel extends BaseModel {
  final String userId;

  BaseUserModel({
    required super.id,
    required this.userId,
    required super.createdAt,
  });

  @override
  @mustCallSuper
  @mustBeOverridden
  @useResult
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      ...super.toMap(),
    };
  }

  BaseUserModel.fromMap(Map<String, dynamic> data)
      : userId = data['userId'],
        super.fromMap(data);
}
