class Logro {
  final int id;
  final String name;
  final String photo;
  final String description;
  final String rewardType;
  final int rewardAmount;
  bool achieved;
  DateTime? createdAt;

  Logro({
    required this.id,
    required this.name,
    required this.photo,
    required this.description,
    required this.rewardType,
    required this.rewardAmount,
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
      achieved: json['achieved'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }
}