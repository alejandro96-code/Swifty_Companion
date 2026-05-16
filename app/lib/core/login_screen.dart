import 'dart:async';

import 'package:flutter/material.dart';

import 'info_screen.dart';
import 'services/forty_two_api.dart';

class LoginScreen extends StatefulWidget {
	const LoginScreen({super.key});

	@override
	State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
	final _controller = TextEditingController();
	final _api = FortyTwoApi();
	Timer? _debounce;
	bool _isLoading = false;
	String? _error;
	List<Map<String, dynamic>> _results = [];

	@override
	void dispose() {
		_debounce?.cancel();
		_controller.dispose();
		super.dispose();
	}

	void _onQueryChanged(String value) {
		final query = value.trim();
		_debounce?.cancel();

		if (query.length < 2) {
			setState(() {
				_results = [];
				_error = null;
				_isLoading = false;
			});
			return;
		}

		_debounce = Timer(const Duration(milliseconds: 350), () async {
			setState(() {
				_isLoading = true;
				_error = null;
			});

			try {
				final users = await _api.searchUsers(
					query: query,
					limit: 10,
				);
				if (!mounted) {
					return;
				}
				setState(() {
					_results = users;
				});
			} catch (error) {
				if (!mounted) {
					return;
				}
				setState(() {
					_error = error.toString();
					_results = [];
				});
			} finally {
				if (!mounted) {
					return;
				}
				setState(() {
					_isLoading = false;
				});
			}
		});
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: Colors.red,
			body: SafeArea(
				child: LayoutBuilder(
					builder: (context, constraints) {
						final maxWidth = constraints.maxWidth;
						final contentWidth = maxWidth > 600 ? 420.0 : maxWidth * 0.9;
						final horizontalPadding = maxWidth > 600 ? 32.0 : 20.0;
						final hintStyle = TextStyle(
							color: Colors.black.withOpacity(0.55),
						);
						final listHeight = (_results.length * 92).toDouble();
						final resultsHeight =
								listHeight > 320 ? 320.0 : listHeight;

						return Center(
							child: ConstrainedBox(
								constraints: BoxConstraints(maxWidth: contentWidth),
								child: Padding(
									padding: EdgeInsets.symmetric(
										horizontal: horizontalPadding,
									),
									child: Column(
										mainAxisSize: MainAxisSize.min,
										crossAxisAlignment: CrossAxisAlignment.stretch,
										children: [
											const Text(
												'Login',
												textAlign: TextAlign.center,
												style: TextStyle(
													fontSize: 32,
													fontWeight: FontWeight.bold,
													color: Colors.white,
												),
											),
											const SizedBox(height: 24),
											TextField(
												controller: _controller,
												onChanged: _onQueryChanged,
												decoration: InputDecoration(
													filled: true,
													fillColor: Colors.white,
													hintText: 'Escribe tu login',
													hintStyle: hintStyle,
													border: const OutlineInputBorder(),
												),
											),
											const SizedBox(height: 16),
											if (_isLoading)
												const Center(
													child: SizedBox(
														height: 18,
														width: 18,
														child: CircularProgressIndicator(
															strokeWidth: 2,
														),
													),
												),
											if (_error != null) ...[
												const SizedBox(height: 16),
												Text(
													_error!,
													textAlign: TextAlign.center,
													style: const TextStyle(
														color: Colors.white,
													),
												),
											],
											if (_results.isNotEmpty) ...[
												const SizedBox(height: 16),
												SizedBox(
													height: resultsHeight,
													child: ListView.separated(
														itemCount: _results.length,
														separatorBuilder: (_, __) =>
															const SizedBox(height: 12),
														itemBuilder: (context, index) {
															final user = _results[index];
															return GestureDetector(
																onTap: () {
																	Navigator.push(
																		context,
																		MaterialPageRoute(
																			builder: (context) =>
																				InfoScreen(login: user['login'] as String),
																		),
																	);
																},
																child: Container(
																	padding: const EdgeInsets.all(12),
																	decoration: BoxDecoration(
																		color: Colors.white,
																		borderRadius:
																			BorderRadius.circular(12),
																	),
																	child: Column(
																		crossAxisAlignment:
																			CrossAxisAlignment.start,
																		children: [
																			Text(
																				user['login'] ?? '-',
																				style: const TextStyle(
																					fontWeight: FontWeight.bold,
																				),
																			),
																		],
																	),
																),
															);
														},
													),
												),
											],
										],
									),
								),
							),
						);
					},
				),
			),
		);
	}
}
