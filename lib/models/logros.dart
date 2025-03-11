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
      id: json['id'],
      description: json['description'],
      rewardType: json['reward_type'],
      rewardAmount: json['reward_amount'],
      logroType: json['logro_type'],
      requirement: json['requirement'],
      achieved: json['achieved']?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }
}