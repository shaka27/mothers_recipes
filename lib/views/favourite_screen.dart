import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mothers_recipes/provider/favourite_Provider.dart';
import 'package:mothers_recipes/utils/colors.dart';
import 'package:mothers_recipes/views/detail_screen.dart'; // Add this import

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = FavouriteProvider.of(context);
    final favouriteItems = provider.favourites;
    return Scaffold(
      backgroundColor: kbackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Your Favourites",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: favouriteItems.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No favourite recipes yet',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Add some recipes to your favourites!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: favouriteItems.length,
        itemBuilder: (context, index) {
          String favourite = favouriteItems[index];
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection("recipes")
                .doc(favourite)
                .get(),
            builder: (context, streamSnapshot) {
              if (streamSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(15),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (streamSnapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(15),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.red.shade50,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 24),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Error loading recipe',
                            style: TextStyle(color: Colors.red, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (!streamSnapshot.hasData || streamSnapshot.data == null) {
                return Padding(
                  padding: const EdgeInsets.all(15),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey.shade100,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.grey, size: 24),
                        const SizedBox(width: 10),
                        Text(
                          'Recipe not found',
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                );
              }

              var favouriteItem = streamSnapshot.data!;

              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: GestureDetector(
                      onTap: () {
                        // Navigate to detail screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailScreen(
                              documentSnapshot: favouriteItem,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Hero(
                              tag: "favourite_${favouriteItem.id}_${favouriteItem['images']}",
                              child: Container(
                                width: 100,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(20),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      favouriteItem['images'],
                                    ),
                                    fit: BoxFit.cover,
                                    onError: (exception, stackTrace) {
                                      // Handle image loading error
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    favouriteItem['name'] ?? 'Unknown Recipe',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Icon(
                                        Iconsax.flash_1,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "${favouriteItem['cal'] ?? 0} Cal",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const Text(
                                        "  •  ",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Icon(
                                        Iconsax.clock,
                                        size: 15,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "${favouriteItem['time'] ?? 0} Min",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "Tap to view recipe",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: kprimaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 25,
                    right: 25,
                    child: GestureDetector(
                      onTap: () {
                        // Show confirmation dialog before removing
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Remove from Favourites'),
                              content: Text(
                                'Remove "${favouriteItem['name']}" from your favourites?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    provider.toggleFavourite(favouriteItem);
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(
                                    'Remove',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}