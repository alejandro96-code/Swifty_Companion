import 'package:flutter/material.dart';

import '../components/user_data.dart';
import '../components/user_level.dart';
import '../components/user_projects.dart';
import '../services/forty_two_api.dart';

class InfoScreen extends StatefulWidget {
  final String login;

  const InfoScreen({required this.login, super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  final _api = FortyTwoApi();
  Map<String, dynamic>? _user;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    try {
      final user = await _api.fetchUser(widget.login);
      if (!mounted) return;
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[700],
      body: SafeArea(
        child: Column(
          children: [
            // Header con botón de atrás
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Atrás'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue[700],
                    ),
                  ),
                ],
              ),
            ),
            // Contenido
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    )
                  : _error != null
                      ? Center(
                          child: Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : _user != null
                          ? LayoutBuilder(
                              builder: (context, constraints) {
                                final isWide = constraints.maxWidth >= 900;
                                final content = isWide
                                    ? Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 5,
                                            child: UserData(user: _user!),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            flex: 4,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                UserLevel(
                                                  login: widget.login,
                                                ),
                                                const SizedBox(height: 16),
                                                UserProjects(
                                                  login: widget.login,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                    : Column(
                                        children: [
                                          UserData(user: _user!),
                                          const SizedBox(height: 16),
                                          UserLevel(login: widget.login),
                                          const SizedBox(height: 16),
                                          UserProjects(login: widget.login),
                                        ],
                                      );

                                return SingleChildScrollView(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  child: content,
                                );
                              },
                            )
                          : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}
