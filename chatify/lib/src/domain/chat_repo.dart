import 'models/chat.dart';
import '../helpers/paginated_result.dart';
import '../helpers/result.dart';

abstract class ChatRepo {
  final String userId;

  ChatRepo({required this.userId});

  Stream<PaginatedResult<Chat>> chatsStream();

  void loadMore();

  FutureResult<Chat> create(List<User> members);

  FutureResult<Chat> findById(String id);

  FutureResult<Chat?> findByUser(String receiverId);

  FutureResult<bool> delete(String id);

  Stream<int> get unreadCountStream;

  void dispose();
}
