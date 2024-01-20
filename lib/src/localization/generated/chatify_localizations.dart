import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'chatify_localizations_ar.dart';
import 'chatify_localizations_en.dart';

/// Callers can lookup localized strings with an instance of ChatifyLocalizations
/// returned by `ChatifyLocalizations.of(context)`.
///
/// Applications need to include `ChatifyLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/chatify_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: ChatifyLocalizations.localizationsDelegates,
///   supportedLocales: ChatifyLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the ChatifyLocalizations.supportedLocales
/// property.
abstract class ChatifyLocalizations {
  ChatifyLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static ChatifyLocalizations? of(BuildContext context) {
    return Localizations.of<ChatifyLocalizations>(context, ChatifyLocalizations);
  }

  static const LocalizationsDelegate<ChatifyLocalizations> delegate = _ChatifyLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @messeges.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messeges;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @reply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get reply;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get ok;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @confirmDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the message?'**
  String get confirmDeleteMessage;

  /// No description provided for @confirmDeleteMessagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete these messages?'**
  String get confirmDeleteMessagesTitle;

  /// Confirm delete messages count
  ///
  /// In en, this message translates to:
  /// **'Delete {count} messages?'**
  String confirmDeleteMessagesCount(int count);

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @deleteForAll.
  ///
  /// In en, this message translates to:
  /// **'Delete for all'**
  String get deleteForAll;

  /// No description provided for @confirmDeleteChat.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the chat?'**
  String get confirmDeleteChat;

  /// No description provided for @deleteChat.
  ///
  /// In en, this message translates to:
  /// **'Delete chat'**
  String get deleteChat;

  /// No description provided for @selectMedia.
  ///
  /// In en, this message translates to:
  /// **'Select media'**
  String get selectMedia;

  /// No description provided for @addCaption.
  ///
  /// In en, this message translates to:
  /// **'Add caption'**
  String get addCaption;

  /// No description provided for @selectedMedia.
  ///
  /// In en, this message translates to:
  /// **'Selected media'**
  String get selectedMedia;

  /// No description provided for @waitingConnection.
  ///
  /// In en, this message translates to:
  /// **'Waiting for connection...'**
  String get waitingConnection;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get connecting;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @lastSeenRecently.
  ///
  /// In en, this message translates to:
  /// **'Last seen recently'**
  String get lastSeenRecently;

  /// No description provided for @lastSeenJustNow.
  ///
  /// In en, this message translates to:
  /// **'Last seen just now'**
  String get lastSeenJustNow;

  /// Last seen minutes ago
  ///
  /// In en, this message translates to:
  /// **'Last seen {minutes} minutes ago'**
  String lastSeenMinutes(int minutes);

  /// Last seen hours ago
  ///
  /// In en, this message translates to:
  /// **'Last seen {hours} hours ago'**
  String lastSeenHours(int hours);

  /// Last seen days ago
  ///
  /// In en, this message translates to:
  /// **'Last seen {days} days ago'**
  String lastSeenDays(int days);

  /// Last seen weeks ago
  ///
  /// In en, this message translates to:
  /// **'Last seen {weeks} weeks ago'**
  String lastSeenWeeks(int weeks);

  /// No description provided for @lastSeenLongTime.
  ///
  /// In en, this message translates to:
  /// **'Last seen a long time ago'**
  String get lastSeenLongTime;

  /// No description provided for @me.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get me;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @savedToGallery.
  ///
  /// In en, this message translates to:
  /// **'Saved to gallery'**
  String get savedToGallery;

  /// No description provided for @failedToSave.
  ///
  /// In en, this message translates to:
  /// **'Failed to save'**
  String get failedToSave;

  /// No description provided for @noMessages.
  ///
  /// In en, this message translates to:
  /// **'No messages'**
  String get noMessages;

  /// No description provided for @savedMessages.
  ///
  /// In en, this message translates to:
  /// **'Saved messages'**
  String get savedMessages;

  /// No description provided for @newMessage.
  ///
  /// In en, this message translates to:
  /// **'New message'**
  String get newMessage;

  /// No description provided for @deletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Deleted message'**
  String get deletedMessage;

  /// No description provided for @edited.
  ///
  /// In en, this message translates to:
  /// **'Edited'**
  String get edited;

  /// No description provided for @sayHi.
  ///
  /// In en, this message translates to:
  /// **'Say hi!'**
  String get sayHi;

  /// No description provided for @noRecentsEmojis.
  ///
  /// In en, this message translates to:
  /// **'No recent emojis'**
  String get noRecentsEmojis;

  /// No description provided for @member.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get member;

  /// No description provided for @slideToCancel.
  ///
  /// In en, this message translates to:
  /// **'Slide to cancel'**
  String get slideToCancel;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To: '**
  String get to;

  /// No description provided for @imageMessage.
  ///
  /// In en, this message translates to:
  /// **'Image Message'**
  String get imageMessage;

  /// No description provided for @voiceMessage.
  ///
  /// In en, this message translates to:
  /// **'Voice Message'**
  String get voiceMessage;

  /// No description provided for @unSuppprtedMessage.
  ///
  /// In en, this message translates to:
  /// **'Unsuppprted Message'**
  String get unSuppprtedMessage;
}

class _ChatifyLocalizationsDelegate extends LocalizationsDelegate<ChatifyLocalizations> {
  const _ChatifyLocalizationsDelegate();

  @override
  Future<ChatifyLocalizations> load(Locale locale) {
    return SynchronousFuture<ChatifyLocalizations>(lookupChatifyLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_ChatifyLocalizationsDelegate old) => false;
}

ChatifyLocalizations lookupChatifyLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return ChatifyLocalizationsAr();
    case 'en': return ChatifyLocalizationsEn();
  }

  throw FlutterError(
    'ChatifyLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
