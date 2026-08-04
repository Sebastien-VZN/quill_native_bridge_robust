import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:quill_native_bridge/quill_native_bridge.dart';
import 'package:quill_native_bridge_example/main.dart';

@GenerateMocks([QuillNativeBridge])
import 'example_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockQuillNativeBridge mockQuillNativeBridge;

  setUp(() {
    mockQuillNativeBridge = MockQuillNativeBridge();
    quillNativeBridge = mockQuillNativeBridge;
  });

  group('Is iOS Simulator', () {
    testWidgets(
      'pressing the button shows a SnackBar with correct text on iOS devices',
      (tester) async {
        await tester.pumpWidget(const MainApp());

        Future<void> runIsIOSSimulatorTest({
          required bool isIOSSimulator,
          required String expectedSnackbarMessage,
        }) async {
          when(
            mockQuillNativeBridge.isSupported(
              QuillNativeBridgeFeature.isIOSSimulator,
            ),
          ).thenAnswer((_) async => true);

          when(
            mockQuillNativeBridge.isIOSSimulator(),
          ).thenAnswer((_) async => isIOSSimulator);

          final isIOSButton = find.text('Is iOS Simulator');

          expect(isIOSButton, findsOneWidget);

          await tester.tap(isIOSButton);
          await tester.pump();

          expect(find.text(expectedSnackbarMessage), findsOneWidget);
        }

        await runIsIOSSimulatorTest(
          isIOSSimulator: true,
          expectedSnackbarMessage: "You're running the app on iOS simulator.",
        );
        await runIsIOSSimulatorTest(
          isIOSSimulator: false,
          expectedSnackbarMessage:
              "You're running the app on a real iOS device.",
        );
      },
    );

    testWidgets(
      'pressing the button shows unsupported message on non-iOS devices',
      (tester) async {
        await tester.pumpWidget(const MainApp());

        when(
          mockQuillNativeBridge.isSupported(
            QuillNativeBridgeFeature.isIOSSimulator,
          ),
        ).thenAnswer((_) async => false);

        final isIOSButton = find.text('Is iOS Simulator');

        expect(isIOSButton, findsOneWidget);

        await tester.tap(isIOSButton);
        await tester.pump();

        expect(
          find.text(
            'Available only on iOS to determine if the device is a simulator.',
          ),
          findsOneWidget,
        );
      },
    );
  });

  group('Get HTML from Clipboard', () {
    testWidgets('shows HTML content from clipboard', (tester) async {
      await tester.pumpWidget(const MainApp());

      when(
        mockQuillNativeBridge.isSupported(
          QuillNativeBridgeFeature.getClipboardHtml,
        ),
      ).thenAnswer((_) async => true);
      when(
        mockQuillNativeBridge.getClipboardHtml(),
      ).thenAnswer((_) async => '<b>Hello</b>');

      await tester.tap(find.text('Get HTML from Clipboard'));
      await tester.pump();

      expect(find.textContaining('<b>Hello</b>'), findsOneWidget);
    });

    testWidgets('shows unavailable message when clipboard has no HTML', (
      tester,
    ) async {
      await tester.pumpWidget(const MainApp());

      when(
        mockQuillNativeBridge.isSupported(
          QuillNativeBridgeFeature.getClipboardHtml,
        ),
      ).thenAnswer((_) async => true);
      when(
        mockQuillNativeBridge.getClipboardHtml(),
      ).thenAnswer((_) async => null);

      await tester.tap(find.text('Get HTML from Clipboard'));
      await tester.pump();

      expect(
        find.text('The HTML is not available on the clipboard.'),
        findsOneWidget,
      );
    });
  });

  group('Copy HTML to Clipboard', () {
    testWidgets('copies HTML and shows confirmation', (tester) async {
      await tester.pumpWidget(const MainApp());

      when(
        mockQuillNativeBridge.isSupported(
          QuillNativeBridgeFeature.copyHtmlToClipboard,
        ),
      ).thenAnswer((_) async => true);
      when(
        mockQuillNativeBridge.copyHtmlToClipboard(any),
      ).thenAnswer((_) async => {});

      await tester.tap(find.text('Copy HTML to Clipboard'));
      await tester.pump();

      expect(
        find.textContaining('HTML copied to the clipboard'),
        findsOneWidget,
      );
    });
  });

  group('Get Text from Clipboard', () {
    testWidgets('shows text content from clipboard', (tester) async {
      await tester.pumpWidget(const MainApp());

      when(
        mockQuillNativeBridge.isSupported(
          QuillNativeBridgeFeature.getClipboardText,
        ),
      ).thenAnswer((_) async => true);
      when(
        mockQuillNativeBridge.getClipboardText(),
      ).thenAnswer((_) async => 'Hello World');

      await tester.tap(find.text('Get Text from Clipboard'));
      await tester.pump();

      expect(find.textContaining('Hello World'), findsOneWidget);
    });

    testWidgets('shows unavailable message when clipboard has no text', (
      tester,
    ) async {
      await tester.pumpWidget(const MainApp());

      when(
        mockQuillNativeBridge.isSupported(
          QuillNativeBridgeFeature.getClipboardText,
        ),
      ).thenAnswer((_) async => true);
      when(
        mockQuillNativeBridge.getClipboardText(),
      ).thenAnswer((_) async => null);

      await tester.tap(find.text('Get Text from Clipboard'));
      await tester.pump();

      expect(
        find.text('The text is not available on the clipboard.'),
        findsOneWidget,
      );
    });
  });

  group('Copy Text to Clipboard', () {
    testWidgets('copies text and shows confirmation', (tester) async {
      await tester.pumpWidget(const MainApp());

      when(
        mockQuillNativeBridge.isSupported(
          QuillNativeBridgeFeature.copyTextToClipboard,
        ),
      ).thenAnswer((_) async => true);
      when(
        mockQuillNativeBridge.copyTextToClipboard(any),
      ).thenAnswer((_) async => {});

      await tester.tap(find.text('Copy Text to Clipboard'));
      await tester.pump();

      expect(
        find.textContaining('Text copied to the clipboard'),
        findsOneWidget,
      );
    });
  });

  group('Get Markdown from Clipboard', () {
    testWidgets('shows Markdown content from clipboard', (tester) async {
      await tester.pumpWidget(const MainApp());

      when(
        mockQuillNativeBridge.isSupported(
          QuillNativeBridgeFeature.getClipboardMarkdown,
        ),
      ).thenAnswer((_) async => true);
      when(
        mockQuillNativeBridge.getClipboardMarkdown(),
      ).thenAnswer((_) async => '# Hello\n\n**bold**');

      await tester.tap(find.text('Get Markdown from Clipboard'));
      await tester.pump();

      expect(find.textContaining('# Hello'), findsOneWidget);
    });

    testWidgets('shows unavailable message when clipboard has no Markdown', (
      tester,
    ) async {
      await tester.pumpWidget(const MainApp());

      when(
        mockQuillNativeBridge.isSupported(
          QuillNativeBridgeFeature.getClipboardMarkdown,
        ),
      ).thenAnswer((_) async => true);
      when(
        mockQuillNativeBridge.getClipboardMarkdown(),
      ).thenAnswer((_) async => null);

      await tester.tap(find.text('Get Markdown from Clipboard'));
      await tester.pump();

      expect(
        find.text('The Markdown is not available on the clipboard.'),
        findsOneWidget,
      );
    });

    testWidgets('shows unsupported message on unsupported platforms', (
      tester,
    ) async {
      await tester.pumpWidget(const MainApp());

      when(
        mockQuillNativeBridge.isSupported(
          QuillNativeBridgeFeature.getClipboardMarkdown,
        ),
      ).thenAnswer((_) async => false);

      await tester.tap(find.text('Get Markdown from Clipboard'));
      await tester.pump();

      expect(find.textContaining('not supported on'), findsOneWidget);
    });
  });

  group('Copy Markdown to Clipboard', () {
    testWidgets('copies Markdown and shows confirmation', (tester) async {
      await tester.pumpWidget(const MainApp());

      when(
        mockQuillNativeBridge.isSupported(
          QuillNativeBridgeFeature.copyMarkdownToClipboard,
        ),
      ).thenAnswer((_) async => true);
      when(
        mockQuillNativeBridge.copyMarkdownToClipboard(any),
      ).thenAnswer((_) async => {});

      await tester.tap(find.text('Copy Markdown to Clipboard'));
      await tester.pump();

      expect(
        find.textContaining('Markdown copied to the clipboard'),
        findsOneWidget,
      );
    });

    testWidgets('shows unsupported message on unsupported platforms', (
      tester,
    ) async {
      await tester.pumpWidget(const MainApp());

      when(
        mockQuillNativeBridge.isSupported(
          QuillNativeBridgeFeature.copyMarkdownToClipboard,
        ),
      ).thenAnswer((_) async => false);

      await tester.tap(find.text('Copy Markdown to Clipboard'));
      await tester.pump();

      expect(find.textContaining('not supported on'), findsOneWidget);
    });
  });
}
