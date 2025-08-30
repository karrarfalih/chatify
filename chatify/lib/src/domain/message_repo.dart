import 'models/chat.dart';
import 'models/messages/message.dart';
import 'models/messages/content.dart';
import '../helpers/paginated_result.dart';
import '../helpers/result.dart';

abstract class MessageRepo {
  final Chat chat;

  MessageRepo(this.chat);

  Stream<PaginatedResult<Message>> messagesStream();

  void loadMore();

  FutureResult<bool> add(
    MessageContent message, {
    String? attachmentUrl,
    Map<String, dynamic> metadata = const {},
  });

  FutureResult<bool> update(String content, String messageId);

  FutureResult<Message> getById(String messageId);

  FutureResult<bool> addReaction(String messageId, String emoji);

  FutureResult<bool> removeReaction(String messageId, String emoji);

  FutureResult<bool> delete(String id, bool forMe);

  FutureResult<bool> markAsSeen(String id);

  FutureResult<bool> markAsDelivered(String id);

  FutureResult<bool> updateStatus(ChatStatus status);

  Stream<ChatStatus> getStatus();

  void dispose();
}
