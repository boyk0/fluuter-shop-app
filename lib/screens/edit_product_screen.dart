import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  bool _isInit = true;
  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
    'isFavorite': false,
  };
  String _type = 'create';
  bool _isLoading = false;

  Product _editedProduct = Product(
    id: null,
    title: '',
    price: 0,
    imageUrl: '',
    description: '',
  );

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        final Product product = Provider.of<Products>(context).findById(productId);
        _editedProduct = product;
        _initValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          'imageUrl': '',
          'isFavorite': _editedProduct.isFavorite,
        };
        _imageUrlController.text = _editedProduct.imageUrl;
        _type = 'edit';
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  void _updateImageUrl() {
    if (_imageUrlFocusNode.hasFocus) {
      if (
        _imageUrlController.text.isEmpty || (
            !_imageUrlController.text.startsWith('http') && !_imageUrlController.text.startsWith('https')) || (
            !_imageUrlController.text.endsWith('.png') && !_imageUrlController.text.endsWith('.jpg') && !_imageUrlController.text.endsWith('.jpeg')
        )) {
        return;
      }
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    if (!_form.currentState.validate()) {
      return;
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_type == 'create') {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        await showDialog(
          context: context,
          builder: (ctx) =>
              AlertDialog(
                title: Text('An error occurred!'),
                content: Text('Something went wrong'),
                actions: [
                  FlatButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      // setState(() => _isLoading = false);
                    },
                    child: Text('Okay'),
                  )
                ],
              ),
        );
      } finally {
        setState(() => _isLoading = false);
        Navigator.of(context).pop();
      }

    } else {
      Provider.of<Products>(context, listen: false).editProduct(
        _editedProduct.id, _editedProduct,
      );
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();

    };
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlFocusNode.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _type == 'create' ? Text('Create a product') : Text('Edit product'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: _isLoading ? Center(
        child: CircularProgressIndicator(

        ),
      ) : Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          // onChanged: () => print('qwe'),
          child: ListView(
            children: [
              TextFormField(
                initialValue: _initValues['title'],
                decoration: InputDecoration(
                  labelText: 'Title',
                  errorStyle: TextStyle(
                    color: Colors.red,
                  ),
                ),
                validator: (value) {
                  value = value.trimLeft().trimRight();
                  if (value.isEmpty) {
                    return 'Please, input title';
                  }
                  return null;
                },
                // onSaved: (value) => print(value),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (value) {
                  FocusScope.of(context).requestFocus(_priceFocusNode);
                },
                onSaved: (value) {
                  _editedProduct = Product(
                      id: _editedProduct.id,
                      title: value,
                      description: _editedProduct.description,
                      price: _editedProduct.price,
                      imageUrl: _editedProduct.imageUrl,
                      isFavorite: _editedProduct.isFavorite,
                  );
                },
              ),
              TextFormField(
                initialValue: _initValues['price'],
                decoration: InputDecoration(
                  labelText: 'Price',
                ),
                // onSaved: (value) => print(value),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                focusNode: _priceFocusNode,
                onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_descriptionFocusNode),
                onSaved: (value) {
                  _editedProduct = Product(
                    id: _editedProduct.id,
                    title: _editedProduct.title,
                    description: _editedProduct.description,
                    price: double.parse(value),
                    imageUrl: _editedProduct.imageUrl,
                    isFavorite: _editedProduct.isFavorite,
                  );
                },
                validator: (value) {
                  value = value.trimLeft().trimRight();
                  if (value.isEmpty) {
                    return 'Please, input price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please, input valid number';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Please, enter a number greater than 0';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _initValues['description'],
                decoration: InputDecoration(
                  labelText: 'Description',
                ),
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                focusNode: _descriptionFocusNode,
                onSaved: (value) {
                  _editedProduct = Product(
                    id: _editedProduct.id,
                    title: _editedProduct.title,
                    description: value,
                    price: _editedProduct.price,
                    imageUrl: _editedProduct.imageUrl,
                    isFavorite: _editedProduct.isFavorite,
                  );
                },
                validator: (value) {
                  value = value.trimLeft().trimRight();
                  if (value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                // onSaved: (value) => print(value),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    margin: EdgeInsets.only(top: 8, right: 10),
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.grey),
                    ),
                    child: _imageUrlController.text.isEmpty ? Text('Enter a URL') :  FittedBox(
                      child: Image.network(_imageUrlController.text),
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Image URL',
                      ),
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      controller: _imageUrlController,
                      focusNode: _imageUrlFocusNode,
                      onEditingComplete: () {
                        setState(() {});
                      },
                      onFieldSubmitted: (_) => _saveForm(),
                      onSaved: (value) {
                        _editedProduct = Product(
                          id: _editedProduct.id,
                          title: _editedProduct.title,
                          description: _editedProduct.description,
                          price: _editedProduct.price,
                          imageUrl: value,
                          isFavorite: _editedProduct.isFavorite,
                        );
                      },
                      validator: (value) {
                        value = value.trim();
                        if (value.isEmpty) {
                          return 'Please, input image URL';
                        }
                        if (!value.startsWith('http') && !value.startsWith('https')) {
                          return 'Please, input correct URL';
                        }
                        if (!value.endsWith('.png') && !value.endsWith('.jpg') && !value.endsWith('.jpeg')) {
                          return 'Please, input correct image URL';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
