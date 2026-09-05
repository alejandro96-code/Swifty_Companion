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
        _error = _api.errorMessage(error);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Image.asset(
            'web/img/42Background.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Container(color: const Color(0xB8001024)),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: SizedBox(
                    height: 48,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Atras'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.95),
                              foregroundColor: const Color(0xFF0C2E5A),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                        const Text(
                          'Perfil 42',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
                                    final isWide = constraints.maxWidth >= 980;
                                    final maxCardHeight = 520.0;
                                    final content = isWide
                                        ? Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: SizedBox(
                                                  height: maxCardHeight,
                                                  child: UserData(
                                                    user: _user!,
                                                    forceTwoColumns: true,
                                                    fillHeight: true,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 20),
                                              Expanded(
                                                child: SizedBox(
                                                  height: maxCardHeight,
                                                  child: UserLevel(
                                                    login: widget.login,
                                                    maxListHeight:
                                                        maxCardHeight - 120,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 20),
                                              Expanded(
                                                child: SizedBox(
                                                  height: maxCardHeight,
                                                  child: UserProjects(
                                                    login: widget.login,
                                                    maxListHeight:
                                                        maxCardHeight - 170,
                                                  ),
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

                                    return Center(
                                      child: SingleChildScrollView(
                                        padding: const EdgeInsets.fromLTRB(
                                          18,
                                          8,
                                          18,
                                          24,
                                        ),
                                        child: ConstrainedBox(
                                          constraints:
                                              const BoxConstraints(maxWidth: 1120),
                                          child: content,
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : const SizedBox(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
