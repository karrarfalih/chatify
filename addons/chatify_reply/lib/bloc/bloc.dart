import 'package:chatify/chatify.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'event.dart';
part 'state.dart';

class ReplyBloc extends Bloc<ReplyEvent, ReplyState> {

  static ReplyBloc? instance;

  ReplyBloc(Chat chat) : super(const ReplyState.initial()) {
    instance = this;
    on<ReplyEvent>((event, emit) async {
      switch (event) {
        case ReplyStart():
          emit(state.copyWith(replying: event.message));
        case ReplyCancel():
          emit(const ReplyState.initial());
      }
    });
  }

  @override
  Future<void> close() {
    instance = null;
    return super.close();
  }
}
