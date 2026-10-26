import 'package:chat_app/core/theme/app_theme.dart';
import 'package:chat_app/core/theme/theme_mode_provider.dart';
import 'package:chat_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:typed_data';

Future<void> _pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const ProviderScope(child: ChatApp()));
  await tester.pumpAndSettle();
}

Future<void> _login(WidgetTester tester, String email, String password) async {
  await tester.enterText(find.byType(TextFormField).at(0), email);
  await tester.enterText(find.byType(TextFormField).at(1), password);
  await tester.tap(find.text('Login'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('login validation and wrong credentials', (tester) async {
    await _pumpApp(tester);
    expect(find.text('Welcome back 👋'), findsOneWidget);

    await _login(tester, 'not-an-email', '12');
    expect(find.text('Please enter a valid email'), findsOneWidget);
    expect(find.text('Password must be at least 6 characters'), findsOneWidget);

    await _login(tester, 'someone@test.com', 'wrongpass');
    expect(find.text('Incorrect email or password.'), findsOneWidget);
    expect(find.text('Messages'), findsNothing);
  });

  testWidgets('login, chat, send, logout', (tester) async {
    await _pumpApp(tester);
    await _login(tester, 'demo@gmail.com', '123456');
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
    await _login(tester, 'demo@gmail.com', '123456');

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
    await _login(tester, 'demo@gmail.com', '123456');

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
