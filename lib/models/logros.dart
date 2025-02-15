class Logro {
  final int id;
  final String photo;
  final String description;
  final String rewardType;
  final int rewardAmount;
  final int requiredExperience;
  bool achieved;
  DateTime? createdAt;

  Logro({
    required this.id,
    required this.photo,
    required this.description,
    required this.rewardType,
    required this.rewardAmount,
    required this.requiredExperience,
    this.achieved = false,
    this.createdAt
  });

  void unlock() {
    if (!achieved) {
      achieved = true;
      createdAt = DateTime.now();
    }
  }
}