import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const String routeName = "/edit-product";

  const EditProductScreen({Key? key}) : super(key: key);

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();

  final _imageURLController = TextEditingController();

  final _key = GlobalKey<FormState>();

  Product _newProduct = Product(
    id: "",
    title: "",
    description: "",
    price: -1,
    imageUrl: "",
  );

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageURLController.dispose();
    super.dispose();
  }

  void _saveProduct() {
    if (_key.currentState!.validate()) {
      _key.currentState!.save();

      Provider.of<Products>(context, listen: false).addProduct(_newProduct);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Изменение продукта"),
        actions: [
          IconButton(
            onPressed: () {
              _saveProduct();
            },
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Form(
          key: _key,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Название",
                ),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (value) {
                  FocusScope.of(context).requestFocus(_priceFocusNode);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Введите пожалуйста название";
                  }
                  return null;
                },
                onSaved: (newValue) {
                  _newProduct = Product(
                    id: _newProduct.id,
                    title: newValue!,
                    description: _newProduct.description,
                    price: _newProduct.price,
                    imageUrl: _newProduct.imageUrl,
                  );
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Цена",
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
                focusNode: _priceFocusNode,
                onFieldSubmitted: (value) {
                  FocusScope.of(context).requestFocus(_descriptionFocusNode);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Введите пожалуйста цену";
                  }
                  if (double.tryParse(value) == null) {
                    return "Введите пожалуйста корректное значение";
                  }
                  if (double.parse(value) <= 0) {
                    return "Введите пожалуйста корректную сумму";
                  }
                  return null;
                },
                onSaved: (newValue) {
                  _newProduct = Product(
                    id: _newProduct.id,
                    title: _newProduct.title,
                    description: _newProduct.description,
                    price: double.parse(newValue!),
                    imageUrl: _newProduct.imageUrl,
                  );
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Описание",
                ),
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                focusNode: _descriptionFocusNode,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Введите пожалуйста описание";
                  }
                  if (value.length < 10) {
                    return "Описание должно быть более 10 символов";
                  }
                  return null;
                },
                onSaved: (newValue) {
                  _newProduct = Product(
                    id: _newProduct.id,
                    title: _newProduct.title,
                    description: newValue!,
                    price: _newProduct.price,
                    imageUrl: _newProduct.imageUrl,
                  );
                },
              ),
              Row(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.only(
                      top: 10,
                      right: 10,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Colors.grey,
                      ),
                    ),
                    child: _imageURLController.text.isEmpty
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                "Введите путь до фотографии",
                                textAlign: TextAlign.center,
                              ),
                            ],
                          )
                        : Image.network(
                            _imageURLController.text,
                            fit: BoxFit.cover,
                          ),
                  ),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                          labelText: "Ссылка на фотографию"),
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      controller: _imageURLController,
                      onEditingComplete: () {
                        if ((_imageURLController.text.isEmpty) ||
                            (!_imageURLController.text.startsWith("http://") &&
                                !_imageURLController.text
                                    .startsWith("https://")) ||
                            (!_imageURLController.text.endsWith(".png") &&
                                !_imageURLController.text.endsWith(".jpg") &&
                                !_imageURLController.text.endsWith(".jpeg"))) {
                          return;
                        }
                        setState(() {});
                      },
                      onFieldSubmitted: (_) {
                        _saveProduct();
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Введите пожалуйста ссылку фотографии";
                        }
                        if (!value.startsWith("http://") &&
                            !value.startsWith("https://")) {
                          return "Введите пожалуйста корректную ссылку на фотографию";
                        }
                        if (!value.endsWith(".png") &&
                            !value.endsWith(".jpg") &&
                            !value.endsWith(".jpeg")) {
                          return "Введите пожалуйста корректную ссылку на фотографию";
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        _newProduct = Product(
                          id: _newProduct.id,
                          title: _newProduct.title,
                          description: _newProduct.description,
                          price: _newProduct.price,
                          imageUrl: newValue!,
                        );
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
