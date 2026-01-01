part of 'about_cubit.dart';

abstract class AboutState {
  bool get showExtraInfo => false;
}

class AboutInitial extends AboutState {}

class AboutLoading extends AboutState {}

class AboutLoaded extends AboutState {
  final String appVersion;
  final String developer;
  final String description;

  AboutLoaded({
    required this.appVersion,
    required this.developer,
    required this.description,
  });
}

class AboutInfoToggled extends AboutState {
  @override
  final bool showExtraInfo;

  AboutInfoToggled(this.showExtraInfo);
}

class AboutError extends AboutState {
  final String message;

  AboutError(this.message);
}




