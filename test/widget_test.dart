import 'dart:typed_data';

import 'package:chat_app/core/theme/app_theme.dart';
import 'package:chat_app/core/theme/theme_mode_provider.dart';
import 'package:chat_app/data/models/models.dart';
import 'package:chat_app/data/repositories/auth_repository.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/shared/widgets/app_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const ProviderScope(child: ChatApp()));
  await tester.pumpAndSettle();
}

Future<void> _login(WidgetTester tester, String mobileNumber) async {
  await tester.enterText(find.byType(TextFormField).first, mobileNumber);
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();
}

Future<void> _selectCountry(
  WidgetTester tester,
  String currentFlag,
  String countryName,
) async {
  await tester.tap(find.text(currentFlag));
  await tester.pumpAndSettle();
  await tester.tap(find.text(countryName));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('mobile login validation and unknown number', (tester) async {
    await _pumpApp(tester);
    expect(find.text('Welcome back 👋'), findsOneWidget);
    expect(find.byType(AppLogo), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter your mobile number'), findsOneWidget);

    await _login(tester, '701234567');
    expect(
      find.text('No account found for this mobile number.'),
      findsOneWidget,
    );
    expect(find.text('Messages'), findsNothing);
  });

  testWidgets('signup requires mobile and has no email or password', (
    tester,
  ) async {
    await _pumpApp(tester);
    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();

    expect(find.text('Membership number'), findsOneWidget);
    expect(find.text('Mobile number'), findsNWidgets(2));
    expect(find.byType(AppLogo), findsNothing);
    expect(find.text('Remarks (optional)'), findsOneWidget);
    expect(find.text('Add profile photo'), findsOneWidget);
    expect(find.text('Email'), findsNothing);
    expect(find.text('Password'), findsNothing);

    await tester.ensureVisible(find.text('Create account'));
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter your name'), findsOneWidget);
    expect(find.text('Please enter your membership number'), findsOneWidget);
    expect(find.text('Please enter your mobile number'), findsOneWidget);

    final nameField = find.byType(TextFormField).at(0);
    await tester.ensureVisible(nameField);
    await tester.enterText(nameField, 'Member Test');
    final membershipField = find.byType(TextFormField).at(1);
    await tester.ensureVisible(membershipField);
    await tester.enterText(membershipField, 'MEM-1234');
    await _selectCountry(tester, '🇱🇰', 'United States');
    final mobileField = find.byType(TextFormField).at(2);
    await tester.ensureVisible(mobileField);
    await tester.enterText(mobileField, '2025550134');
    await tester.ensureVisible(find.text('Create account'));
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    expect(find.text('Messages'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.more_vert_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Member Test'), findsOneWidget);
  });

  test('new accounts can sign in using only their mobile number', () async {
    final repository = DummyAuthRepository();
    await repository.signUp(
      const SignUpRequest(
        name: 'Member Test',
        membershipNumber: 'MEM-1234',
        mobileNumber: '+12025550134',
      ),
    );

    final user = await repository.signInWithMobile('+12025550134');

    expect(user.name, 'Member Test');
    expect(user.mobileNumber, '+12025550134');
  });

  testWidgets('login, chat, send, logout', (tester) async {
    await _pumpApp(tester);
    await _login(tester, '771234567');
    expect(find.text('Messages'), findsOneWidget);
    expect(find.text('5'), findsOneWidget); // Kasun's unread badge

    await tester.tap(find.text('Kasun Silva').last);
    await tester.pumpAndSettle();
    expect(find.byType(CustomPaint), findsWidgets);

    await tester.enterText(find.byType(TextField), 'Hello');
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pump();
    expect(find.byIcon(Icons.schedule_rounded), findsOneWidget); // sending
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.schedule_rounded), findsNothing); // sent

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Hello'), findsOneWidget);
    expect(find.text('5'), findsNothing); // marked as read

    await tester.tap(find.byIcon(Icons.more_vert_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Demo User'), findsOneWidget);
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back 👋'), findsOneWidget);
  });

  testWidgets('search empty state can clear the query', (tester) async {
    await _pumpApp(tester);
    await _login(tester, '771234567');

    final searchField = find.byType(TextField).first;
    await tester.enterText(searchField, 'no matching chat');
    await tester.pumpAndSettle();
    expect(find.text('No chats found'), findsOneWidget);

    await tester.tap(find.text('Clear search'));
    await tester.pumpAndSettle();
    expect(find.text('No chats found'), findsNothing);
    expect(find.text('Kasun Silva'), findsOneWidget);
    expect(tester.widget<TextField>(searchField).controller?.text, isEmpty);
  });

  testWidgets('settings can switch dark mode and follow device theme', (
    tester,
  ) async {
    await _pumpApp(tester);
    await _login(tester, '771234567');

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Theme'));
    await tester.pumpAndSettle();
    expect(find.text('Chat Theme'), findsOneWidget);
    expect(find.text('Dark mode'), findsOneWidget);
    expect(find.text('Use device theme'), findsOneWidget);
    await tester.ensureVisible(find.text('Chat wallpaper'));
    await tester.drag(find.byType(ListView).at(1), const Offset(-300, 0));
    await tester.pumpAndSettle();
    expect(find.text('Gallery'), findsOneWidget);
    expect(find.byIcon(Icons.add_photo_alternate_outlined), findsOneWidget);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );

    await tester.tap(find.text('Ocean Blue'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<MaterialApp>(find.byType(MaterialApp))
          .theme!
          .colorScheme
          .primary,
      AppThemePalette.ocean.primary,
    );

    await tester.tap(find.text('Ocean'));
    await tester.pumpAndSettle();
    expect(find.text('Ocean'), findsNWidgets(2));

    await tester.ensureVisible(find.text('Font size'));
    await tester.drag(find.byType(Slider), const Offset(120, 0));
    await tester.pumpAndSettle();
    final selectedFontSize = tester.widget<Slider>(find.byType(Slider)).value;
    expect(selectedFontSize, greaterThan(15));
    expect(find.text('${selectedFontSize.round()} px'), findsOneWidget);

    await tester.tap(find.text('Use device theme'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.system,
    );
  });

  test('custom wallpaper stores image data for chat backgrounds', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final bytes = Uint8List.fromList([1, 2, 3]);

    container
        .read(chatWallpaperProvider.notifier)
        .setWallpaper(ChatWallpaper.customImage(bytes));

    final wallpaper = container.read(chatWallpaperProvider);

    expect(wallpaper.id, 'custom');
    expect(wallpaper.imageBytes, same(bytes));
    expect(wallpaper.decoration.image, isNotNull);
    expect(wallpaper.decoration.gradient, isNull);
  });
}
