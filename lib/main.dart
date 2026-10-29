
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color pink = Color(0xFFFF4FA0);
const Color darkPink = Color(0xFFE91E83);
const Color lightPink = Color(0xFFFFE4F0);
const Color luxuryWhite = Color(0xFFFFFBFD);

void main() {
  runApp(const BarbieApp());
}

// ---------------- APP ----------------

class BarbieApp extends StatefulWidget {
  const BarbieApp({super.key});

  @override
  State<BarbieApp> createState() => _BarbieAppState();
}

class _BarbieAppState extends State<BarbieApp> {
  bool checking = true;
  bool loggedIn = false;

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      loggedIn = prefs.getBool('isLoggedIn') ?? false;
      checking = false;
    });
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    if (!mounted) return;
    setState(() => loggedIn = false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Barbie Planner',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: luxuryWhite,
        colorScheme: ColorScheme.fromSeed(seedColor: pink),
        appBarTheme: const AppBarTheme(
          backgroundColor: luxuryWhite,
          foregroundColor: darkPink,
          elevation: 0,
          centerTitle: false,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: pink,
          foregroundColor: Colors.white,
        ),
      ),
      home: checking
          ? const Scaffold(
              body: Center(child: CircularProgressIndicator(color: pink)),
            )
          : loggedIn
              ? PlannerShell(onLogout: logout)
              : LoginPage(
                  onSuccess: () {
                    setState(() => loggedIn = true);
                  },
                ),
    );
  }
}

// ---------------- LOGIN / SIGN UP ----------------

class LoginPage extends StatefulWidget {
  final VoidCallback onSuccess;

