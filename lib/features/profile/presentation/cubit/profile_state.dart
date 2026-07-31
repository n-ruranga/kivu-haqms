import 'package:equatable/equatable.dart';
import 'package:kivu_haqms/features/profile/domain/entities/profile_entity.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

final class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

final class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

final class ProfileLoaded extends ProfileState {
  const ProfileLoaded(this.profile);

  final ProfileEntity profile;

  @override
  List<Object?> get props => [profile];
}

final class ProfileSaving extends ProfileState {
  const ProfileSaving(this.profile);

  final ProfileEntity profile;

  @override
  List<Object?> get props => [profile];
}

final class ProfileSaved extends ProfileState {
  const ProfileSaved(this.profile);

  final ProfileEntity profile;

  @override
  List<Object?> get props => [profile];
}

final class ProfileFailure extends ProfileState {
  const ProfileFailure(this.message, {this.previousProfile});

  final String message;
  final ProfileEntity? previousProfile;

  @override
  List<Object?> get props => [message, previousProfile];
}
