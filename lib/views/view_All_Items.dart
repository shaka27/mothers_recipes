import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mothers_recipes/utils/colors.dart';
import 'package:mothers_recipes/widgets/food_items_display.dart';
import 'package:mothers_recipes/widgets/iconButton.dart';
import 'package:iconsax/iconsax.dart';

class ViewAllItems extends StatefulWidget {
  const ViewAllItems({super.key});

  @override
  State<ViewAllItems> createState() => _ViewAllItemsState();
}

class _ViewAllItemsState extends State<ViewAllItems> {
  final CollectionReference completeApp = FirebaseFirestore.instance.collection("recipes");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kbackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          const SizedBox(width: 15),
          MyIconButton(
            icon: Icons.arrow_back,
            pressed: () {
              Navigator.pop(context);
            },
          ),
          const Spacer(),
          const Text(
            "Quick & Easy",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          MyIconButton(
            icon: Iconsax.notification,
            pressed: () {
              // Notification logic here
            },
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 15, right: 5),
        child: Column(
          children: [
            SizedBox(height: 15,),
            StreamBuilder<QuerySnapshot>(
              stream: completeApp.snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                if (streamSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (streamSnapshot.hasError) {
                  return Text("Error: ${streamSnapshot.error}");
                }

                final data = streamSnapshot.data;
                if (data == null || data.docs.isEmpty) {
                  return const Text("No items found.");
                }

                if (streamSnapshot.hasData) {
                  return GridView.builder(
                    itemCount: streamSnapshot.data!.docs.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.78,
                    ),
                    itemBuilder: (context, index) {
                      final DocumentSnapshot documentSnapshot = streamSnapshot.data!.docs[index];
                      return FoodItemsDisplay(documentSnapshot: documentSnapshot);
                    },
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ],
        ),
      ),
    );
  }
}
