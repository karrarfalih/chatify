import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'event.dart';
part 'state.dart';

class ChatRecordBloc extends Bloc<ChatRecordEvent, ChatRecordState> {


  ChatRecordBloc() : super(ChatRecordState.initial()) {
    on<ChatRecordEvent>((event, emit) async {
      switch (event) {
        case ChatRecordStart():
          emit(state.copyWith(isRecording: true));
      }
    });


  }
}
