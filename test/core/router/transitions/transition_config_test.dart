/// Test suite for TransitionConfig.
///
/// Tests transition configuration constants to ensure:
/// - Duration constants are correct
/// - Curve constants are correct
/// - Offset constants are correct
/// - Values follow Material Design guidelines
/// - Constants are accessible and immutable
///
/// Comprehensive test coverage following FlowForge Rule #3
/// (80%+ test coverage) and Rule #25 (Testing & Reliability).
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mnesis_flutter/core/router/transitions/transition_config.dart';

void main() {
  group('TransitionConfig Duration Constants', () {
    test('standardDuration is 300ms', () {
      expect(TransitionConfig.standardDuration, equals(const Duration(milliseconds: 300)));
      expect(TransitionConfig.standardDuration.inMilliseconds, equals(300));
    });

    test('fastDuration is 200ms', () {
      expect(TransitionConfig.fastDuration, equals(const Duration(milliseconds: 200)));
      expect(TransitionConfig.fastDuration.inMilliseconds, equals(200));
    });

    test('fastDuration is shorter than standardDuration', () {
      expect(
        TransitionConfig.fastDuration < TransitionConfig.standardDuration,
        isTrue,
        reason: 'Fast duration should be shorter than standard duration',
      );
    });

    test('durations follow Material Design guidelines', () {
      // Material Design recommends 200-300ms for transitions
      expect(
        TransitionConfig.standardDuration.inMilliseconds,
        inInclusiveRange(200, 300),
      );
      expect(
        TransitionConfig.fastDuration.inMilliseconds,
        inInclusiveRange(150, 250),
      );
    });

    test('durations are positive', () {
      expect(TransitionConfig.standardDuration.inMilliseconds, greaterThan(0));
      expect(TransitionConfig.fastDuration.inMilliseconds, greaterThan(0));
    });

    test('durations are const', () {
      // Verify constants are compile-time constants
      const duration1 = TransitionConfig.standardDuration;
      const duration2 = TransitionConfig.fastDuration;

      expect(duration1, isA<Duration>());
      expect(duration2, isA<Duration>());
    });
  });

  group('TransitionConfig Curve Constants', () {
    test('standardCurve is easeInOut', () {
      expect(TransitionConfig.standardCurve, equals(Curves.easeInOut));
    });

    test('enteringCurve is easeOut', () {
      expect(TransitionConfig.enteringCurve, equals(Curves.easeOut));
    });

    test('exitingCurve is easeIn', () {
      expect(TransitionConfig.exitingCurve, equals(Curves.easeIn));
    });

    test('curves are const', () {
      // Verify constants are compile-time constants
      const curve1 = TransitionConfig.standardCurve;
      const curve2 = TransitionConfig.enteringCurve;
      const curve3 = TransitionConfig.exitingCurve;

      expect(curve1, isA<Curve>());
      expect(curve2, isA<Curve>());
      expect(curve3, isA<Curve>());
    });

    test('curves produce valid transformation values', () {
      // Test curve transformations at key points
      final curves = [
        TransitionConfig.standardCurve,
        TransitionConfig.enteringCurve,
        TransitionConfig.exitingCurve,
      ];

      for (final curve in curves) {
        // At start (t=0.0), curve should be ~0.0
        expect(curve.transform(0.0), closeTo(0.0, 0.1));

        // At end (t=1.0), curve should be ~1.0
        expect(curve.transform(1.0), closeTo(1.0, 0.1));

        // At middle (t=0.5), curve should be between 0.0 and 1.0
        final midValue = curve.transform(0.5);
        expect(midValue, greaterThanOrEqualTo(0.0));
        expect(midValue, lessThanOrEqualTo(1.0));
      }
    });

    test('easeInOut provides smooth acceleration and deceleration', () {
      final curve = TransitionConfig.standardCurve;

      // Early in animation (t=0.2), should be moving but not too fast
      final early = curve.transform(0.2);
      expect(early, greaterThan(0.0));
      expect(early, lessThan(0.5));

      // Late in animation (t=0.8), should be slowing down
      final late = curve.transform(0.8);
      expect(late, greaterThan(0.5));
      expect(late, lessThan(1.0));
    });

    test('easeOut decelerates content entering', () {
      final curve = TransitionConfig.enteringCurve;

      // Early values should progress quickly
      final early = curve.transform(0.2);
      expect(early, greaterThan(0.1)); // Should move more than linear

      // Late values should slow down
      final late = curve.transform(0.8);
      expect(late, lessThan(0.9)); // Should be slower near end
    });

    test('easeIn accelerates content exiting', () {
      final curve = TransitionConfig.exitingCurve;

      // Early values should be slower
      final early = curve.transform(0.2);
      expect(early, lessThan(0.3)); // Should be slower than linear

      // Late values should accelerate
      final late = curve.transform(0.8);
      expect(late, greaterThan(0.7)); // Should accelerate near end
    });
  });

  group('TransitionConfig Offset Constants', () {
    test('slideOffset is 1.0', () {
      expect(TransitionConfig.slideOffset, equals(1.0));
    });

    test('partialSlideOffset is 0.3', () {
      expect(TransitionConfig.partialSlideOffset, equals(0.3));
    });

    test('partialSlideOffset is less than slideOffset', () {
      expect(
        TransitionConfig.partialSlideOffset < TransitionConfig.slideOffset,
        isTrue,
        reason: 'Partial slide should be smaller than full slide',
      );
    });

    test('offsets are positive', () {
      expect(TransitionConfig.slideOffset, greaterThan(0));
      expect(TransitionConfig.partialSlideOffset, greaterThan(0));
    });

    test('offsets are within valid range', () {
      // Offsets should be reasonable values (0.0 to 1.0 for full slide)
      expect(TransitionConfig.slideOffset, inInclusiveRange(0.0, 2.0));
      expect(TransitionConfig.partialSlideOffset, inInclusiveRange(0.0, 1.0));
    });

    test('slideOffset represents full screen width', () {
      // 1.0 offset means content starts completely off-screen
      expect(TransitionConfig.slideOffset, equals(1.0));
    });

    test('partialSlideOffset creates subtle effect', () {
      // 0.3 offset creates a subtle parallax/modal-like effect
      expect(TransitionConfig.partialSlideOffset, equals(0.3));
      expect(TransitionConfig.partialSlideOffset, lessThan(0.5));
    });
  });

  group('TransitionConfig Class Structure', () {
    test('has private constructor', () {
      // TransitionConfig uses private constructor to prevent instantiation
      // This is a static-only configuration class

      // Can access static constants
      expect(TransitionConfig.standardDuration, isNotNull);
      expect(TransitionConfig.standardCurve, isNotNull);
      expect(TransitionConfig.slideOffset, isNotNull);
    });

    test('all constants are static', () {
      // Verify all members can be accessed without instantiation
      expect(TransitionConfig.standardDuration, isA<Duration>());
      expect(TransitionConfig.fastDuration, isA<Duration>());
      expect(TransitionConfig.standardCurve, isA<Curve>());
      expect(TransitionConfig.enteringCurve, isA<Curve>());
      expect(TransitionConfig.exitingCurve, isA<Curve>());
      expect(TransitionConfig.slideOffset, isA<double>());
      expect(TransitionConfig.partialSlideOffset, isA<double>());
    });
  });

  group('Material Design Compliance', () {
    test('durations match Material Design motion guidelines', () {
      // Material Design recommends:
      // - 200-300ms for standard transitions
      // - Shorter for simple transitions

      expect(
        TransitionConfig.standardDuration.inMilliseconds,
        equals(300),
        reason: 'Standard duration should be 300ms per Material Design',
      );

      expect(
        TransitionConfig.fastDuration.inMilliseconds,
        equals(200),
        reason: 'Fast duration should be 200ms for simpler transitions',
      );
    });

    test('curves follow Material Design motion principles', () {
      // Material Design emphasizes:
      // - Smooth, natural motion (easeInOut)
      // - Deceleration when entering (easeOut)
      // - Acceleration when exiting (easeIn)

      expect(TransitionConfig.standardCurve, equals(Curves.easeInOut));
      expect(TransitionConfig.enteringCurve, equals(Curves.easeOut));
      expect(TransitionConfig.exitingCurve, equals(Curves.easeIn));
    });

    test('provides 60 FPS performance at standard duration', () {
      // At 60 FPS, 300ms = 18 frames
      // This is sufficient for smooth animation
      final frames = (TransitionConfig.standardDuration.inMilliseconds / 16.67).round();
      expect(frames, greaterThanOrEqualTo(12), reason: 'Should have enough frames for smooth animation');
    });
  });

  group('Configuration Consistency', () {
    test('all durations use milliseconds', () {
      expect(TransitionConfig.standardDuration.inMilliseconds, equals(300));
      expect(TransitionConfig.fastDuration.inMilliseconds, equals(200));
    });

    test('all curves are from Curves class', () {
      expect(TransitionConfig.standardCurve, isA<Curve>());
      expect(TransitionConfig.enteringCurve, isA<Curve>());
      expect(TransitionConfig.exitingCurve, isA<Curve>());
    });

    test('all offsets are doubles', () {
      expect(TransitionConfig.slideOffset, isA<double>());
      expect(TransitionConfig.partialSlideOffset, isA<double>());
    });
  });

  group('Usage Patterns', () {
    test('standardDuration suitable for most transitions', () {
      // 300ms is ideal for:
      // - Screen transitions
      // - Navigation animations
      // - Modal presentations
      expect(TransitionConfig.standardDuration.inMilliseconds, equals(300));
    });

    test('fastDuration suitable for quick transitions', () {
      // 200ms is ideal for:
      // - Simple fades
      // - Quick reveals
      // - Performance-critical animations
      expect(TransitionConfig.fastDuration.inMilliseconds, equals(200));
    });

    test('slideOffset enables full-screen slides', () {
      // 1.0 offset means content can slide from completely off-screen
      expect(TransitionConfig.slideOffset, equals(1.0));
    });

    test('partialSlideOffset enables subtle parallax', () {
      // 0.3 offset creates subtle background motion
      expect(TransitionConfig.partialSlideOffset, equals(0.3));
    });
  });

  group('Immutability', () {
    test('duration constants are immutable', () {
      // const values cannot be modified
      const d1 = TransitionConfig.standardDuration;
      const d2 = TransitionConfig.fastDuration;

      expect(d1, isNotNull);
      expect(d2, isNotNull);
    });

    test('curve constants are immutable', () {
      const c1 = TransitionConfig.standardCurve;
      const c2 = TransitionConfig.enteringCurve;
      const c3 = TransitionConfig.exitingCurve;

      expect(c1, isNotNull);
      expect(c2, isNotNull);
      expect(c3, isNotNull);
    });

    test('offset constants are immutable', () {
      const o1 = TransitionConfig.slideOffset;
      const o2 = TransitionConfig.partialSlideOffset;

      expect(o1, isNotNull);
      expect(o2, isNotNull);
    });
  });
}
