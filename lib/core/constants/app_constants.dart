import '../../features/exercise/domain/models/vowel_guide_model.dart';

class AppConstants {
  const AppConstants._();

  static const String appName = 'AsaWicara';
  static const String appTagline =
      'Pendamping Latihan Artikulasi Vokal AIUEO Pasca-Stroke';

  static const String audioBucketName = 'exercise-audio';
  static const int signedUrlExpiresInSeconds = 900;

  static const String nonDiagnosticDisclaimer =
      'AsaWicara adalah media pendamping latihan artikulasi mandiri di rumah, '
      'BUKAN alat diagnosis medis dan tidak menggantikan terapi wicara profesional.';

  static const List<VowelGuideModel> aiueoGuides = [
    VowelGuideModel(
      vowel: 'A',
      phoneticExample: '/a/ seperti kata "Apa"',
      mouthCueTitle: 'Buka Mulut Lebar',
      instructionText:
          'Buka mulut lebar secara perlahan, turunkan rahang bawah dengan rileks, lalu suarakan "Aaaa" selama 3–5 detik.',
      caregiverTip:
          'Duduk berhadapan dengan pasien dan berikan contoh bukaan mulut lebar secara santai.',
    ),
    VowelGuideModel(
      vowel: 'I',
      phoneticExample: '/i/ seperti kata "Ibu"',
      mouthCueTitle: 'Tarik Bibir Seperti Tersenyum',
      instructionText:
          'Tarik kedua sudut bibir ke samping seperti tersenyum lebar, lalu ucapkan "Iiii" dengan suara stabil.',
      caregiverTip:
          'Ajak pasien tersenyum terlebih dahulu sebelum mulai mengeluarkan suara.',
    ),
    VowelGuideModel(
      vowel: 'U',
      phoneticExample: '/u/ seperti kata "Ubi"',
      mouthCueTitle: 'Majukan Bibir Membulat Kecil',
      instructionText:
          'Majukan kedua bibir ke depan membentuk lingkaran kecil seperti meniup lilin, lalu suarakan "Uuuu".',
      caregiverTip:
          'Bantu pasien menarik napas tenang sebelum membulatkan bibir ke depan.',
    ),
    VowelGuideModel(
      vowel: 'E',
      phoneticExample: '/e/ seperti kata "Enak"',
      mouthCueTitle: 'Mulut Setengah Terbuka Rileks',
      instructionText:
          'Buka mulut setengah lebar dengan bibir sedikit melebar santai, lalu suarakan "Eeee" dengan jelas.',
      caregiverTip:
          'Pastikan rahang pasien tidak tegang saat mengucapkan vokal E.',
    ),
    VowelGuideModel(
      vowel: 'O',
      phoneticExample: '/o/ seperti kata "Obat"',
      mouthCueTitle: 'Bentuk Bibir Bulat Penuh',
      instructionText:
          'Bentuk bibir membulat penuh lebih besar dari huruf U, lalu keluarkan suara "Oooo" dengan mantap.',
      caregiverTip:
          'Berikan isyarat lingkaran dengan jari untuk membantu visualisasi bentuk bibir.',
    ),
  ];
}
