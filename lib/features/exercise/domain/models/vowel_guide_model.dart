class VowelGuideModel {
  final String vowel;
  final String phoneticExample;
  final String mouthCueTitle;
  final String instructionText;
  final String caregiverTip;
  final String? assetIllustrationPath;

  const VowelGuideModel({
    required this.vowel,
    required this.phoneticExample,
    required this.mouthCueTitle,
    required this.instructionText,
    required this.caregiverTip,
    this.assetIllustrationPath,
  });
}
