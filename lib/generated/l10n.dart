// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Timetable`
  String get timetable {
    return Intl.message(
      'Timetable',
      name: 'timetable',
      desc: '',
      args: [],
    );
  }

  /// `Exams`
  String get exams {
    return Intl.message(
      'Exams',
      name: 'exams',
      desc: '',
      args: [],
    );
  }

  /// `Empty Rooms`
  String get empty_rooms {
    return Intl.message(
      'Empty Rooms',
      name: 'empty_rooms',
      desc: '',
      args: [],
    );
  }

  /// `Time`
  String get time {
    return Intl.message(
      'Time',
      name: 'time',
      desc: '',
      args: [],
    );
  }

  /// `Monday`
  String get monday {
    return Intl.message(
      'Monday',
      name: 'monday',
      desc: '',
      args: [],
    );
  }

  /// `Tuesday`
  String get tuesday {
    return Intl.message(
      'Tuesday',
      name: 'tuesday',
      desc: '',
      args: [],
    );
  }

  /// `Wednesday`
  String get wednesday {
    return Intl.message(
      'Wednesday',
      name: 'wednesday',
      desc: '',
      args: [],
    );
  }

  /// `Thursday`
  String get thursday {
    return Intl.message(
      'Thursday',
      name: 'thursday',
      desc: '',
      args: [],
    );
  }

  /// `Friday`
  String get friday {
    return Intl.message(
      'Friday',
      name: 'friday',
      desc: '',
      args: [],
    );
  }

  /// `Calendar`
  String get calendar {
    return Intl.message(
      'Calendar',
      name: 'calendar',
      desc: '',
      args: [],
    );
  }

  /// `Compact`
  String get compact {
    return Intl.message(
      'Compact',
      name: 'compact',
      desc: '',
      args: [],
    );
  }

  /// `Add`
  String get add {
    return Intl.message(
      'Add',
      name: 'add',
      desc: '',
      args: [],
    );
  }

  /// `Logged in`
  String get login_res {
    return Intl.message(
      'Logged in',
      name: 'login_res',
      desc: '',
      args: [],
    );
  }

  /// `Error logging in`
  String get login_res_fail {
    return Intl.message(
      'Error logging in',
      name: 'login_res_fail',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get logout {
    return Intl.message(
      'Logout',
      name: 'logout',
      desc: '',
      args: [],
    );
  }

  /// `Username`
  String get username {
    return Intl.message(
      'Username',
      name: 'username',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message(
      'Password',
      name: 'password',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get login {
    return Intl.message(
      'Login',
      name: 'login',
      desc: '',
      args: [],
    );
  }

  /// `Highlight Exams`
  String get highlightExams {
    return Intl.message(
      'Highlight Exams',
      name: 'highlightExams',
      desc: '',
      args: [],
    );
  }

  /// `If exams take place, they will be displayed in the corresponding hours`
  String get highlightExamsDesc {
    return Intl.message(
      'If exams take place, they will be displayed in the corresponding hours',
      name: 'highlightExamsDesc',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `View Notes`
  String get viewNotes {
    return Intl.message(
      'View Notes',
      name: 'viewNotes',
      desc: '',
      args: [],
    );
  }

  /// `Notes under the subjects can be entered for substitution hours (or rarely also for exams).`
  String get viewNotesDesc {
    return Intl.message(
      'Notes under the subjects can be entered for substitution hours (or rarely also for exams).',
      name: 'viewNotesDesc',
      desc: '',
      args: [],
    );
  }

  /// `Connection not possible `
  String get networkError {
    return Intl.message(
      'Connection not possible ',
      name: 'networkError',
      desc: '',
      args: [],
    );
  }

  /// `Unable to connect to server`
  String get networkErrorDescription {
    return Intl.message(
      'Unable to connect to server',
      name: 'networkErrorDescription',
      desc: '',
      args: [],
    );
  }

  /// `Event`
  String get event {
    return Intl.message(
      'Event',
      name: 'event',
      desc: '',
      args: [],
    );
  }

  /// `Show Empty rooms`
  String get viewRooms {
    return Intl.message(
      'Show Empty rooms',
      name: 'viewRooms',
      desc: '',
      args: [],
    );
  }

  /// `Shows Free rooms in the lunch break\nNote:Rooms of next and previous hour will be prefered`
  String get viewRoomsDesc {
    return Intl.message(
      'Shows Free rooms in the lunch break\nNote:Rooms of next and previous hour will be prefered',
      name: 'viewRoomsDesc',
      desc: '',
      args: [],
    );
  }

  /// `Group`
  String get group {
    return Intl.message(
      'Group',
      name: 'group',
      desc: '',
      args: [],
    );
  }

  /// `Grade`
  String get clasz {
    return Intl.message(
      'Grade',
      name: 'clasz',
      desc: '',
      args: [],
    );
  }

  /// `Grade Settings`
  String get groupInputs {
    return Intl.message(
      'Grade Settings',
      name: 'groupInputs',
      desc: '',
      args: [],
    );
  }

  /// `Free Rooms preferences`
  String get wantedRooms {
    return Intl.message(
      'Free Rooms preferences',
      name: 'wantedRooms',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'de'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
