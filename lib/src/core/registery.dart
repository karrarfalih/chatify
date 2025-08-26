import 'package:chatify/src/core/chatify.dart';
import 'package:chatify/src/domain/models/messages/content.dart';
import 'package:chatify/src/core/composer.dart';
import 'package:chatify/src/core/provider.dart';

class MessageProviderRegistry {
  MessageProviderRegistry._();

  static final instance = MessageProviderRegistry._();

  final Map<String, MessageProvider<MessageContent>> _providers = {};
  bool _initialized = false;

  void register(MessageProvider provider) {
    _providers[provider.type] = provider;
  }

  void registerAll(Iterable<MessageProvider> providers) {
    for (final p in providers) {
      register(p);
    }
    _initialized = true;
  }

  MessageProvider<MessageContent>? getByType(String? type) {
    if (type == null) return null;
    return _providers[type];
  }

  MessageProvider<MessageContent>? getByMessage(MessageContent message) {
    return getByType(message.runtimeType.toString());
  }

  void ensureInitialized() {
    if (_initialized) return;
    registerDefaultMessageProviders();
    _initialized = true;
  }

  void registerDefaultMessageProviders() {
    final registry = MessageProviderRegistry.instance;
    registry.registerAll(Chatify.messageProviders);
  }

  List<ComposerAction> get composerActions => _providers.values
      .expand((p) => p.composerActions)
      .toList(growable: false);

  Iterable<MessageProvider<MessageContent>> get providers => _providers.values;
}
