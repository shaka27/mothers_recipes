import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class FavouriteProvider extends ChangeNotifier {
  List<String> _favouriteIds = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> get favourites => _favouriteIds;

  FavouriteProvider() {
    loadFavourites();
  }
  void toggleFavourite(DocumentSnapshot product) async {
    String productId = product.id;
    if (_favouriteIds.contains(productId)) {
      _favouriteIds.remove(productId);
      await _removeFavourite(productId);
    } else {
      _favouriteIds.add(productId);
      await _addFavourite(productId);
    }
    notifyListeners();
  }

  bool doesExist(DocumentSnapshot product) {
    return _favouriteIds.contains(product.id);
  }

  Future<void> _addFavourite(String productId) async {
    try {
      await _firestore.collection("userFavourite").doc(productId).set({
        'isFavourite': true,
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _removeFavourite(String productId) async {
    try {
      await _firestore.collection("userFavourite").doc(productId).delete();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> loadFavourites() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection("userFavourite")
          .get();

      _favouriteIds = snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print(e.toString());
    }
    notifyListeners();
  }

  static FavouriteProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<FavouriteProvider>(context, listen: listen);
  }
}
