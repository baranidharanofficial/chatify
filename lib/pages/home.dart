import 'package:chat/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> signOut() async {
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      await authService.signOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber[50],
        automaticallyImplyLeading: false,
        title: const Text('Chatify'),
        actions: [
          IconButton(
            onPressed: signOut,
            icon: const Icon(
              Icons.logout_rounded,
              size: 24,
            ),
          )
        ],
      ),
      body: const Center(
        child: Text('Home'),
      ),
    );
  }
}
