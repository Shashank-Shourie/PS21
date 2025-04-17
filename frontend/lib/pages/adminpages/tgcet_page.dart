import 'package:flutter/material.dart';

class TGCETPage extends StatefulWidget {
  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<TGCETPage> {
  TextEditingController _searchController = TextEditingController();
  List<String> items = List.generate(20, (index) => 'List item ${index + 1}');
  List<String> filteredItems = [];

  @override
  void initState() {
    super.initState();
    filteredItems = items;
    _searchController.addListener(() {
      filterItems();
    });
  }

  void filterItems() {
    setState(() {
      String query = _searchController.text.toLowerCase();
      filteredItems =
          items.where((item) => item.toLowerCase().contains(query)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TGCET'),
        backgroundColor: Colors.blue[900],
        leading: Icon(Icons.arrow_back),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.blue[900],
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text('CREATE FORM'),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    fillColor: Colors.grey[300],
                    filled: true,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.purple[200],
                    child: Text('A'),
                  ),
                  title: Text(filteredItems[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
