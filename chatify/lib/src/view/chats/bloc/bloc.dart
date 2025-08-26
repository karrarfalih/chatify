import 'dart:async';
import '../../../../chatify.dart';
import '../../../domain/chat_repo.dart';
import '../../../helpers/paginated_result.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';

part 'event.dart';
part 'state.dart';

class ChatsBloc extends Bloc<ChatsEvent, ChatsState> {
  late final ChatRepo chatRepo;

  final int pageSize = 20;

  StreamSubscription<PaginatedResult<Chat>>? _chatsSubscription;

  ChatsBloc({required String userId}) : super(ChatsState.initial()) {
    chatRepo = Chatify.chatRepo;
    on<ChatsEvent>((event, emit) async {
      switch (event) {
        case ChatsRingUser():
          break;
        case ChatsUpdated():
          emit(state.copyWith(chats: event.chats));
        case ChatsLoadMore():
          break;
      }
    });
    on<ChatsLoadMore>(
      (event, emit) {
        chatRepo.loadMore();
      },
      transformer: (events, mapper) => events
          .throttleTime(const Duration(milliseconds: 300), trailing: true)
          .asyncExpand(mapper),
    );

    _chatsSubscription = chatRepo.chatsStream().listen((chats) {
      add(ChatsUpdated(chats));
    });
  }

  @override
  Future<void> close() {
    _chatsSubscription?.cancel();
    chatRepo.dispose();
    return super.close();
  }
}
