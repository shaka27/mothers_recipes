import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mothers_recipes/utils/colors.dart';
import 'package:mothers_recipes/views/app_HomeScreen.dart';
import 'package:mothers_recipes/views/favourite_screen.dart';
import 'package:mothers_recipes/views/upload_recipe_screen.dart';

class Appmain extends StatefulWidget {
  const Appmain({super.key});

  @override
  State<Appmain> createState() => _AppmainState();
}

class _AppmainState extends State<Appmain> {
  int selectedIndex = 0;
  late final List<Widget> page;
  @override
  void initState() {
    page = [
      const MyAppHomescreen(),
      const FavouriteScreen(),
      const UploadRecipeScreen(),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconSize: 28,
        currentIndex: selectedIndex,
        selectedItemColor: kprimaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,

        selectedLabelStyle: TextStyle(
          color: kprimaryColor,
          fontWeight: FontWeight.w600,
        ),

        unselectedLabelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),

        onTap: (value) {
          setState(() {
            selectedIndex = value;
          });
        },

        items: [
          BottomNavigationBarItem(
            icon: Icon(selectedIndex == 0 ? Iconsax.home5 : Iconsax.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(selectedIndex == 1 ? Iconsax.heart5 : Iconsax.heart),
            label: "Favourite ",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              selectedIndex == 2 ? Iconsax.add_circle5 : Iconsax.add_circle,
            ),
            label: "Upload",
          ),
        ],
      ),
      body: page[selectedIndex],
    );
  }

  navBarPage(iconName) {
    return Center(child: Icon(iconName, size: 100, color: kprimaryColor));
  }
}
