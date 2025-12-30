import 'package:flutter_bloc/flutter_bloc.dart';

part 'about_state.dart';

class AboutCubit extends Cubit<AboutState> {
  AboutCubit() : super(AboutInitial());

  void toggleInfo() {
    emit(AboutInfoToggled(!state.showExtraInfo));
  }

  void loadAppInfo() {
    // Simulate loading app information
    emit(AboutLoading());

    // In a real app, this would fetch data from an API or local storage
    Future.delayed(Duration(seconds: 1), () {
      emit(AboutLoaded(
        appVersion: '1.0.0',
        developer: 'فريق التطوير',
        description: 'تطبيق ألعاب التخمين الممتع',
      ));
    });
  }
}

