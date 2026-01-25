import 'package:flutter/material.dart';
import 'package:mothers_recipes/utils/colors.dart';

class MyBanner extends StatelessWidget {
  const MyBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 170,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15),
      color: kBannerColor),
      child: Stack(
        children: [
          Positioned(
              top: 20,
              left: 15,
              child:

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Cook the best\nrecipes at home",
                style: TextStyle(
                  height: 1.1,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,

                ),
              ),

            ],
          ),
          ),
          Positioned(
            top: 0,
            left: 150,
            right: -20,
            child: Image.network("https://pngimg.com/d/chef_PNG102.png",
              height: 200,
              width: 200,
            ),
            ),
        ],
      ),
    );
  }
}
