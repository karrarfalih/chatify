import 'package:chatify/chatify.dart';
import 'package:example/models/base_model.dart';
import 'package:example/utilz/extensions.dart';
import 'package:get/get.dart';

class User extends BaseModel {
  final String firstName;
  final String lastName;
  final String? phone;
  final String? image;
  final List<String> clientNotificationIds;
  final DateTime? updatedAt;

  User({
    required super.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.image,
    this.updatedAt,
    super.createdAt,
    this.clientNotificationIds = const [],
  });

  User.fromMap(Map<String, dynamic> data)
      : firstName = data['firstName'].toString().toTitleCase(),
        lastName = data['lastName'].toString().toTitleCase(),
        phone = data['phone'],
        image = data['image'],
        updatedAt = data['updatedAt']?.toDate(),
        clientNotificationIds = data['clientNotificationIds'] ?? [],
        super.fromMap(data);

  @override
  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName.toTitleCase(),
      'lastName': lastName.toTitleCase(),
      'phone': phone,
      'image': image,
      'searchTerms': generateSearchTerms,
      ...super.toMap(),
    };
  }

  ChatifyUser toChatifyUser() {
    return ChatifyUser(
      id: id,
      name: '$firstName $lastName',
      data: toMap(),
      profileImage: image,
      clientNotificationIds: clientNotificationIds,
    );
  }

  List<String> get generateSearchTerms {
    List<String> terms = [];
    for (int i = 0; i < firstName.length; i++) {
      for (int j = 0; j < firstName.length - i; j++) {
        terms.add(firstName.substring(j, i + j + 1));
      }
    }
    if (phone != null) {
      terms.add(phone!);
      terms.add(phone!.phoneLocally);
      terms.add(phone!.phoneUniversal);
    }
    terms.add(lastName);
    return terms;
  }

  static T getEnumFromString<T>(
    String? key,
    List<T> values, {
    required T defaultValue,
  }) {
    return values
            .firstWhereOrNull((v) => key == v.toString().split('.').last) ??
        defaultValue;
  }
}
