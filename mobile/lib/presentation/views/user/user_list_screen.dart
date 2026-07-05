import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patient_management_app/domain/entities/user_entity.dart';
import 'package:patient_management_app/presentation/viewmodels/user_viewmodel.dart';
import 'package:patient_management_app/presentation/theme/app_text_styles.dart';
import 'package:patient_management_app/core/widgets/loading_widget.dart';

class UserListScreen extends ConsumerStatefulWidget {
  const UserListScreen({super.key});

  @override
  ConsumerState<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends ConsumerState<UserListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(userViewModelProvider.notifier).fetchUsers());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(userViewModelProvider.notifier).fetchUsers(),
          ),
        ],
      ),
      body: state.isLoading && state.users.isEmpty
          ? const LoadingWidget()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.users.length,
              itemBuilder: (context, index) {
                final user = state.users[index];
                return _buildUserCard(user);
              },
            ),
    );
  }

  Widget _buildUserCard(UserEntity user) {
    final roleColor = _getRoleColor(user.role);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: roleColor.withValues(alpha: 0.1),
          child: Icon(Icons.person, color: roleColor),
        ),
        title: Text(user.fullName, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(user.email, style: AppTextStyles.bodySmall),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: roleColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                user.role,
                style: AppTextStyles.bodySmall.copyWith(color: roleColor, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        trailing: Switch(
          value: user.isActive,
          onChanged: (val) {
            ref.read(userViewModelProvider.notifier).toggleUserStatus(user.id, val);
          },
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Admin':
        return Colors.red;
      case 'Doctor':
        return Colors.blue;
      case 'Nurse':
        return Colors.teal;
      case 'Patient':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
