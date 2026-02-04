import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class FavouriteProvider extends ChangeNotifier {
  List<String> _favouriteIds = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<String> get favourites => _favouriteIds;

  FavouriteProvider() {
    loadFavourites();
    // Listen to auth state changes to reload favorites when user changes
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        loadFavourites();
      } else {
        _favouriteIds.clear();
        notifyListeners();
      }
    });
  }

  void toggleFavourite(DocumentSnapshot product) async {
    String productId = product.id;
    if (_favouriteIds.contains(productId)) {
      _favouriteIds.remove(productId);
      await _removeFavourite(productId);
    } else {
      _favouriteIds.add(productId);
      await _addFavourite(productId, product);
    }
    notifyListeners();
  }

  bool doesExist(DocumentSnapshot product) {
    return _favouriteIds.contains(product.id);
  }

  Future<void> _addFavourite(String productId, DocumentSnapshot product) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('No user logged in');
        return;
      }

      await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("favorites")
          .doc(productId)
          .set({
        'recipeId': productId,
        'recipeName': product['name'] ?? '',
        'addedAt': FieldValue.serverTimestamp(),
        'isFavourite': true,
      });
    } catch (e) {
      print('Error adding favourite: ${e.toString()}');
    }
  }

  Future<void> _removeFavourite(String productId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('No user logged in');
        return;
      }

      await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("favorites")
          .doc(productId)
          .delete();
    } catch (e) {
      print('Error removing favourite: ${e.toString()}');
    }
  }

  Future<void> loadFavourites() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('No user logged in');
        _favouriteIds.clear();
        notifyListeners();
        return;
      }

      QuerySnapshot snapshot = await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("favorites")
          .get();

      _favouriteIds = snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print('Error loading favourites: ${e.toString()}');
    }
    notifyListeners();
  }

  static FavouriteProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<FavouriteProvider>(context, listen: listen);
  }
}