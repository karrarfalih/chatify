import 'chatify_localizations.dart';

/// The translations for English (`en`).
class ChatifyLocalizationsEn extends ChatifyLocalizations {
  ChatifyLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get messeges => 'Messages';

  @override
  String get message => 'Message';

  @override
  String get search => 'Search';

  @override
  String get delete => 'Delete';

  @override
  String get copy => 'Copy';

  @override
  String get edit => 'Edit';

  @override
  String get reply => 'Reply';

  @override
  String get confirm => 'Confirm';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'Ok';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get confirmDeleteMessage => 'Are you sure you want to delete the message?';

  @override
  String get confirmDeleteMessagesTitle => 'Are you sure you want to delete these messages?';

  @override
  String confirmDeleteMessagesCount(int count) {
    return 'Delete $count messages?';
  }

  @override
  String get selected => 'Selected';

  @override
  String get deleteForAll => 'Delete for all';

  @override
  String get confirmDeleteChat => 'Are you sure you want to delete the chat?';

  @override
  String get deleteChat => 'Delete chat';

  @override
  String get selectMedia => 'Select media';

  @override
  String get addCaption => 'Add caption';

  @override
  String get selectedMedia => 'Selected media';

  @override
  String get waitingConnection => 'Waiting for connection...';

  @override
  String get connecting => 'Connecting...';

  @override
  String get online => 'Online';

  @override
  String get lastSeenRecently => 'Last seen recently';

  @override
  String get lastSeenJustNow => 'Last seen just now';

  @override
  String lastSeenMinutes(int minutes) {
    return 'Last seen $minutes minutes ago';
  }

  @override
  String lastSeenHours(int hours) {
    return 'Last seen $hours hours ago';
  }

  @override
  String lastSeenDays(int days) {
    return 'Last seen $days days ago';
  }

  @override
  String lastSeenWeeks(int weeks) {
    return 'Last seen $weeks weeks ago';
  }

  @override
  String get lastSeenLongTime => 'Last seen a long time ago';

  @override
  String get me => 'Me';

  @override
  String get save => 'Save';

  @override
  String get savedToGallery => 'Saved to gallery';

  @override
  String get failedToSave => 'Failed to save';

  @override
  String get noMessages => 'No messages';

  @override
  String get savedMessages => 'Saved messages';

  @override
  String get newMessage => 'New message';

  @override
  String get deletedMessage => 'Deleted message';

  @override
  String get edited => 'Edited';

  @override
  String get sayHi => 'Say hi!';

  @override
  String get noRecentsEmojis => 'No recent emojis';

  @override
  String get member => 'Member';

  @override
  String get slideToCancel => 'Slide to cancel';

  @override
  String get to => 'To: ';

  @override
  String get imageMessage => 'Image Message';

  @override
  String get voiceMessage => 'Voice Message';

  @override
  String get unSuppprtedMessage => 'Unsuppprted Message';
}
