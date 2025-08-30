## 0.1.5

- Minor fixes

## 0.1.4

### Addons
- Introduced addon system (`ChatAddon`, `ChatAddonsRegistry`) to plug optional features into the chat UI (headers, list wrappers, per-message wrappers, input wrappers, options, composer actions).
- Selection moved out of core into first-party addon: `chatify_selection` (provides selection header, drag-to-select listener, and per-message selection UI).

## 0.1.3

Massive refactor and new architecture. This release is a ground-up rewrite that decouples the UI from any specific backend. It is not drop-in compatible with 0.1.2.

### BREAKING CHANGES
- Removed legacy Firebase-first API (`ChatifyController`, `ChatifyOptions`, built-in Firestore/Storage/Messaging glue)
- Introduced headless data layer contracts:
  - `ChatRepo` (chats pagination, create/find/delete, unread count)
  - `MessageRepo` (messages pagination, CRUD, reactions, seen/delivered, status)
- Introduced explicit initialization via `Chatify.init` with:
  - `currentUser`, `chatRepo`, `messageRepoFactory`, `uploaderFactory`, `messageProviders`
- Replaced message pipeline with provider-based rendering:
  - `MessageProviderRegistry`, `BasicMessageProvider`, `MediaMessageProvider`
  - `ComposerAction`, `BasicComposerResult`, `MediaComposerResult`
- New upload/progress model:
  - `AttachmentUploader`, `MessageTaskRegistry`, `TaskProgress`, `UploadResult`
- UI restructured:
  - `ChatsPage` with optional `ChatsLayout` and nested navigation to
  - `MessagesPage` with optional `ChatLayout`
- Domain models and helpers revised: `Chat`, `User`, `Message`, `MessageContent`, `Result<T>`, `PaginatedResult<T>`

### Removed
- Tight coupling to Firebase (Firestore/Storage/Messaging). You must wire your own data/storage/notifications if needed.
- Old navigation helpers and options under `ChatifyController`.

### New
- Composable, backend-agnostic chat UI for Flutter (mobile/web/desktop)
- Animated messages list with pending/failed queues and day separators
- Swipe-to-reply, copy, edit, delete, multi-select
- Extensible attachment menu fed by registered `MessageProvider`s
- Built-in EN/AR localization maps (GetX `.tr` friendly)

### Migration guide (from <= 0.1.2)
1) Delete usages of `ChatifyController` and `ChatifyOptions`
2) Implement `ChatRepo` and `MessageRepo` for your backend
3) Create one or more `MessageProvider`s for your supported content types
4) Provide an `AttachmentUploader` for media uploads
5) Initialize:
   ```dart
   await Chatify.init(
     currentUser: me,
     chatRepo: MyChatRepo(userId: me.id),
     messageRepoFactory: (chat) => MyMessageRepo(chat: chat),
     uploaderFactory: (att) => MyUploader(attachment: att),
     messageProviders: [TextMessageProvider(), /* ... */],
   );
   ```
6) Replace UI usage:
   - Old: controller screens → New: `ChatsPage` → `MessagesPage`
   - Programmatic open: `Chatify().openChatById(...)` or `.openChatByUser(...)`

For the legacy API/README, see the previous package docs on pub.dev: [chatify (<= 0.1.2)](https://pub.dev/packages/chatify).

---

## 0.1.2

- Internal pre-refactor release.
