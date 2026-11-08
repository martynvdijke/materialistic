import 'package:flutter_test/flutter_test.dart';
import 'package:materialistic/src/telemetry/telemetry.dart';

void main() {
  group('normalizeEndpoint', () {
    test('appends /v1/traces when missing', () {
      expect(
        Telemetry.normalizeEndpoint('https://otlp.example.com'),
        'https://otlp.example.com/v1/traces',
      );
    });

    test('preserves an existing /v1/traces suffix', () {
      expect(
        Telemetry.normalizeEndpoint('https://otlp.example.com/v1/traces'),
        'https://otlp.example.com/v1/traces',
      );
    });

    test('strips trailing slashes before appending', () {
      expect(
        Telemetry.normalizeEndpoint('https://otlp.example.com//'),
        'https://otlp.example.com/v1/traces',
      );
      expect(
        Telemetry.normalizeEndpoint('  https://otlp.example.com/  '),
        'https://otlp.example.com/v1/traces',
      );
    });

    test('keeps a port and base path', () {
      expect(
        Telemetry.normalizeEndpoint('http://localhost:4318/otel'),
        'http://localhost:4318/otel/v1/traces',
      );
    });
  });

  group('parseOtelHeaders', () {
    test('parses comma separated key=value pairs', () {
      expect(
        Telemetry.parseOtelHeaders('authorization=Bearer abc,x-tenant=acme'),
        {'authorization': 'Bearer abc', 'x-tenant': 'acme'},
      );
    });

    test('url-decodes values', () {
      expect(
        Telemetry.parseOtelHeaders('authorization=Bearer%20token'),
        {'authorization': 'Bearer token'},
      );
    });

    test('ignores malformed and empty entries', () {
      expect(
        Telemetry.parseOtelHeaders('novalue,=orphan, a= ,ok=yes,,'),
        {'ok': 'yes'},
      );
    });

    test('empty input yields no headers', () {
      expect(Telemetry.parseOtelHeaders(''), isEmpty);
    });
  });

  group('buildOtlpPayload', () {
    test('emits the expected OTLP/HTTP envelope', () {
      final span = TraceSpan(
        name: 'screen feed',
        attributes: const {'screen.name': 'feed'},
        traceId: 'a' * 32,
        spanId: 'b' * 16,
        startNanos: 1000,
      );

      final payload = buildOtlpPayload(
        serviceName: 'materialistic-android',
        serviceVersion: '1.2.3',
        span: span,
        attributes: const {'http.response.status_code': 200, 'ok': true},
        failed: false,
        endNanos: 2000,
      );

      final resourceSpans = payload['resourceSpans']! as List;
      expect(resourceSpans, hasLength(1));

      final resourceSpan = resourceSpans.first as Map;
      final resource = resourceSpan['resource']! as Map;
      final resourceAttrs = {
        for (final attr in resource['attributes']! as List)
          (attr as Map)['key']: (attr['value'] as Map).values.first,
      };
      expect(resourceAttrs, {
        'service.name': 'materialistic-android',
        'service.version': '1.2.3',
        'telemetry.sdk.name': 'materialistic-mobile',
        'telemetry.sdk.language': 'dart',
      });

      final scopeSpans = resourceSpan['scopeSpans']! as List;
      final scope = (scopeSpans.first as Map)['scope']! as Map;
      expect(scope['name'], 'materialistic.mobile');
      expect(scope['version'], '1.2.3');

      final spans = (scopeSpans.first as Map)['spans']! as List;
      expect(spans, hasLength(1));
      final emitted = spans.first as Map;
      expect(emitted['traceId'], 'a' * 32);
      expect(emitted['spanId'], 'b' * 16);
      expect(emitted['name'], 'screen feed');
      expect(emitted['kind'], 1);
      expect(emitted['startTimeUnixNano'], '1000');
      expect(emitted['endTimeUnixNano'], '2000');
      expect(emitted['status'], {'code': 1});

      final attrs = {
        for (final attr in emitted['attributes']! as List)
          (attr as Map)['key']: (attr['value'] as Map),
      };
      expect(attrs['http.response.status_code'], {'intValue': '200'});
      expect(attrs['ok'], {'boolValue': true});
    });

    test('marks failed spans with status code 2', () {
      final span = TraceSpan(
        name: 'op',
        attributes: const {},
        traceId: randomHex(16),
        spanId: randomHex(8),
        startNanos: 0,
      );
      final payload = buildOtlpPayload(
        serviceName: 's',
        serviceVersion: 'v',
        span: span,
        attributes: const {},
        failed: true,
        endNanos: 1,
      );
      final spanMap =
          ((((payload['resourceSpans']! as List).first as Map)['scopeSpans']!
                      as List)
                  .first as Map)['spans']! as List;
      expect((spanMap.first as Map)['status'], {'code': 2});
    });

    test('ids are lowercase hex of the expected length', () {
      expect(randomHex(16), matches(RegExp(r'^[0-9a-f]{32}$')));
      expect(randomHex(8), matches(RegExp(r'^[0-9a-f]{16}$')));
      expect(
        buildTraceparent('a' * 32, 'b' * 16),
        '00-${'a' * 32}-${'b' * 16}-01',
      );
    });
  });

  group('sanitizeUmamiEvent', () {
    test('drops events that are not allowlisted', () {
      expect(sanitizeUmamiEvent('story_title', {'title': 'secret'}), isNull);
    });

    test('keeps only allowlisted props', () {
      expect(
        sanitizeUmamiEvent('screen_view', {
          'screen': 'feed',
          'username': 'pg',
          'query': 'rust',
        }),
        {'screen': 'feed'},
      );
    });

    test('rejects unknown screens and keeps known ones', () {
      expect(sanitizeUmamiEvent('screen_view', {'screen': 'admin'}), isNull);
      for (final screen in [
        'feed',
        'item',
        'search',
        'favorites',
        'login',
        'submit',
        'settings',
      ]) {
        expect(sanitizeUmamiEvent('screen_view', {'screen': screen}), {
          'screen': screen,
        });
      }
    });

    test('rejects over-long strings', () {
      expect(
        sanitizeUmamiEvent('feed_refresh', {'feed': 'a' * 80}),
        isNull,
      );
    });

    test('accepts booleans and numbers', () {
      expect(sanitizeUmamiEvent('search_submitted', {'has_query': true}), {
        'has_query': true,
      });
      expect(sanitizeUmamiEvent('favorite_toggled', {'favorited': false}), {
        'favorited': false,
      });
    });

    test('an event missing all required props is dropped', () {
      // Every allowlisted event here requires at least one prop.
      expect(sanitizeUmamiEvent('theme_changed'), isNull);
    });
  });

  group('compile-time configuration', () {
    test('telemetry is disabled when no endpoint is compiled in', () {
      // Tests run without --dart-define, so no endpoint exists.
      expect(TelemetryConfig.otelEndpoint, isEmpty);
      expect(TelemetryConfig.otelEnabled, isFalse);
      expect(Telemetry.instance.otelEnabled, isFalse);
    });

    test('service identity defaults are stable', () {
      expect(TelemetryConfig.serviceName, 'materialistic-android');
      expect(TelemetryConfig.serviceVersion, '1.0.0');
    });
  });
}
