import 'package:adrenalux_frontend_mobile/utils/screen_size.dart';
import 'package:flutter/material.dart';

class ExperienceCircleAvatar extends StatelessWidget {
  final String imagePath;
  final double experience;
  final String size; 

  ExperienceCircleAvatar({
    required this.imagePath,
    required this.experience,
    this.size = 'sm', 
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = ScreenSize.of(context);

    double avatarSize;
    double borderWidth;
    double progressSize;

    switch (size) {
      case 'md':
        avatarSize = screenSize.width * 0.2;
        borderWidth = 6.0;
        progressSize = screenSize.width * 0.18;
        break;
      case 'lg':
        avatarSize = screenSize.width * 0.35;
        borderWidth = 8.0;
        progressSize = screenSize.width * 0.33;
        break;
      case 'sm':
      default:
        avatarSize = screenSize.width * 0.14;
        borderWidth = 4.0;
        progressSize = screenSize.width * 0.13;
        break;
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.grey.withOpacity(0.2),
              width: borderWidth,
            ),
          ),
          child: CircleAvatar(
            backgroundImage: AssetImage(imagePath),
            radius: avatarSize / 2,
          ),
        ),
        SizedBox(
          width: progressSize,
          height: progressSize,
          child: CircularProgressIndicator(
            value: experience,
            strokeWidth: borderWidth,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            backgroundColor: Colors.transparent,
          ),
        ),
      ],
    );
  }
}