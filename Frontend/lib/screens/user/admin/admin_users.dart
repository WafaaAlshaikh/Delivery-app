// lib/screens/admin/admin_users.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../providers/admin_provider.dart';

class AdminUsers extends ConsumerStatefulWidget {
  const AdminUsers({super.key});

  @override
  ConsumerState<AdminUsers> createState() => _AdminUsersState();
}

class _AdminUsersState extends ConsumerState<AdminUsers> {
  String? _selectedRole;
  String _searchQuery = '';
  int _currentPage = 1;

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    
    final roleFilters = [
      null,
      tr.t('role_customer'),
      tr.t('role_merchant'),
      tr.t('role_driver'),
      tr.t('role_admin'),
    ];
    
    final roleValues = [null, 'Customer', 'Merchant', 'Driver', 'Admin'];

    final usersAsync = ref.watch(adminUsersProvider({
      'role': _selectedRole,
      'search': _searchQuery,
      'page': _currentPage,
    }));
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 900;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: isWide
          ? null
          : AppBar(
              title: Text(
                tr.t('users'),
                style: AppTypography.display(18, weight: FontWeight.w700),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {},
                ),
              ],
            ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: tr.t('search_users'),
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
                const SizedBox(width: 12),
                if (isWide)
                  FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(tr.t('add_user')),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: roleFilters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final label = roleFilters[i];
                  final roleValue = roleValues[i];
                  final selected = roleValue == _selectedRole;
                  return ChoiceChip(
                    label: Text(label ?? tr.t('all')),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedRole = roleValue),
                    selectedColor: AppColors.primary,
                    backgroundColor: Colors.white,
                    labelStyle: AppTypography.body(
                      12,
                      weight: FontWeight.w600,
                      color: selected ? Colors.white : AppColors.ink700,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: selected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: usersAsync.when(
              data: (data) {
                final users = data['users'] ?? [];
                if (users.isEmpty) {
                  return Center(
                    child: Text(
                      tr.t('no_users_found'),
                      style: AppTypography.body(13, color: AppColors.ink500),
                    ),
                  );
                }

                if (isWide) {
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 3.6,
                    ),
                    itemCount: users.length,
                    itemBuilder: (context, index) => _UserCard(user: users[index]),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: users.length,
                  itemBuilder: (context, index) => _UserCard(user: users[index]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text(
                  '${tr.t('error')}: $error',
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final Map<String, dynamic> user;

  const _UserCard({required this.user});

  Color _roleColor(String role) {
    switch (role) {
      case 'Admin':
        return AppColors.roleAdmin;
      case 'Merchant':
        return AppColors.roleMerchant;
      case 'Driver':
        return AppColors.roleDriver;
      default:
        return AppColors.roleCustomer;
    }
  }

  String _getRoleText(AppLocalizations tr, String role) {
    switch (role) {
      case 'Admin':
        return tr.t('role_admin');
      case 'Merchant':
        return tr.t('role_merchant');
      case 'Driver':
        return tr.t('role_driver');
      default:
        return tr.t('role_customer');
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final roles = (user['roles'] ?? ['Customer']) as List;
    final isActive = user['is_active'] ?? true;
    final primaryRoleColor = _roleColor(roles.isNotEmpty ? roles.first : 'Customer');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink900.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryRoleColor, primaryRoleColor.withOpacity(0.7)],
              ),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              user['full_name']?.isNotEmpty == true
                  ? user['full_name'][0].toUpperCase()
                  : '?',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['full_name'] ?? 'Unknown',
                  style: AppTypography.body(14, weight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  user['email'] ?? '',
                  style: AppTypography.body(12, color: AppColors.ink500),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: roles.map<Widget>((role) {
                    final color = _roleColor(role);
                    final roleText = _getRoleText(tr, role);
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        roleText,
                        style: AppTypography.body(10, weight: FontWeight.w600, color: color),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isActive ? AppColors.successSoft : AppColors.errorSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isActive ? tr.t('active') : tr.t('inactive'),
              style: AppTypography.body(
                10,
                weight: FontWeight.w600,
                color: isActive ? AppColors.success : AppColors.error,
              ),
            ),
          ),
          const SizedBox(width: 4),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, size: 20),
            onSelected: (value) {},
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'view',
                child: Text(tr.t('view_details')),
              ),
              PopupMenuItem(
                value: isActive ? 'deactivate' : 'activate',
                child: Text(isActive ? tr.t('deactivate') : tr.t('activate')),
              ),
              PopupMenuItem(
                value: 'role',
                child: Text(tr.t('change_role')),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text(
                  tr.t('delete'),
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}