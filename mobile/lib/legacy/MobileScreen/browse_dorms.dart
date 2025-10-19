import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'viewdetails.dart';

class BrowseDormsScreen extends StatefulWidget {
  final String? searchQuery;
  final String userEmail;
  
  const BrowseDormsScreen({
    Key? key, 
    this.searchQuery,
    required this.userEmail,
  }) : super(key: key);

  @override
  State<BrowseDormsScreen> createState() => _BrowseDormsScreenState();
}

class _BrowseDormsScreenState extends State<BrowseDormsScreen> {
  bool isLoading = true;
  String? error;
  List<Map<String, dynamic>> dorms = [];

  @override
  void initState() {
    super.initState();
    fetchDorms();
  }

  Future<void> fetchDorms() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final uri = Uri.parse('http://cozydorms.life/modules/mobile-api/student/student_home_api.php');
      final rsp = await http.get(uri);
      if (rsp.statusCode != 200) throw Exception('Server ${rsp.statusCode}');
      final data = jsonDecode(rsp.body);
      if (data is Map && data['ok'] == true && data['dorms'] != null) {
        var list = List.from(data['dorms']);
        var items = list.map((e) => Map<String, dynamic>.from(e)).toList();
        if (widget.searchQuery != null && widget.searchQuery!.trim().isNotEmpty) {
          final q = widget.searchQuery!.toLowerCase();
          items = items.where((p) {
            final t = (p['title'] ?? '').toString().toLowerCase();
            final l = (p['location'] ?? '').toString().toLowerCase();
            return t.contains(q) || l.contains(q);
          }).toList();
        }
        setState(() {
          dorms = items;
          isLoading = false;
        });
      } else {
        throw Exception('Invalid response');
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (error != null) {
      content = ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [Padding(padding: const EdgeInsets.all(20), child: Text('Error: $error'))],
      );
    } else if (dorms.isEmpty) {
      content = ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [Padding(padding: EdgeInsets.all(20), child: Text('No dorms found'))],
      );
    } else {
      content = ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: dorms.length,
        itemBuilder: (context, i) {
          final d = dorms[i];
          final image = d['image'] ?? '';
          final title = d['title'] ?? 'Unnamed Dorm';
          final location = d['location'] ?? '';
          final minPrice = d['min_price'] ?? '';
          final available = d['available_rooms']?.toString() ?? '0';

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: InkWell(
              onTap: () {
                // adapt to existing view details signature which expects Map<String,String>
                final prop = <String, String>{
                  'dorm_id': d['dorm_id']?.toString() ?? '',
                  'title': title.toString(),
                  'location': location.toString(),
                  'desc': (d['desc'] ?? '').toString(),
                  'image': (image ?? '').toString(),
                  'owner_email': (d['owner_email'] ?? '').toString(),
                  'owner_name': (d['owner_name'] ?? '').toString(),
                  'min_price': minPrice.toString(),
                  'available_rooms': available.toString(),
                };
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ViewDetailsScreen(
                      property: prop,
                      userEmail: widget.userEmail,
                    ),
                  ),
                );
              },
              child: Row(
                children: [
                  Container(
                    width: 110,
                    height: 90,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                      color: Colors.grey[200],
                      image: (image != null && image != '')
                          ? DecorationImage(image: NetworkImage(image), fit: BoxFit.cover)
                          : null,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text(location, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              if (minPrice != null && minPrice != '') Text(minPrice, style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                              const Spacer(),
                              Text('$available rooms', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                            ],
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.searchQuery == null || widget.searchQuery!.isEmpty ? 'Browse Dorms' : 'Search: ${widget.searchQuery}'),
        backgroundColor: AppTheme.primary,
      ),
      body: RefreshIndicator(
        onRefresh: fetchDorms,
        child: content,
      ),
    );
  }
}