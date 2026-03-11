import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todolist/screens/auth_wrapper.dart';
import 'package:todolist/services/database_service.dart';
import 'package:todolist/models/todo_list_model.dart';

import 'contants/colors.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart' as local_auth;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 1. Authentication Logic
        ChangeNotifierProvider(create: (_) => local_auth.AuthProvider()),

        // 2. Auth State Stream
        StreamProvider<User?>(
          create: (context) => context.read<local_auth.AuthProvider>().user,
          initialData: null,
        ),

        // 3. Database Service (Dependencies on User UID)
        ProxyProvider<User?, DatabaseService>(
          update: (_, user, __) => DatabaseService(uid: user?.uid),
        ),
      ],
      builder: (context, child) {
        return MultiProvider(
          providers: [
            // 4. Realtime Database Stream for Todos
            StreamProvider<List<TodoModel>>.value(
              value: context.select<DatabaseService, Stream<List<TodoModel>>>(
                (db) => db.todos,
              ),
              initialData: const [],
            ),
          ],
          child: MaterialApp(
            title: 'Todo List',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary,
                primary: AppColors.primary,
                secondary: AppColors.secondary,
                surface: AppColors.surface,
                error: AppColors.error,
              ),
              scaffoldBackgroundColor: AppColors.background,
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.surface,
                foregroundColor: AppColors.textPrimary,
                elevation: 0,
                centerTitle: true,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
            home: const AuthWrapper(),
          ),
        );
      },
    );
  }
}
