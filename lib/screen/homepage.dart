import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _quantity = TextEditingController();

  List<Map<String, dynamic>> _items = [];

  final _mydatabase = Hive.box('mydatabase');

  @override
  void initState() {
    super.initState();
    _refreshItems();
  }

  void _refreshItems() {
    final data = _mydatabase.keys.map((key) {
      final item = _mydatabase.get(key);
      return {"key": key, "name": item["name"], "quantity": item["quantity"]};
    }).toList();
    setState(() {
      _items = data.reversed.toList();
    });
  }

  Future<void> _createItem(Map<String, dynamic> newItem) async {
    await _mydatabase.add(newItem);
    _refreshItems();
  }

  Future<void> _updateItem(int itemkey, Map<String, dynamic> item) async {
    await _mydatabase.put(itemkey, item);
    _refreshItems();
  }

  Future<void> _deleteItem(int itemkey) async {
    await _mydatabase.delete(itemkey);
    _refreshItems();

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An item has been deleted")));
  }

  void _showForm(BuildContext context, int? itemkey) async {
    if (itemkey != null) {
      final existingItem =
          _items.firstWhere((element) => element['key'] == itemkey);
      _nameController.text = existingItem['name'];
      _quantity.text = existingItem['quantity'];
    }
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.6,
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                    top: 15,
                    right: 15,
                    left: 15),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                          hintText: "Name",
                          border: OutlineInputBorder(),
                          labelText: "Name"),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _quantity,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          hintText: "quantity",
                          labelText: "Quantity",
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                        onPressed: () async {
                          if (itemkey == null) {
                            _createItem({
                              "name": _nameController.text,
                              "quantity": _quantity.text
                            });
                          }

                          if (itemkey != null) {
                            _updateItem(itemkey, {
                              'name': _nameController.text.trim(),
                              'quantity': _quantity.text.trim()
                            });
                          }

                          _nameController.text = '';
                          _quantity.text = '';
                          Navigator.of(context).pop();
                        },
                        child: Text(itemkey == null ? "Create" : "update"))
                  ],
                ),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: Drawer(),
        appBar: AppBar(
          title: const Text("Hive database"),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.search))
          ],
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              _showForm(context, null);
            },
            child: Icon(Icons.add)),
        body: SafeArea(
          child: ListView.builder(
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final currentItem = _items[index];
              return Card(
                child: ListTile(
                  title: Text(_items[index]['name']),
                  subtitle: Text(_items[index]['quantity']),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(
                        onPressed: () {
                          _showForm(context, currentItem['key']);
                        },
                        icon: const Icon(Icons.edit)),
                    IconButton(
                        onPressed: () => _deleteItem(currentItem['key']),
                        icon: const Icon(Icons.delete))
                  ]),
                ),
              );
            },
          ),
        ));
  }
}
