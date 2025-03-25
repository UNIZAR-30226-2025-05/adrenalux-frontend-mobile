class Logro {
  final int id;
  final String photo = 'https://t3.ftcdn.net/jpg/00/64/67/80/360_F_64678017_zUpiZFjj04cnLri7oADnyMH0XBYyQghG.jpg';
  final String description;
  final String rewardType;
  final int rewardAmount;
  final int logroType;
  final int requirement;
  bool achieved;
  DateTime? createdAt;

  Logro({
    required this.id,
    required this.description,
    required this.rewardType,
    required this.rewardAmount,
    required this.logroType,
    required this.requirement,
    this.achieved = false,
    this.createdAt
  });

  void unlock() {
    if (!achieved) {
      achieved = true;
      createdAt = DateTime.now();
    }
  }

  factory Logro.fromJson(Map<String, dynamic> json) {
    return Logro(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      description: json['description'] as String? ?? '',
      rewardType: json['reward_type'] ?? '',
      rewardAmount: json['reward_amount'] as int? ?? 0,
      logroType: int.tryParse(json['logro_type']?.toString() ?? '') ?? 0,
      requirement: json['requirement'] as int? ?? 0,
      achieved: json['achieved']?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }
}