import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:quill_native_bridge/quill_native_bridge.dart';
import 'package:quill_native_bridge_platform_interface/quill_native_bridge_platform_interface.dart';

@GenerateMocks([], customMocks: [MockSpec<QuillNativeBridgePlatform>()])
import 'quill_native_bridge_test.mocks.dart' as base_mock;

// Add the mixin to make the platform interface accept the mock.
// For more details, refer to https://pub.dev/packages/plugin_platform_interface#mocking-or-faking-platform-interfaces
class _MockQuillNativeBridgePlatform
    extends base_mock.MockQuillNativeBridgePlatform
    with MockPlatformInterfaceMixin {}

void main() {
  final plugin = QuillNativeBridge();
  late _MockQuillNativeBridgePlatform mockQuillNativeBridgePlatform;

  setUp(() {
    mockQuillNativeBridgePlatform = _MockQuillNativeBridgePlatform();

    QuillNativeBridgePlatform.instance = mockQuillNativeBridgePlatform;
  });

  group('isSupported', () {
    test('returns correct value based on platform implementation', () async {
      for (final isSupported in {true, false}) {
        const exampleFeature = QuillNativeBridgeFeature.isIOSSimulator;
        when(
          mockQuillNativeBridgePlatform.isSupported(exampleFeature),
        ).thenAnswer((_) async => isSupported);

        final result = await plugin.isSupported(exampleFeature);
        verify(
          mockQuillNativeBridgePlatform.isSupported(exampleFeature),
        ).called(1);
        expect(result, isSupported);
      }
    });

    test(
      'passes the $QuillNativeBridgeFeature correctly to the platform implementation',
      () async {
        for (final feature in QuillNativeBridgeFeature.values) {
          when(
            mockQuillNativeBridgePlatform.isSupported(any),
          ).thenAnswer((_) async => false);

          await plugin.isSupported(feature);
          verify(mockQuillNativeBridgePlatform.isSupported(feature)).called(1);
        }
      },
    );
  });

  test(
    'isIOSSimulator returns correct value based on platform implementation',
    () async {
      for (final isSimulator in {true, false}) {
        when(
          mockQuillNativeBridgePlatform.isIOSSimulator(),
        ).thenAnswer((_) async => isSimulator);
        final result = await plugin.isIOSSimulator();
        verify(mockQuillNativeBridgePlatform.isIOSSimulator()).called(1);
        expect(result, isSimulator);
      }
    },
  );

  test(
    'getClipboardHtml returns correct value based on platform implementation',
    () async {
      for (final html in {'<center></center>', '<html></html>'}) {
        when(
          mockQuillNativeBridgePlatform.getClipboardHtml(),
        ).thenAnswer((_) async => html);
        final result = await plugin.getClipboardHtml();
        verify(mockQuillNativeBridgePlatform.getClipboardHtml()).called(1);
        expect(result, html);
      }
    },
  );

  test(
    'copyHtmlToClipboard passes the HTML correctly to the platform implementation',
    () async {
      const exampleHtml = '<body></body>';
      when(
        mockQuillNativeBridgePlatform.copyHtmlToClipboard(any),
      ).thenAnswer((_) async {});

      await plugin.copyHtmlToClipboard(exampleHtml);
      verify(
        mockQuillNativeBridgePlatform.copyHtmlToClipboard(exampleHtml),
      ).called(1);
    },
  );

  group('isAppleSafari', () {
    test('calls isAppleSafari from the platform API', () {
      when(mockQuillNativeBridgePlatform.isAppleSafari()).thenReturn(false);
      plugin.isAppleSafari();
      verify(mockQuillNativeBridgePlatform.isAppleSafari()).called(1);
      verifyNoMoreInteractions(mockQuillNativeBridgePlatform);
    });

    test('delegates to isAppleSafari from the platform API', () {
      for (final isAppleSafariValue in {true, false}) {
        when(
          mockQuillNativeBridgePlatform.isAppleSafari(),
        ).thenReturn(isAppleSafariValue);
        expect(plugin.isAppleSafari(), isAppleSafariValue);
      }
    });
  });
}
