import 'package:flutter/material.dart';
import 'package:shop_app/providers/product.dart';

class UserProductItem extends StatelessWidget {
  final Product product;

  const UserProductItem({
    required this.product,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(product.title),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(product.imageUrl),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.edit,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.delete,
              color: Theme.of(context).errorColor,
            ),
          ),
        ],
      ),
    );
  }
}
