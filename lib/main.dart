import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'University Search',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: UniversityListScreen(),
    );
  }
}

class UniversityListScreen extends StatefulWidget {
  @override
  _UniversityListScreenState createState() => _UniversityListScreenState();
}

class _UniversityListScreenState extends State<UniversityListScreen> {
  List universities = [];
  bool isLoading = false;
  final TextEditingController _controller = TextEditingController();

  Future<void> fetchUniversities(String country) async {
    setState(() {
      isLoading = true;
    });
    //pake http.get untuk melakukan permintaan ke API Universitas untuk mencari nama negara yang diberikan.
    final response = await http.get(
        Uri.parse('http://universities.hipolabs.com/search?country=$country'));

    if (response.statusCode == 200) {
      setState(() {
        universities = json.decode(response.body);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load universities');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Universities'), 
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Enter country name',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    String country = _controller.text.trim();
                    if (country.isNotEmpty) {
                      fetchUniversities(country);
                    }
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: universities.length,
                    itemBuilder: (context, index) {
                      return UniversityTile(university: universities[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class UniversityTile extends StatelessWidget {
  final Map university;

  UniversityTile({required this.university});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(university['name']),
      subtitle: Text(university['country']),
      trailing: Icon(Icons.arrow_forward),
      onTap: () {
        launchURL(university['web_pages'][0]);
      },
    );
  }

  void launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
