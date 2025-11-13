// QUICK START - COPY & PASTE EXAMPLES FOR YOUR APP
// Use these code snippets directly in your widgets!

// ============================================================================
// EXAMPLE 1: Add Student Button
// ============================================================================

import 'services/firebase_service.dart';

class AddStudentPage extends StatefulWidget {
  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  final FirebaseService _firebaseService = FirebaseService();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _deptController = TextEditingController();

  Future<void> _addStudent() async {
    try {
      String? studentId = await _firebaseService.addStudent(
        name: _nameController.text,
        email: _emailController.text,
        department: _deptController.text,
        semester: 1,
      );

      if (studentId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Student added! ID: $studentId')),
        );
        _nameController.clear();
        _emailController.clear();
        _deptController.clear();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Student')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _deptController,
              decoration: InputDecoration(labelText: 'Department'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addStudent,
              child: Text('Add Student'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _deptController.dispose();
    super.dispose();
  }
}

// ============================================================================
// EXAMPLE 2: List Students (Real-time with StreamBuilder)
// ============================================================================

class StudentListPage extends StatefulWidget {
  @override
  State<StudentListPage> createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Students')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _firebaseService.getStudentsStream(),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // Error state
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          // Data state
          final students = snapshot.data ?? [];

          if (students.isEmpty) {
            return Center(child: Text('No students found'));
          }

          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  title: Text(student['name']),
                  subtitle: Text('${student['email']}\n${student['department']}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      await _firebaseService.deleteStudent(student['id']);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Student deleted')),
                      );
                    },
                  ),
                  onTap: () {
                    // Navigate to student details
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddStudentPage()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 3: Query Students by Department
// ============================================================================

class SearchStudentPage extends StatefulWidget {
  @override
  State<SearchStudentPage> createState() => _SearchStudentPageState();
}

class _SearchStudentPageState extends State<SearchStudentPage> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Map<String, dynamic>> _results = [];
  bool _isLoading = false;

  Future<void> _searchByDepartment(String department) async {
    setState(() => _isLoading = true);

    try {
      final results =
          await _firebaseService.getStudentsByDepartment(department);
      setState(() => _results = results);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search Students')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Department filter buttons
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => _searchByDepartment('Computer Science'),
                  child: Text('CS'),
                ),
                ElevatedButton(
                  onPressed: () => _searchByDepartment('Information Technology'),
                  child: Text('IT'),
                ),
                ElevatedButton(
                  onPressed: () => _searchByDepartment('Business'),
                  child: Text('Business'),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Results
            if (_isLoading)
              CircularProgressIndicator()
            else if (_results.isEmpty)
              Text('No students found')
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final student = _results[index];
                    return ListTile(
                      title: Text(student['name']),
                      subtitle: Text(student['email']),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 4: Update Student Information
// ============================================================================

class EditStudentPage extends StatefulWidget {
  final String studentId;
  final String initialName;

  const EditStudentPage({
    required this.studentId,
    required this.initialName,
  });

  @override
  State<EditStudentPage> createState() => _EditStudentPageState();
}

class _EditStudentPageState extends State<EditStudentPage> {
  final FirebaseService _firebaseService = FirebaseService();
  late TextEditingController _nameController;
  int _semester = 1;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
  }

  Future<void> _updateStudent() async {
    try {
      bool success = await _firebaseService.updateStudent(
        studentId: widget.studentId,
        name: _nameController.text,
        semester: _semester,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Student updated successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Student')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text('Semester: '),
                Slider(
                  value: _semester.toDouble(),
                  min: 1,
                  max: 8,
                  divisions: 7,
                  onChanged: (value) =>
                      setState(() => _semester = value.toInt()),
                ),
                Text('$_semester'),
              ],
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _updateStudent,
              child: Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}

// ============================================================================
// EXAMPLE 5: Dashboard with Statistics
// ============================================================================

class DashboardPage extends StatefulWidget {
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final AdvancedFirebaseService _advancedService = AdvancedFirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Total students count
            FutureBuilder<int>(
              future: _advancedService.countStudents(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Card(
                    child: ListTile(
                      title: Text('Total Students'),
                      trailing: Text(
                        snapshot.data.toString(),
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }
                return Card(child: CircularProgressIndicator());
              },
            ),
            SizedBox(height: 16),
            // CS students count
            FutureBuilder<int>(
              future: _advancedService.countStudentsByDepartment('Computer Science'),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Card(
                    child: ListTile(
                      title: Text('CS Students'),
                      trailing: Text(
                        snapshot.data.toString(),
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }
                return Card(child: CircularProgressIndicator());
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 6: Full App Navigation
// ============================================================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainPage(),
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final pages = [
    StudentListPage(),
    SearchStudentPage(),
    DashboardPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Students',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
        ],
      ),
    );
  }
}
