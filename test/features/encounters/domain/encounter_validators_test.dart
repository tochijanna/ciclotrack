import 'package:flutter_test/flutter_test.dart';
import 'package:ciclotrack/features/encounters/domain/encounter_draft.dart';
import 'package:ciclotrack/features/encounters/domain/encounter_validators.dart';

void main() {
  group('validateEncounterDraft', () {
    test('rejects future date', () {
      final draft = EncounterDraft(
        encounterTime: DateTime(2099, 1, 1),
        protection: 'Condón',
        participants: [
          const EncounterParticipantDraft(
            womanId: 1,
            relationshipType: 'Vaginal',
          ),
        ],
      );
      final errors = validateEncounterDraft(draft);
      expect(errors.encounterTime, isNotNull);
      expect(errors.isValid, isFalse);
    });

    test('rejects empty participants', () {
      final draft = EncounterDraft(
        encounterTime: DateTime(2026, 9, 1),
        protection: 'Condón',
        participants: [],
      );
      final errors = validateEncounterDraft(draft);
      expect(errors.participants, isNotNull);
      expect(errors.isValid, isFalse);
    });

    test('rejects duplicate participants', () {
      final draft = EncounterDraft(
        encounterTime: DateTime(2026, 9, 1),
        protection: 'Condón',
        participants: [
          const EncounterParticipantDraft(
            womanId: 1,
            relationshipType: 'Vaginal',
          ),
          const EncounterParticipantDraft(womanId: 1, relationshipType: 'Oral'),
        ],
      );
      final errors = validateEncounterDraft(draft);
      expect(errors.participants, isNotNull);
      expect(errors.isValid, isFalse);
    });

    test('rejects invalid protection', () {
      final draft = EncounterDraft(
        encounterTime: DateTime(2026, 9, 1),
        protection: 'Inexistente',
        participants: [
          const EncounterParticipantDraft(
            womanId: 1,
            relationshipType: 'Vaginal',
          ),
        ],
      );
      final errors = validateEncounterDraft(draft);
      expect(errors.protection, isNotNull);
      expect(errors.isValid, isFalse);
    });

    test('rejects invalid relationship type', () {
      final draft = EncounterDraft(
        encounterTime: DateTime(2026, 9, 1),
        protection: 'Condón',
        participants: [
          const EncounterParticipantDraft(
            womanId: 1,
            relationshipType: 'Inexistente',
          ),
        ],
      );
      final errors = validateEncounterDraft(draft);
      expect(errors.relationshipType, isNotNull);
      expect(errors.isValid, isFalse);
    });

    test('rejects invalid outcome', () {
      final draft = EncounterDraft(
        encounterTime: DateTime(2026, 9, 1),
        protection: 'Condón',
        participants: [
          const EncounterParticipantDraft(
            womanId: 1,
            relationshipType: 'Vaginal',
          ),
        ],
        outcome: 'Inexistente',
      );
      final errors = validateEncounterDraft(draft);
      expect(errors.outcome, isNotNull);
      expect(errors.isValid, isFalse);
    });

    test('accepts valid draft with one participant', () {
      final draft = EncounterDraft(
        encounterTime: DateTime(2026, 9, 1),
        protection: 'Condón',
        participants: [
          const EncounterParticipantDraft(
            womanId: 1,
            relationshipType: 'Vaginal',
          ),
        ],
      );
      final errors = validateEncounterDraft(draft);
      expect(errors.isValid, isTrue);
    });

    test('accepts valid draft with multiple participants', () {
      final draft = EncounterDraft(
        encounterTime: DateTime(2026, 9, 1),
        protection: 'Natural',
        participants: [
          const EncounterParticipantDraft(
            womanId: 1,
            relationshipType: 'Vaginal',
          ),
          const EncounterParticipantDraft(womanId: 2, relationshipType: 'Oral'),
          const EncounterParticipantDraft(womanId: 3, relationshipType: 'Anal'),
        ],
        outcome: 'Nada',
        notes: 'Test',
      );
      final errors = validateEncounterDraft(draft);
      expect(errors.isValid, isTrue);
    });

    test('accepts null outcome', () {
      final draft = EncounterDraft(
        encounterTime: DateTime(2026, 9, 1),
        protection: 'Condón',
        participants: [
          const EncounterParticipantDraft(
            womanId: 1,
            relationshipType: 'Vaginal',
          ),
        ],
        outcome: null,
      );
      final errors = validateEncounterDraft(draft);
      expect(errors.isValid, isTrue);
    });
  });
}
