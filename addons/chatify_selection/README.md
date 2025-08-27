## Chatify Selection Addon

Optional message selection service for Chatify. Provides:
- Selection header (modal bar showing selected count and delete action)
- Drag-to-select listener over the messages list
- Per-message selection highlight and checkbox affordance

This addon plugs into Chatify via the addons API and can be enabled or disabled per app.

### Installation

```bash
flutter pub add chatify_selection
```

### Usage

Register the addon globally at init or per screen.

Global registration during init:

```dart
import 'package:chatify/chatify.dart';
import 'package:chatify_selection/chatify_selection.dart';

await Chatify.init(
  currentUser: currentUser,
  chatRepo: chatRepo,
  messageRepoFactory: (chat) => messageRepoFor(chat),
  uploaderFactory: (attachment) => uploaderFor(attachment),
  messageProviders: [
    // your message providers
  ],
  chatAddons: const [
    SelectionAddon(),
  ],
);
```

Or register on-demand before building chat screens:

```dart
ChatAddonsRegistry.instance.registerChatAddons(const [SelectionAddon()]);
```

### What it adds

- Header contribution: `SelectedMessagesHeader`
- Messages wrapper: `MessagesSelectionListener`
- Per-message wrapper: `MessageSelectionWidget`

All three are wired through the `SelectionAddon`, so no direct imports of the widgets are needed in your app.

### Notes

- The delete action uses your configured `MessageRepo` to delete selected messages.
- The addon is UI-only; style it via your app theme.

## Features

- Long-press to select or toggle selection
- Drag to select/deselect a continuous range
- Modal header shows selected count and delete action
- Per-message selection indicator and highlight
- Addon-based integration; no UI changes required in your app

## Getting started

1. Add the dependency (see Installation above)
2. Ensure `Chatify.init` is called in your app
3. Register `SelectionAddon` globally at init or before building chat screens

## Additional information

- Report issues and request features on the project homepage.
- Contributions are welcome; follow repo linting and code style.
- License: see LICENSE.