  const LoginPage({super.key, required this.onSuccess});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isSignup = true;
  bool hidePassword = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty ||
        (isSignup && name.isEmpty)) {
      showMessage('Please fill in all required details.');
      return;
    }

    if (!email.contains('@')) {
      showMessage('Please enter a valid email address.');
      return;
    }

    if (password.length < 4) {
      showMessage('Password must contain at least 4 characters.');
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    if (isSignup) {
      await prefs.setString('userName', name);
      await prefs.setString('barbie_name', name);
      await prefs.setString('userEmail', email);
      await prefs.setString('userPassword', password);
      await prefs.setBool('isLoggedIn', true);
    } else {
      final savedEmail = prefs.getString('userEmail') ?? '';
      final savedPassword = prefs.getString('userPassword') ?? '';

      if (email != savedEmail || password != savedPassword) {
        showMessage('Email or password is incorrect.');
        return;
      }

      await prefs.setBool('isLoggedIn', true);
    }

    if (!mounted) return;
    widget.onSuccess();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 48,
                  backgroundColor: lightPink,
                  child: Icon(Icons.face_3_rounded, size: 58, color: darkPink),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Barbie Planner',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: darkPink,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Plan your day. Shine your way!',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 28),
                Text(
                  isSignup ? 'Create Your Account' : 'Welcome Back!',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                if (isSignup)
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Your name',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                if (isSignup) const SizedBox(height: 14),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email address',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: passwordController,
                  obscureText: hidePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() => hidePassword = !hidePassword);
                      },
                      icon: Icon(
                        hidePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pink,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: submit,
                    child: Text(isSignup ? 'SIGN UP' : 'LOGIN'),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() => isSignup = !isSignup);
                  },
                  child: Text(
                    isSignup
                        ? 'Already have an account? Login'
                        : 'New here? Create an account',
                    style: const TextStyle(color: darkPink),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Local demo account stored on this device',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------- TASK MODEL ----------------

class PlannerTask {
  String title;
  String description;
  bool completed;

  PlannerTask({
    required this.title,
    this.description = '',
    this.completed = false,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'completed': completed,
        'isDone': completed,
      };

  factory PlannerTask.fromJson(Map<String, dynamic> json) {
    return PlannerTask(
      title: (json['title'] ?? json['task'] ?? 'Untitled task').toString(),
      description: (json['description'] ?? '').toString(),
      completed: json['completed'] == true || json['isDone'] == true,
    );
  }
}

// ---------------- BONUS POINT MODEL ----------------

class BonusPoint {
  String title;
  int points;

  BonusPoint({required this.title, required this.points});

  Map<String, dynamic> toJson() => {
        'title': title,
        'points': points,
      };

  factory BonusPoint.fromJson(Map<String, dynamic> json) {
    return BonusPoint(
      title: (json['title'] ?? 'Bonus').toString(),
      points: (json['points'] as num?)?.toInt() ?? 0,
    );
  }
}

// ---------------- MAIN PLANNER ----------------

class PlannerShell extends StatefulWidget {
  final Future<void> Function() onLogout;

  const PlannerShell({super.key, required this.onLogout});

  @override
  State<PlannerShell> createState() => _PlannerShellState();
}

class _PlannerShellState extends State<PlannerShell> {
  int selectedIndex = 0;
  bool loading = true;

  String userName = 'Barbie Girl';
  String userEmail = '';

  List<PlannerTask> tasks = [];
  List<BonusPoint> bonuses = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final taskText = prefs.getString('barbie_tasks');
    final bonusText = prefs.getString('barbie_bonuses');

    List<PlannerTask> loadedTasks = [];
    List<BonusPoint> loadedBonuses = [];

    try {
      if (taskText != null) {
        final decoded = jsonDecode(taskText);
        if (decoded is List) {
          loadedTasks = decoded
              .whereType<Map>()
              .map((item) => PlannerTask.fromJson(
                    Map<String, dynamic>.from(item),
                  ))
              .toList();
        }
      }
    } catch (_) {
      loadedTasks = [];
    }

    try {
      if (bonusText != null) {
        final decoded = jsonDecode(bonusText);
        if (decoded is List) {
          loadedBonuses = decoded
              .whereType<Map>()
              .map((item) => BonusPoint.fromJson(
                    Map<String, dynamic>.from(item),
                  ))
              .toList();
        }
      }
    } catch (_) {
      loadedBonuses = [];
    }

    if (!mounted) return;
    setState(() {
      userName = prefs.getString('barbie_name') ??
          prefs.getString('userName') ??
          'Barbie Girl';
      userEmail = prefs.getString('userEmail') ?? '';
      tasks = loadedTasks;
      bonuses = loadedBonuses;
      loading = false;
    });

    await saveTasks();
  }

  Future<void> saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'barbie_tasks',
      jsonEncode(tasks.map((task) => task.toJson()).toList()),
    );
  }

  Future<void> saveBonuses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'barbie_bonuses',
      jsonEncode(bonuses.map((bonus) => bonus.toJson()).toList()),
    );
  }

  int get completedCount => tasks.where((task) => task.completed).length;

  int get totalPoints =>
      (completedCount * 10) +
      bonuses.fold<int>(0, (sum, bonus) => sum + bonus.points);

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> editTask({int? index}) async {
    final titleController = TextEditingController(
      text: index == null ? '' : tasks[index].title,
    );
    final descriptionController = TextEditingController(
      text: index == null ? '' : tasks[index].description,
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(index == null ? 'Add a Task' : 'Edit Task'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Task name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isEmpty) return;
              Navigator.pop(dialogContext, true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true && titleController.text.trim().isNotEmpty) {
      setState(() {
        final task = PlannerTask(
          title: titleController.text.trim(),
          description: descriptionController.text.trim(),
          completed: index == null ? false : tasks[index].completed,
        );

        if (index == null) {
          tasks.add(task);
        } else {
          tasks[index] = task;
        }
      });
      await saveTasks();
    }

    titleController.dispose();
    descriptionController.dispose();
  }

  Future<void> deleteTask(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text('Delete "${tasks[index].title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => tasks.removeAt(index));
      await saveTasks();
    }
  }

  Future<void> editBonus({int? index}) async {
    final titleController = TextEditingController(
      text: index == null ? '' : bonuses[index].title,
    );
    final pointsController = TextEditingController(
      text: index == null ? '5' : bonuses[index].points.toString(),
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(index == null ? 'Add Bonus Points' : 'Edit Bonus Points'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Bonus reason',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: pointsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Points',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final points = int.tryParse(pointsController.text);
              if (titleController.text.trim().isEmpty ||
                  points == null ||
                  points < 0) {
                return;
              }
              Navigator.pop(dialogContext, true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    final points = int.tryParse(pointsController.text);

    if (result == true && points != null && points >= 0 &&
        titleController.text.trim().isNotEmpty) {
      setState(() {
        final bonus = BonusPoint(
          title: titleController.text.trim(),
          points: points,
        );
        if (index == null) {
          bonuses.add(bonus);
        } else {
          bonuses[index] = bonus;
        }
      });
      await saveBonuses();
    }

    titleController.dispose();
    pointsController.dispose();
  }

  Future<void> deleteBonus(int index) async {
    setState(() => bonuses.removeAt(index));
    await saveBonuses();
  }

  Future<void> editProfile() async {
    final nameController = TextEditingController(text: userName);
    final emailController = TextEditingController(text: userEmail);

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty ||
                  !emailController.text.trim().contains('@')) {
                return;
              }
              Navigator.pop(dialogContext, true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true) {
      final prefs = await SharedPreferences.getInstance();
      userName = nameController.text.trim();
      userEmail = emailController.text.trim().toLowerCase();

      await prefs.setString('userName', userName);
      await prefs.setString('barbie_name', userName);
      await prefs.setString('userEmail', userEmail);

      if (mounted) setState(() {});
    }

    nameController.dispose();
    emailController.dispose();
  }

  Widget buildHome() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Hello, $userName! 💗',
          style: const TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.bold,
            color: darkPink,
          ),
        ),
        const SizedBox(height: 6),
        const Text('Today is your day to sparkle ✨'),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [pink, darkPink],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'YOUR BARBIE SCORE',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '$totalPoints points ✨',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$completedCount of ${tasks.length} tasks completed',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: summaryCard(
                'Total Tasks',
                '${tasks.length}',
                Icons.checklist_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: summaryCard(
                'Completed',
                '$completedCount',
                Icons.favorite_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Your Tasks 💕',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (tasks.isEmpty)
          const Text('No tasks yet. Tap Planner to add your first task.')
        else
          ...tasks.take(3).map(
                (task) => Card(
                  child: ListTile(
                    leading: Icon(
                      task.completed
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: pink,
                    ),
                    title: Text(task.title),
                    subtitle: Text(task.completed ? 'Completed' : 'In progress'),
                  ),
                ),
              ),
      ],
    );
  }

  Widget summaryCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(icon, color: pink, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: darkPink,
              ),
            ),
            Text(title),
          ],
        ),
      ),
    );
  }

  Widget buildTasks() {
    if (tasks.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Text(
            'Your planner is waiting for its first task! 💗\nTap + to add one.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 7),
          child: ListTile(
            leading: Checkbox(
              activeColor: pink,
              value: task.completed,
              onChanged: (value) async {
                setState(() => task.completed = value ?? false);
                await saveTasks();
              },
            ),
            title: Text(
              task.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration:
                    task.completed ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: task.description.isEmpty
                ? Text(task.completed ? 'Completed · +10 points' : 'In progress')
                : Text(task.description),
            trailing: PopupMenuButton<String>(
              onSelected: (choice) {
                if (choice == 'edit') editTask(index: index);
                if (choice == 'delete') deleteTask(index);
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildProgress() {
    final percent = tasks.isEmpty ? 0.0 : completedCount / tasks.length;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Your Progress ✨',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: darkPink,
          ),
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                Text(
                  '${(percent * 100).round()}%',
                  style: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    color: darkPink,
                  ),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: percent,
                  minHeight: 10,
                  color: pink,
                  backgroundColor: lightPink,
                ),
                const SizedBox(height: 10),
                Text('$completedCount / ${tasks.length} tasks completed'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.stars_rounded, color: pink, size: 35),
            title: const Text('Total Bonus Points'),
            subtitle: Text(
              '$totalPoints points · 10 points for each completed task',
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Bonus Points',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: () => editBonus(),
              icon: const Icon(Icons.add_circle, color: pink, size: 30),
              tooltip: 'Add bonus',
            ),
          ],
        ),
        const Text('Add your own rewards, then edit or delete them anytime.'),
        const SizedBox(height: 10),
        if (bonuses.isEmpty)
          const Text('No extra bonuses yet. Tap + to add one.')
        else
          ...List.generate(bonuses.length, (index) {
            final bonus = bonuses[index];
            return Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: lightPink,
                  child: Icon(Icons.card_giftcard, color: darkPink),
                ),
                title: Text(bonus.title),
                subtitle: Text('${bonus.points} points'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => editBonus(index: index),
                      icon: const Icon(Icons.edit_outlined, color: darkPink),
                    ),
                    IconButton(
                      onPressed: () => deleteBonus(index),
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget buildProfile() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 12),
        const CircleAvatar(
          radius: 58,
          backgroundColor: lightPink,
          child: Icon(Icons.face_3_rounded, size: 75, color: darkPink),
        ),
        const SizedBox(height: 18),
        Text(
          userName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: darkPink,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          userEmail,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 28),
        Card(
          child: ListTile(
            leading: const Icon(Icons.person_outline, color: pink),
            title: const Text('Edit Profile'),
            subtitle: const Text('Change your name or email'),
            trailing: const Icon(Icons.chevron_right),
            onTap: editProfile,
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.stars_rounded, color: pink),
            title: const Text('Your Points'),
            subtitle: Text('$totalPoints Barbie points'),
          ),
        ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Logout?'),
                content: const Text('Are you sure you want to log out?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            );

            if (confirm == true) await widget.onLogout();
          },
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
          style: OutlinedButton.styleFrom(
            foregroundColor: darkPink,
            side: const BorderSide(color: pink),
            padding: const EdgeInsets.all(14),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: pink)),
      );
    }

    final titles = ['Home', 'Planner', 'Progress', 'Profile'];

    final pages = [
      buildHome(),
      buildTasks(),
      buildProgress(),
      buildProfile(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Barbie ${titles[selectedIndex]} 💗',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: pages[selectedIndex],
      floatingActionButton: selectedIndex == 1
          ? FloatingActionButton(
              onPressed: () => editTask(),
              child: const Icon(Icons.add),
            )
          : selectedIndex == 2
              ? FloatingActionButton(
                  onPressed: () => editBonus(),
                  child: const Icon(Icons.stars),
                )
              : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        backgroundColor: Colors.white,
        indicatorColor: lightPink,
        onDestinationSelected: (index) {
          setState(() => selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: darkPink),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_rounded),
            selectedIcon: Icon(Icons.checklist, color: darkPink),
            label: 'Planner',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights, color: darkPink),
            label: 'Progress',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: darkPink),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
