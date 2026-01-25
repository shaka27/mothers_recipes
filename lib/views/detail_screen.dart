import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mothers_recipes/provider/favourite_Provider.dart';
import 'package:mothers_recipes/provider/quantity_provider.dart';
import 'package:mothers_recipes/utils/colors.dart';
import 'package:mothers_recipes/widgets/iconButton.dart';
import 'package:mothers_recipes/widgets/quantity_modifier.dart';
import 'package:provider/provider.dart';

class DetailScreen extends StatefulWidget {
  final DocumentSnapshot<Object?> documentSnapshot;
  const DetailScreen({super.key, required this.documentSnapshot});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  List<DocumentSnapshot> sections = [];
  bool hasSubsections = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkForSubsections();
  }

  Future<void> _checkForSubsections() async {
    try {
      // Check if this recipe has subsections
      final sectionsSnapshot = await widget.documentSnapshot.reference
          .collection('sections')
          .get();

      if (sectionsSnapshot.docs.isNotEmpty) {
        setState(() {
          sections = sectionsSnapshot.docs;
          hasSubsections = true;
          isLoading = false;
        });

        // Initialize base amounts for recipes with subsections (use first section)
        if (sections.isNotEmpty) {
          List<double> baseAmount = sections.first['ingredientAmount']
              .map<double>((amount) => double.parse(amount.toString()))
              .toList();
          Provider.of<QuantityProvider>(context, listen: false)
              .initializeBaseIngredientAmounts(baseAmount);
        }
      } else {
        // No subsections, use main document data
        setState(() {
          hasSubsections = false;
          isLoading = false;
        });

        // Initialize base amounts for recipes without subsections
        if (widget.documentSnapshot.data() != null &&
            (widget.documentSnapshot.data() as Map<String, dynamic>)
                .containsKey('ingredientAmount')) {
          List<double> baseAmount = widget.documentSnapshot['ingredientAmount']
              .map<double>((amount) => double.parse(amount.toString()))
              .toList();
          Provider.of<QuantityProvider>(context, listen: false)
              .initializeBaseIngredientAmounts(baseAmount);
        }
      }
    } catch (e) {
      print('Error checking subsections: $e');
      setState(() {
        hasSubsections = false;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = FavouriteProvider.of(context);
    final quantityProvider = Provider.of<QuantityProvider>(context);

    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
      floatingActionButton: startCooking(provider),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Hero(
                  tag: widget.documentSnapshot['images'],
                  child: Container(
                    height: MediaQuery.of(context).size.height / 2.1,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(widget.documentSnapshot['images']),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 10,
                  right: 10,
                  child: Row(
                    children: [
                      MyIconButton(
                        icon: Icons.arrow_back,
                        pressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      Spacer(),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: MediaQuery.of(context).size.height / 2.3,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [],
                    ),
                  ),
                ),
              ],
            ),
            Center(
              child: Container(
                width: 40,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.documentSnapshot['name'],
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Iconsax.flash_1, size: 20, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        "${widget.documentSnapshot['cal']} Cal",
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "•",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(Iconsax.clock, size: 20, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        "${widget.documentSnapshot['time']} Min",
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Display ingredients and instructions based on whether there are subsections
                  if (hasSubsections)
                    _buildSubsectionContent(quantityProvider)
                  else
                    _buildMainContent(quantityProvider),

                  SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(QuantityProvider quantityProvider) {
    // For recipes without subsections (like Crustless Bacon)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Ingredients",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "How many servings?",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
            Spacer(),
            QuantityModifier(
              currentNumber: quantityProvider.currentNumber,
              onAdd: () => quantityProvider.increaseQuantity(),
              onRemove: () => quantityProvider.decreaseQuantity(),
            ),
          ],
        ),
        SizedBox(height: 10),

        // Ingredients list
        if (widget.documentSnapshot.data() != null &&
            (widget.documentSnapshot.data() as Map<String, dynamic>)
                .containsKey('ingredientName'))
          Column(
            children: List.generate(
              widget.documentSnapshot['ingredientName'].length,
                  (index) {
                final imageUrl = widget.documentSnapshot['ingredientImage'][index];
                final name = widget.documentSnapshot['ingredientName'][index];
                final amount = quantityProvider.getScaledIngredientAmounts()[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(imageUrl),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                      Text(
                        "$amount",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

        SizedBox(height: 30),

        // Instructions
        Text(
          "Instructions",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 15),
        if (widget.documentSnapshot.data() != null &&
            (widget.documentSnapshot.data() as Map<String, dynamic>)
                .containsKey('recipe'))
          Column(
            children: List.generate(
              widget.documentSnapshot['recipe'].length,
                  (index) {
                final instruction = widget.documentSnapshot['recipe'][index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Text(
                            "${index + 1}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          instruction,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSubsectionContent(QuantityProvider quantityProvider) {
    // For recipes with subsections (like Carrot Cake)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Ingredients",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "How many servings?",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
            Spacer(),
            QuantityModifier(
              currentNumber: quantityProvider.currentNumber,
              onAdd: () => quantityProvider.increaseQuantity(),
              onRemove: () => quantityProvider.decreaseQuantity(),
            ),
          ],
        ),
        SizedBox(height: 20),

        // Display each section
        ...sections.map((section) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section header
              Text(
                section['sectionName'] ?? 'Section',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
              SizedBox(height: 10),

              // Section ingredients
              if (section.data() != null &&
                  (section.data() as Map<String, dynamic>)
                      .containsKey('ingredientName'))
                Column(
                  children: List.generate(
                    section['ingredientName'].length,
                        (index) {
                      final imageUrl = section['ingredientImage'][index];
                      final name = section['ingredientName'][index];
                      final baseAmount = double.parse(section['ingredientAmount'][index].toString());
                      final scaledAmount = baseAmount * quantityProvider.currentNumber;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(imageUrl),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Text(
                                name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ),
                            Text(
                              "$scaledAmount",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

              SizedBox(height: 20),

              // Section instructions
              Text(
                "${section['sectionName'] ?? 'Section'} Instructions",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              if (section.data() != null &&
                  (section.data() as Map<String, dynamic>)
                      .containsKey('recipe'))
                Column(
                  children: List.generate(
                    section['recipe'].length,
                        (index) {
                      final instruction = section['recipe'][index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.blue.shade800,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Center(
                                child: Text(
                                  "${index + 1}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Text(
                                instruction,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade700,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              SizedBox(height: 30),
            ],
          );
        }),
      ],
    );
  }

  FloatingActionButton startCooking(FavouriteProvider provider) {
    return FloatingActionButton.extended(
      backgroundColor: Colors.white54,
      elevation: 0.1,
      onPressed: () {},
      label: Row(
        children: [
          IconButton(
            style: IconButton.styleFrom(
              shape: CircleBorder(
                side: BorderSide(color: Colors.grey.shade300, width: 2),
              ),
            ),
            onPressed: () {
              provider.toggleFavourite(widget.documentSnapshot);
            },
            icon: Icon(
              provider.doesExist(widget.documentSnapshot)
                  ? Iconsax.heart5
                  : Iconsax.heart,
              color: provider.doesExist(widget.documentSnapshot)
                  ? Colors.red
                  : Colors.black,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}