import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart' show Iconsax;
import 'package:mothers_recipes/provider/favourite_Provider.dart';
import 'package:mothers_recipes/views/detail_screen.dart';

class FoodItemsDisplay extends StatelessWidget {
  final DocumentSnapshot<Object?> documentSnapshot;
  const FoodItemsDisplay({super.key, required this.documentSnapshot});

  @override
  Widget build(BuildContext context) {
    final provider = FavouriteProvider.of(context);
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context)=>DetailScreen(documentSnapshot: documentSnapshot)));
      },
      child: SizedBox(
        width: 230,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: documentSnapshot['images'],
                  child: Container(
                    width: double.infinity,
                    height: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      image: DecorationImage(
                        image: NetworkImage(documentSnapshot['images']),
                        fit: BoxFit.cover, // Add this for better image display
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  documentSnapshot['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  maxLines: 1, // Limit to 1 line
                  overflow: TextOverflow.ellipsis, // Add "..." if too long
                ),

                SizedBox(height: 5),
                Row(
                  children: [
                    Icon(Iconsax.flash_1, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      "${documentSnapshot['cal']} Cal",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      "  •  ",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(Iconsax.clock, size: 15, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      "${documentSnapshot['time']} Min",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              top: 5,
              right: 5,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: InkWell(
                  onTap: () {
                    provider.toggleFavourite(documentSnapshot);
                  },
                  child: Icon(
                    provider.doesExist(documentSnapshot)
                        ? Iconsax.heart5
                        : Iconsax.heart,
                    color: provider.doesExist(documentSnapshot)
                        ? Colors.red
                        : Colors.black,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
