class Logro {
  final int id;
  final String name;
  final String photo;
  final String description;
  final String rewardType;
  final int rewardAmount;
  final int requiredExperience;
  bool achieved;
  DateTime? createdAt;

  Logro({
    required this.id,
    required this.name,
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

  factory Logro.fromJson(Map<String, dynamic> json) {
    return Logro(
      id: json['id'],
      name: json['name'],
      photo: json['photo'],
      description: json['description'],
      rewardType: json['rewardType'],
      rewardAmount: json['rewardAmount'],
      requiredExperience: json['requiredExperience'],
      achieved: json['achieved'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }
}