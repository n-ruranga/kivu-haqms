import 'package:equatable/equatable.dart';

/// Domain model for the signed-in user.
/// Duke: map Firebase User → UserEntity in the data layer.
class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.displayName,
    this.email,
    this.phoneNumber,
  });

  final String id;
  final String displayName;
  final String? email;
  final String? phoneNumber;

  @override
  List<Object?> get props => [id, displayName, email, phoneNumber];
}
