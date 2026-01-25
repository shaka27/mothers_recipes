import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mothers_recipes/utils/colors.dart';
import 'package:mothers_recipes/views/view_All_Items.dart';
import 'package:mothers_recipes/widgets/banner.dart';
import 'package:mothers_recipes/widgets/food_items_display.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyAppHomescreen extends StatefulWidget {
  const MyAppHomescreen({super.key});

  @override
  State<MyAppHomescreen> createState() => _MyAppHomescreenState();
}

class _MyAppHomescreenState extends State<MyAppHomescreen> {
  String selectedCategory = "All";
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  final CollectionReference categoriesItems = FirebaseFirestore.instance
      .collection("categories");

  // Enhanced query logic with search functionality
  Query get filteredRecipes {
    Query query = FirebaseFirestore.instance.collection("recipes");

    // Apply category filter
    if (selectedCategory != "All") {
      query = query.where('category', isEqualTo: selectedCategory);
    }

    return query;
  }

  // Filter recipes by search query (done in memory after Firestore query)
  List<DocumentSnapshot> filterRecipesBySearch(List<DocumentSnapshot> recipes) {
    if (searchQuery.isEmpty) {
      return recipes;
    }

    return recipes.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final name = (data['name'] ?? '').toString().toLowerCase();
      final category = (data['category'] ?? '').toString().toLowerCase();
      final ingredients = (data['ingredientName'] as List<dynamic>?)
          ?.map((e) => e.toString().toLowerCase())
          .join(' ') ?? '';

      final query = searchQuery.toLowerCase();

      return name.contains(query) ||
          category.contains(query) ||
          ingredients.contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kbackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    headerPart(),
                    searchBar(),
                    if (searchQuery.isEmpty) ...[
                      const MyBanner(),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          "Categories",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      selectedCategoryWidget(),
                      const SizedBox(height: 10),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          searchQuery.isEmpty
                              ? "Quick and easy"
                              : "Search Results",
                          style: const TextStyle(
                            fontSize: 20,
                            letterSpacing: 0.1,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (searchQuery.isEmpty)
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const ViewAllItems())
                              );
                            },
                            child: Text(
                              "View all",
                              style: TextStyle(
                                color: kBannerColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // FOOD ITEMS LIST
              StreamBuilder<QuerySnapshot>(
                stream: filteredRecipes.snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 50),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(
                              'Error loading recipes: ${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 50),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  // Apply search filter
                  List<DocumentSnapshot> recipes = filterRecipesBySearch(snapshot.data!.docs);

                  if (recipes.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 50),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                                searchQuery.isEmpty ? Icons.restaurant_menu : Icons.search_off,
                                size: 48,
                                color: Colors.grey[400]
                            ),
                            const SizedBox(height: 16),
                            Text(
                              searchQuery.isEmpty
                                  ? (selectedCategory == "All"
                                  ? 'No recipes found'
                                  : 'No recipes found in "$selectedCategory" category')
                                  : 'No recipes found for "$searchQuery"',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            if (searchQuery.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    searchQuery = "";
                                    _searchController.clear();
                                  });
                                },
                                child: Text(
                                  "Clear search",
                                  style: TextStyle(color: kprimaryColor),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }

                  // For search results, show in a grid layout
                  if (searchQuery.isNotEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: recipes.length,
                        itemBuilder: (context, index) {
                          return FoodItemsDisplay(documentSnapshot: recipes[index]);
                        },
                      ),
                    );
                  }

                  // Default horizontal scroll for non-search
                  return SizedBox(
                    height: 280,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(left: 15, top: 5, bottom: 15),
                      itemCount: recipes.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 15),
                          child: FoodItemsDisplay(documentSnapshot: recipes[index]),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  StreamBuilder<QuerySnapshot> selectedCategoryWidget() {
    return StreamBuilder<QuerySnapshot>(
      stream: categoriesItems.snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
        if (streamSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (streamSnapshot.hasError) {
          return Text(
            'Error loading categories: ${streamSnapshot.error}',
            style: const TextStyle(color: Colors.red),
          );
        }

        if (!streamSnapshot.hasData || streamSnapshot.data!.docs.isEmpty) {
          return const Text('No categories found');
        }

        List<Map<String, dynamic>> categories = streamSnapshot.data!.docs.map((doc) => {
          "name": doc["name"] as String,
          "id": doc.id,
        }).toList();

        return SizedBox(
          height: 45,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = selectedCategory == category["name"];

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedCategory = category["name"];
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected ? kprimaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: isSelected
                        ? [
                      BoxShadow(
                        color: kprimaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ]
                        : null,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  margin: const EdgeInsets.only(right: 15),
                  child: Center(
                    child: Text(
                      category["name"],
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 22),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            searchQuery = value.trim();
          });
        },
        decoration: InputDecoration(
          filled: true,
          prefixIcon: const Icon(Iconsax.search_normal4),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() {
                searchQuery = "";
                _searchController.clear();
              });
            },
          )
              : null,
          fillColor: Colors.white,
          border: InputBorder.none,
          hintText: "Search any recipe",
          hintStyle: const TextStyle(color: Colors.grey),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: kprimaryColor, width: 2),
          ),
        ),
      ),
    );
  }

  Widget headerPart() {
    return const Row(
      children: [
        Text(
          "What are you\ncooking today?",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
        ),
      ],
    );
  }
}