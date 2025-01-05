import 'package:flutter/material.dart';
import 'dart:convert'; // For JSON decoding
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Grades',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple, // Changed primary color to deep purple
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false, // Remove debug banner
      home: StudentScreen(),
    );
  }
}

class StudentScreen extends StatefulWidget {
  @override
  _StudentScreenState createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  final TextEditingController _studentIdController = TextEditingController();
  String? _studentName;
  String? _studentGrade;
  String? _studentSubject;
  String? _errorMessage;
  bool _isLoading = false;

  Future<void> fetchStudentData(String studentId) async {
    final url = 'http://prjct.atwebpages.com/get_grade.php?student_id=$studentId';

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);

          if (data['error'] != null) {
            setState(() {
              _errorMessage = data['error'];
              _studentName = null;
              _studentGrade = null;
              _studentSubject = null;
            });
          } else {
            setState(() {
              _studentName = data['name'];
              _studentGrade = data['grade'];
              _studentSubject = data['subject'];
              _errorMessage = null;
            });
          }
        } catch (e) {
          setState(() {
            _errorMessage = 'Invalid response format: $e';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Server error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Grades'),
        backgroundColor: Colors.deepPurple, // Updated AppBar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 8,
                color: Colors.deepPurple[50], // Light purple background for input section
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _studentIdController,
                        decoration: InputDecoration(
                          labelText: 'Enter Student ID',
                          labelStyle: TextStyle(color: Colors.deepPurple),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(Icons.search, color: Colors.deepPurple), // Centered icon
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (_studentIdController.text.isNotEmpty) {
                            fetchStudentData(_studentIdController.text);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          primary: Colors.deepPurple, // Button color
                        ),
                        icon: Icon(Icons.cloud_download, color: Colors.white), // Centered icon
                        label: Text('Get Student Data', style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              if (_isLoading)
                Center(child: CircularProgressIndicator())
              else if (_errorMessage != null)
                Center(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                )
              else if (_studentName != null && _studentGrade != null && _studentSubject != null)
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 8,
                    color: Colors.lightBlue[50], // Light blue background for result section
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Name: $_studentName',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Grade: $_studentGrade',
                            style: TextStyle(fontSize: 18, color: Colors.deepPurple),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Subject: $_studentSubject',
                            style: TextStyle(fontSize: 18, color: Colors.deepPurple),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
