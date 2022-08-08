import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';
import '../providers/product.dart';
import '../screens/product_detail_screen.dart';

class ProductItem extends StatelessWidget{
  // final Product product;
  //
  // ProductItem(this.product);

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);


    return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: GridTile(
          child: GestureDetector(
            child: Image.network(
              product.imageUrl,
              fit: BoxFit.cover,
            ),
            onTap: () {
              Navigator.of(context).pushNamed(ProductDetailScreen.routeName, arguments: product);
            },
          ),
          footer: GridTileBar(
            leading: Consumer<Product>(
              builder: (ctx, product, _) => IconButton(
                icon: product.isFavorite ? Icon(Icons.favorite) : Icon(Icons.favorite_border),
                onPressed: () async {
                  try {
                    await product.toggleFavoriteStatus();
                    Scaffold.of(context).showSnackBar(SnackBar(content: Text('Change favorite status was successful')));
                  } catch (error) {
                    Scaffold.of(context).showSnackBar(SnackBar(content: Text('Change favorite status was not successful')));
                  }
                },
                color: Theme.of(context).accentColor,
              ),
            ),
            backgroundColor: Colors.black87,
            title: Text(
              product.title,
              textAlign: TextAlign.center,
            ),
            trailing: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                cart.addItem(product.id, product.price, product.title);
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Added item to cart!',
                        textAlign: TextAlign.center,
                      ),
                      action: SnackBarAction(
                        onPressed: () => cart.removeSingleItem(product.id),
                        label: 'UNDO',
                      ),
                      duration: Duration(seconds: 2),
                    ),
                );
              },
              color: Theme.of(context).accentColor,
            ),
          ),
        ),
    );
  }
}