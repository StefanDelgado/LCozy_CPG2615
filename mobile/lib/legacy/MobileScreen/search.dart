import 'package:flutter/material.dart';

// ==================== SearchScreen Widget ====================
class SearchScreen extends StatefulWidget {
  final List<Map<String, String>> dorms;
  const SearchScreen({super.key, required this.dorms});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

// ==================== SearchScreen State ====================
class _SearchScreenState extends State<SearchScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    // ----------- FILTERED DORMS LOGIC SECTION -----------
    final filteredDorms = widget.dorms
        .where((dorm) =>
            dorm['title']!.toLowerCase().contains(query.toLowerCase()) ||
            dorm['location']!.toLowerCase().contains(query.toLowerCase()) ||
            dorm['desc']!.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      // ----------- APPBAR SECTION -----------
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: Container(
          color: Colors.grey[100],
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black87),
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        Navigator.pushReplacementNamed(context, '/home');
                      }
                    },
                  ),
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 12, right: 4),
                            child: Icon(Icons.search, color: Colors.grey[600]),
                          ),
                          Expanded(
                            child: TextField(
                              style: TextStyle(color: Colors.black87),
                              decoration: InputDecoration(
                                hintText: 'Search for dorms...',
                                hintStyle: TextStyle(color: Colors.grey[600]),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 12),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  query = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // ----------- POPULAR SEARCHES SECTION -----------
          Padding(
            padding: EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Popular Searches in Dormitory',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'Premium Student Housing',
                'Urban Dorms',
                'Budget Dorms',
                'Near Campus',
                'City Center',
                'Affordable',
                'Luxury',
              ].map((search) => GestureDetector(
                onTap: () {
                  setState(() {
                    query = search;
                  });
                },
                child: Chip(
                  label: Text(
                    search,
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  backgroundColor: Colors.grey[200],
                  shape: StadiumBorder(),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
              )).toList(),
            ),
          ),
          // ----------- DORM LIST SECTION -----------
          Expanded(
            child: filteredDorms.isEmpty
                ? Center(child: Text('No dorms found.'))
                : ListView.builder(
                    itemCount: filteredDorms.length,
                    itemBuilder: (context, index) {
                      final dorm = filteredDorms[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          leading: dorm['image'] != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    dorm['image']!,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : null,
                          title: Text(dorm['title'] ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(dorm['location'] ?? ''),
                          trailing: Icon(Icons.arrow_forward_ios, color: Colors.orange),
                          onTap: () {
                            // Show details or do something
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}