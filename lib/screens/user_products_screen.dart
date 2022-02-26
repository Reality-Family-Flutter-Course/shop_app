import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/user_product_item.dart';

import 'edit_product_screen.dart';

class UserProductsScreen extends StatelessWidget {
  static const String routeName = "/user-products";

  const UserProductsScreen({Key? key}) : super(key: key);

  _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false).fetchAndSetProducts();
  }

  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<Products>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ваши товары"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () => _refreshProducts(context),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: ListView.builder(
            itemCount: productData.items.length,
            itemBuilder: (_, index) => Column(
              children: [
                UserProductItem(
                  product: productData.items[index],
                ),
                const Divider(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
