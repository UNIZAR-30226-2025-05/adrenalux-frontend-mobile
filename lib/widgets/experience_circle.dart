import 'package:flutter/material.dart';

class ExperienceCircleAvatar extends StatelessWidget {
  final String imagePath;
  final double experience; 

  ExperienceCircleAvatar({required this.imagePath, required this.experience});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 60,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.grey.withOpacity(0.2),
              width: 4.0,
            ),
          ),
          child: CircleAvatar(
            backgroundImage: AssetImage(imagePath),
            radius: 36,
          ),
        ),
        SizedBox(
          width: 50,
          height: 50,
          child: CircularProgressIndicator(
            value: experience,
            strokeWidth: 4.0,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            backgroundColor: Colors.transparent,
          ),
        ),
      ],
    );
  }
}