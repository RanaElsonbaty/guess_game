import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:guess_game/core/theming/colors.dart';
import 'package:guess_game/core/theming/styles.dart';
import 'package:guess_game/core/widgets/file_shape_clipper.dart';

class FolderTeamImageCard extends StatelessWidget {
  final String teamTitle;
  final String imageUrl;
  final double width;
  final double height;
  final double imageBoxSize;

  const FolderTeamImageCard({
    super.key,
    required this.teamTitle,
    required this.imageUrl,
    this.width = 237,
    this.height = 240,
    this.imageBoxSize = 145,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: FileClipper(),
      child: Container(
        width: width.w,
        height: height.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0XFF8e8e8e),
              AppColors.black.withOpacity(.3),
              Colors.white.withOpacity(.5),
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: 10.w, right: 10.w, top: 35.h, bottom: 12.h),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
            child: Column(
              children: [
                Text(teamTitle, style: TextStyles.font14Secondary700Weight),
                SizedBox(height: 10.h),
                Expanded(
                  child: Center(
                    child: Container(
                      width: imageBoxSize.w,
                      height: imageBoxSize.w,
                      color: Colors.black.withOpacity(0.18),
                      padding: EdgeInsets.all(10.w),
                      child: _ImageVisual(url: imageUrl),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ImageVisual extends StatelessWidget {
  final String url;

  const _ImageVisual({required this.url});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return const Center(
        child: Icon(Icons.image, color: Colors.grey, size: 60),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(child: CircularProgressIndicator());
      },
      errorBuilder: (context, error, stackTrace) => const Center(
        child: Icon(Icons.error, color: Colors.red, size: 40),
      ),
    );
  }
}


