import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth.dart';
import 'providers/cart.dart';
import 'providers/orders.dart';
import 'providers/products.dart';
import 'screens/auth_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/edit_product_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/products_overview_screen.dart';
import 'screens/user_products_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider.value(
          value: Auth(),
      ),
      ChangeNotifierProxyProvider<Auth, Products>(
        update: (_, auth, products) => Products(auth.token, auth.userId, products == null ? [] : products.items),
      ),
      ChangeNotifierProvider.value(
        value: Cart(),
      ),
      ChangeNotifierProxyProvider<Auth, Orders>(
        update: (_, auth, orders) => Orders(auth.token, orders == null ? [] : orders.orders),
      ),
    ],
      child: Consumer<Auth>(
        builder: (ctx, authData, child) =>  MaterialApp(
          title: 'MyShop',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            fontFamily: 'Lato',
            textTheme: TextTheme(
              titleMedium: TextStyle(
                color: Colors.black,
              )
            ),
          ),
          home: authData.isAuth ? ProductsOverViewScreen() : AuthScreen(),
          routes: {
            ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrdersScreen.routeName: (ctx) => OrdersScreen(),
            UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen(),
            ProductsOverViewScreen.routeName: (ctx) => ProductsOverViewScreen(),
          },
        ),
      ),
    );
  }
}
