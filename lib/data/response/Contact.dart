import 'package:aloha/data/response/Message.dart';

class ContactResponse {
  ContactResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  bool success;
  List<Contact> data;
  String message;

  factory ContactResponse.fromJson(Map<String, dynamic> json) =>
      ContactResponse(
        success: json["success"],
        data: List<Contact>.from(json["data"].map((x) => Contact.fromJson(x))),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "message": message,
      };
}

class Contact {
  Contact({
    required this.id,
    required this.customer,
    required this.createdAt,
    required this.agent,
    required this.lastMessage,
    required this.updatedAt,
  });

  int id;
  Customer customer;
  DateTime createdAt;
  List<Agent> agent;
  Message lastMessage;
  DateTime updatedAt;

  factory Contact.fromJson(Map<String, dynamic> json) => Contact(
        id: json["id"],
        customer: Customer.fromJson(json["customer"]),
        createdAt: DateTime.parse(json["created_at"]),
        agent: List<Agent>.from(json["agent"].map((x) => Agent.fromJson(x))),
        lastMessage: Message.fromJson(json["lastMessage"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "customer": customer.toJson(),
        "created_at": createdAt.toIso8601String(),
        "agent": List<dynamic>.from(agent.map((x) => x.toJson())),
        "lastMessage": lastMessage.toJson(),
        "updated_at": updatedAt.toIso8601String(),
      };
}

class Agent {
  Agent({
    required this.id,
    required this.fullName,
    required this.username,
    required this.email,
    required this.role,
    required this.profilePhoto,
    required this.createdAt,
    required this.updatedAt,
  });

  int id;
  String fullName;
  String username;
  String email;
  String role;
  String? profilePhoto;
  DateTime createdAt;
  DateTime updatedAt;

  factory Agent.fromJson(Map<String, dynamic> json) => Agent(
        id: json["id"],
        fullName: json["full_name"],
        username: json["username"],
        email: json["email"],
        role: json["role"],
        profilePhoto: json["profile_photo"] as String?,
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "full_name": fullName,
        "username": username,
        "email": email,
        "role": role,
        "profile_photo": profilePhoto,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}

class Customer {
  Customer({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  int id;
  String name;
  String phoneNumber;
  DateTime createdAt;
  DateTime updatedAt;

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json["id"],
        name: json["name"],
        phoneNumber: json["phoneNumber"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "phoneNumber": phoneNumber,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}