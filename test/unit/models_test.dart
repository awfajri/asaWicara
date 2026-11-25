import 'package:flutter_test/flutter_test.dart';

import 'package:asa_wicara/features/auth/domain/models/caregiver_model.dart';
import 'package:asa_wicara/features/patient/domain/models/patient_model.dart';

void main() {
  group('CaregiverModel', () {
    test('fromJson membaca kolom snake_case dan default aman', () {
      final model = CaregiverModel.fromJson({
        'id': 'c1',
        'full_name': 'Siti',
        'email': 'siti@mail.com',
        'phone': null,
        'is_profile_completed': true,
        'created_at': '2026-11-25T08:00:00Z',
        'updated_at': '2026-11-25T09:00:00Z',
      });
      expect(model.id, 'c1');
      expect(model.fullName, 'Siti');
      expect(model.phone, isNull);
      expect(model.isProfileCompleted, isTrue);

      final minimal = CaregiverModel.fromJson({'id': 'c2'});
      expect(minimal.fullName, '');
      expect(minimal.isProfileCompleted, isFalse);
    });

    test('toJson memakai key snake_case', () {
      final json = CaregiverModel.fromJson({
        'id': 'c1',
        'full_name': 'Siti',
        'email': 'siti@mail.com',
      }).toJson();
      expect(json['full_name'], 'Siti');
      expect(json['is_profile_completed'], false);
    });
  });

  group('PatientModel', () {
    test('fromJson + toUpdateMap konsisten', () {
      final model = PatientModel.fromJson({
        'id': 'p1',
        'caregiver_id': 'c1',
        'full_name': 'Ncun Wati',
        'nickname': 'Bu Ncun',
        'birth_date': '1958-05-15',
        'gender': 'P',
        'relationship': 'Ibu',
      });
      expect(model.nickname, 'Bu Ncun');
      expect(model.birthDate, DateTime(1958, 5, 15));
      expect(model.toUpdateMap()['birth_date'], '1958-05-15');
      expect(model.ageYears, greaterThanOrEqualTo(68));
    });

    test('ageYears null jika tanggal lahir kosong', () {
      final model = PatientModel.fromJson({
        'id': 'p1',
        'caregiver_id': 'c1',
        'full_name': 'A',
        'nickname': 'A',
        'relationship': 'Ayah',
      });
      expect(model.ageYears, isNull);
    });
  });
}
