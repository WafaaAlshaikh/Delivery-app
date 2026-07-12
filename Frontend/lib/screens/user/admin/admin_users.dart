// lib/screens/user/admin/admin_users.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:email_validator/email_validator.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../providers/admin_provider.dart';
import '../../../widgets/custom/custom_text_field.dart';

class AdminUsers extends ConsumerStatefulWidget {
  const AdminUsers({super.key});

  @override
  ConsumerState<AdminUsers> createState() => _AdminUsersState();
}

class _AdminUsersState extends ConsumerState<AdminUsers> {
  String? _selectedRole;
  String _searchQuery = '';
  int _currentPage = 1;

  void _showCreateUserDialog() {
    final tr = context.tr;
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();
    String selectedRole = 'Customer';
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.person_add, color: AppColors.primary),
            const SizedBox(width: 10),
            Text(
              tr.t('add_new_user'),
              style: AppTypography.display(18, weight: FontWeight.w700),
            ),
          ],
        ),
        content: Form(
          key: formKey,
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  controller: nameController,
                  label: tr.t('full_name'),
                  hint: tr.t('enter_full_name'),
                  prefixIcon: const Icon(Icons.person_outline),
                  validator: (v) =>
                      v!.isEmpty ? tr.t('validation_name_required') : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: emailController,
                  label: tr.t('email'),
                  hint: tr.t('enter_email'),
                  prefixIcon: const Icon(Icons.email_outlined),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v!.isEmpty) return tr.t('validation_email_required');
                    if (!EmailValidator.validate(v))
                      return tr.t('validation_email_invalid');
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: phoneController,
                  label: tr.t('phone'),
                  hint: tr.t('enter_phone'),
                  prefixIcon: const Icon(Icons.phone_outlined),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: passwordController,
                  label: tr.t('password'),
                  hint: tr.t('enter_password'),
                  prefixIcon: const Icon(Icons.lock_outline),
                  obscureText: true,
                  validator: (v) {
                    if (v!.isEmpty) return tr.t('validation_password_required');
                    if (v.length < 6) return tr.t('validation_password_min');
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: InputDecoration(
                    labelText: tr.t('role'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'Customer', child: Text('Customer')),
                    DropdownMenuItem(
                        value: 'Merchant', child: Text('Merchant')),
                    DropdownMenuItem(value: 'Driver', child: Text('Driver')),
                    DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                  ],
                  onChanged: (value) {
                    if (value != null) selectedRole = value;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr.t('cancel')),
          ),
          ElevatedButton(
            onPressed: isLoading
                ? null
                : () async {
                    if (formKey.currentState!.validate()) {
                      isLoading = true;
                      (context as Element).markNeedsBuild();

                      try {
                        final adminService = ref.read(adminServiceProvider);
                        final response = await adminService.createUser(
                          fullName: nameController.text.trim(),
                          email: emailController.text.trim(),
                          phone: phoneController.text.trim(),
                          role: selectedRole,
                          password: passwordController.text.trim(),
                        );

                        if (!context.mounted) return;

                        if (response['success']) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('✅ ${tr.t('user_created_success')}'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                          Navigator.pop(context);
                          setState(() {
                            _currentPage = 1;
                          });
                          ref.refresh(adminUsersProvider((
                            role: _selectedRole,
                            search: _searchQuery,
                            page: _currentPage,
                            limit: 20,
                          )));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('❌ ${response['message']}'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('❌ ${tr.t('error')}: ${e.toString()}'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                      isLoading = false;
                      if (context.mounted) {
                        (context as Element).markNeedsBuild();
                      }
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(tr.t('create_user')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('🔍 [DEBUG] AdminUsers.build START');
    final tr = context.tr;

    final roleFilters = [
      null,
      tr.t('role_customer'),
      tr.t('role_merchant'),
      tr.t('role_driver'),
      tr.t('role_admin'),
    ];

    final roleValues = [null, 'Customer', 'Merchant', 'Driver', 'Admin'];

    print('🔍 [DEBUG] Before watching adminUsersProvider');
    print('🔍 [DEBUG] _selectedRole: $_selectedRole');
    print('🔍 [DEBUG] _searchQuery: $_searchQuery');
    print('🔍 [DEBUG] _currentPage: $_currentPage');

    final usersAsync = ref.watch(adminUsersProvider((
      role: _selectedRole,
      search: _searchQuery,
      page: _currentPage,
      limit: 20,
    )));

    print('🔍 [DEBUG] After watching adminUsersProvider');

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
                  icon: const Icon(Icons.add, color: AppColors.primary),
                  onPressed: _showCreateUserDialog,
                  tooltip: tr.t('add_user'),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: AppColors.ink700),
                  onPressed: () {
                    ref.refresh(adminUsersProvider((
                      role: _selectedRole,
                      search: _searchQuery,
                      page: _currentPage,
                      limit: 20,
                    )));
                  },
                  tooltip: tr.t('refresh'),
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
                    onPressed: _showCreateUserDialog,
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(tr.t('add_user')),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 16),
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
                    onSelected: (_) =>
                        setState(() => _selectedRole = roleValue),
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
                print('✅ [DEBUG] usersAsync.data received');
                print('✅ [DEBUG] data: $data');

                if (data == null) {
                  return Center(
                    child: Text(
                      'No data available',
                      style: AppTypography.body(13, color: AppColors.ink500),
                    ),
                  );
                }

                final users = data['users'] ?? [];
                print('✅ [DEBUG] users count: ${users.length}');

                if (users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline,
                            size: 64, color: AppColors.ink300),
                        const SizedBox(height: 16),
                        Text(
                          tr.t('no_users_found'),
                          style: AppTypography.display(18,
                              weight: FontWeight.w700, color: AppColors.ink500),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          tr.t('users_will_appear_here'),
                          style:
                              AppTypography.body(13, color: AppColors.ink300),
                        ),
                      ],
                    ),
                  );
                }

                if (isWide) {
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 3.6,
                    ),
                    itemCount: users.length,
                    itemBuilder: (context, index) =>
                        _UserCard(user: users[index]),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: users.length,
                  itemBuilder: (context, index) =>
                      _UserCard(user: users[index]),
                );
              },
              loading: () {
                print('⏳ [DEBUG] usersAsync.loading');
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading users...'),
                    ],
                  ),
                );
              },
              error: (error, stack) {
                print('❌ [DEBUG] usersAsync.error: $error');
                print('❌ [DEBUG] stack: $stack');
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 48, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text(
                        '${tr.t('error')}: $error',
                        style: const TextStyle(color: AppColors.error),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref.refresh(adminUsersProvider((
                            role: _selectedRole,
                            search: _searchQuery,
                            page: _currentPage,
                            limit: 20,
                          )));
                        },
                        child: Text(tr.t('retry')),
                      ),
                    ],
                  ),
                );
              },
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
    final primaryRoleColor =
        _roleColor(roles.isNotEmpty ? roles.first : 'Customer');

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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        roleText,
                        style: AppTypography.body(10,
                            weight: FontWeight.w600, color: color),
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
