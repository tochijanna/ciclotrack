import 'package:flutter_test/flutter_test.dart';
import 'package:ciclotrack/features/profiles/domain/woman_draft.dart';
import 'package:ciclotrack/features/profiles/domain/woman_validator.dart';

void main() {
  group('initialsFrom', () {
    test('returns empty for empty name', () {
      expect(initialsFrom(''), '');
    });

    test('returns single initial for one word', () {
      expect(initialsFrom('María'), 'M');
    });

    test('returns two initials for two words', () {
      expect(initialsFrom('María López'), 'ML');
    });

    test('takes only first two words', () {
      expect(initialsFrom('Ana María López'), 'AM');
    });

    test('uppercases initials', () {
      expect(initialsFrom('ana'), 'A');
    });

    test('handles extra whitespace', () {
      expect(initialsFrom('  María   López  '), 'ML');
    });
  });

  group('normalizeTags', () {
    test('removes empty and trims', () {
      expect(normalizeTags(['  Relacionada ', '', '  ', 'Amiga']), [
        'Relacionada',
        'Amiga',
      ]);
    });

    test('deduplicates exact matches', () {
      expect(normalizeTags(['Amiga', 'Amiga', 'Ex']), ['Amiga', 'Ex']);
    });

    test('returns empty for all empty', () {
      expect(normalizeTags(['', '  ']), isEmpty);
    });
  });

  group('validateWomanDraft', () {
    test('rejects empty name', () {
      const draft = WomanDraft(name: '', initials: 'AB');
      final errors = validateWomanDraft(draft);
      expect(errors.name, isNotNull);
      expect(errors.initials, isNull);
      expect(errors.isValid, isFalse);
    });

    test('rejects name shorter than 2 chars', () {
      const draft = WomanDraft(name: 'A', initials: 'AB');
      final errors = validateWomanDraft(draft);
      expect(errors.name, isNotNull);
    });

    test('rejects empty initials', () {
      const draft = WomanDraft(name: 'María', initials: '');
      final errors = validateWomanDraft(draft);
      expect(errors.initials, isNotNull);
      expect(errors.name, isNull);
    });

    test('rejects initials longer than 4 chars', () {
      const draft = WomanDraft(name: 'María', initials: 'ABCDE');
      final errors = validateWomanDraft(draft);
      expect(errors.initials, isNotNull);
    });

    test('accepts valid draft', () {
      const draft = WomanDraft(name: 'María', initials: 'ML');
      final errors = validateWomanDraft(draft);
      expect(errors.isValid, isTrue);
    });
  });

  group('applyDefaults', () {
    test('generates initials when empty', () {
      const draft = WomanDraft(name: 'María López', initials: '');
      final result = applyDefaults(draft);
      expect(result.initials, 'ML');
    });

    test('keeps provided initials', () {
      const draft = WomanDraft(name: 'María', initials: 'X');
      final result = applyDefaults(draft);
      expect(result.initials, 'X');
    });

    test('normalizes tags', () {
      const draft = WomanDraft(
        name: 'María',
        initials: 'M',
        tags: [' Amiga ', '', 'Amiga', 'Ex '],
      );
      final result = applyDefaults(draft);
      expect(result.tags, ['Amiga', 'Ex']);
    });

    test('trims name', () {
      const draft = WomanDraft(name: '  María  ', initials: 'M');
      final result = applyDefaults(draft);
      expect(result.name, 'María');
    });
  });
}
