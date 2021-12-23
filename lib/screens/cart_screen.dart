import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart.dart' show Cart;
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/widgets/cart_item.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';

  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Корзина'),
      ),
      body: Column(
        children: <Widget>[
          Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text(
                    'Итого',
                    style: TextStyle(fontSize: 20),
                  ),
                  const Spacer(),
                  Chip(
                    label: Text(
                      '${cart.totalAmount} руб.',
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  TextButton(
                    child: const Text('Оформить заказ'),
                    onPressed: () {
                      Provider.of<Orders>(context, listen: false).addOrder(
                        cart.order.values.toList(),
                        cart.totalAmount,
                      );
                      cart.clear();
                    },
                    style: TextButton.styleFrom(
                      primary: Theme.of(context).colorScheme.primary,
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: cart.order.length,
              itemBuilder: (ctx, i) => CartItem(
                id: cart.order.values.toList()[i].id,
                productId: cart.order.keys.toList()[i],
                price: cart.order.values.toList()[i].price,
                quantity: cart.order.values.toList()[i].quantity,
                title: cart.order.values.toList()[i].product.title,
              ),
            ),
          )
        ],
      ),
    );
  }
}
