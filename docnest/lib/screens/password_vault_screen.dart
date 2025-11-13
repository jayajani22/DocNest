import 'package:docnest/api/api_service.dart';
import 'package:docnest/widgets/gradient_app_bar_with_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class PasswordVaultScreen extends StatefulWidget {
  const PasswordVaultScreen({Key? key}) : super(key: key);

  @override
  PasswordVaultScreenState createState() => PasswordVaultScreenState();
}

class PasswordVaultScreenState extends State<PasswordVaultScreen> {
  List<dynamic> _passwords = [];
  List<dynamic> _filteredPasswords = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPasswords();
  }

  Future<void> _loadPasswords() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final passwords = await apiService.fetchPasswords();
      setState(() {
        _passwords = passwords ?? [];
        _filteredPasswords = _passwords;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
    }
  }

  void _filterPasswords(String query) {
    final filtered = _passwords.where((password) {
      final siteName = password['site_name']?.toString().toLowerCase() ?? '';
      return siteName.contains(query.toLowerCase());
    }).toList();

    setState(() {
      _searchQuery = query;
      _filteredPasswords = filtered;
    });
  }

  void _addPassword() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        final siteController = TextEditingController();
        final usernameController = TextEditingController();
        final passwordController = TextEditingController();
        bool isPasswordVisible = false;
        return StatefulBuilder(
          builder: (context, setState) => Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
            child: Container(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.lock,
                          color: Colors.red.shade600,
                          size: 24.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Add Password',
                        style: GoogleFonts.poppins(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  TextField(
                    controller: siteController,
                    style: GoogleFonts.inter(),
                    decoration: InputDecoration(
                      labelText: 'Site Name',
                      labelStyle: GoogleFonts.inter(),
                      prefixIcon: Icon(Icons.language,
                          color: Colors.deepPurple.shade300),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: Colors.deepPurple.shade400,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: usernameController,
                    style: GoogleFonts.inter(),
                    decoration: InputDecoration(
                      labelText: 'Username',
                      labelStyle: GoogleFonts.inter(),
                      prefixIcon:
                          Icon(Icons.person, color: Colors.deepPurple.shade300),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: Colors.deepPurple.shade400,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: passwordController,
                    obscureText: !isPasswordVisible,
                    style: GoogleFonts.inter(),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: GoogleFonts.inter(),
                      prefixIcon: Icon(Icons.lock_outline,
                          color: Colors.deepPurple.shade300),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey.shade600,
                        ),
                        onPressed: () => setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        }),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: Colors.deepPurple.shade400,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.inter(color: Colors.grey.shade600),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      ElevatedButton(
                        onPressed: () {
                          if (siteController.text.isNotEmpty &&
                              passwordController.text.isNotEmpty) {
                            Navigator.of(context).pop({
                              'site_name': siteController.text,
                              'username': usernameController.text,
                              'password': passwordController.text,
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Text(
                          'Add',
                          style: GoogleFonts.inter(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (result != null) {
      try {
        await apiService.addPassword(result);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12.w),
                Text(
                  'Password added successfully',
                  style: GoogleFonts.inter(),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
        await _loadPasswords(); // refresh list safely
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'Error: $e',
                    style: GoogleFonts.inter(),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      }
    }
  }

  void _deletePassword(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          'Delete Password',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete this password?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.inter(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });
    try {
      await apiService.deletePassword(id);
      await _loadPasswords(); // Refresh passwords after deleting
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12.w),
              Text(
                'Password deleted successfully',
                style: GoogleFonts.inter(),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  e.toString(),
                  style: GoogleFonts.inter(),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showEditDialog(Map<String, dynamic> password) {
    final siteNameController =
        TextEditingController(text: password['site_name']);
    final usernameController =
        TextEditingController(text: password['username']);
    final passwordController =
        TextEditingController(text: password['password']);
    bool isPasswordVisible = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          child: Container(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.lock,
                        color: Colors.red.shade600,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Edit Password',
                      style: GoogleFonts.poppins(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                TextField(
                  controller: siteNameController,
                  style: GoogleFonts.inter(),
                  decoration: InputDecoration(
                    labelText: 'Site Name',
                    labelStyle: GoogleFonts.inter(),
                    prefixIcon: Icon(Icons.language,
                        color: Colors.deepPurple.shade300),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: Colors.deepPurple.shade400,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: usernameController,
                  style: GoogleFonts.inter(),
                  decoration: InputDecoration(
                    labelText: 'Username',
                    labelStyle: GoogleFonts.inter(),
                    prefixIcon:
                        Icon(Icons.person, color: Colors.deepPurple.shade300),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: Colors.deepPurple.shade400,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: passwordController,
                  obscureText: !isPasswordVisible,
                  style: GoogleFonts.inter(),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: GoogleFonts.inter(),
                    prefixIcon: Icon(Icons.lock_outline,
                        color: Colors.deepPurple.shade300),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey.shade600,
                      ),
                      onPressed: () => setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      }),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: Colors.deepPurple.shade400,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(color: Colors.grey.shade600),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    ElevatedButton(
                      onPressed: () async {
                        final updatedData = {
                          "site_name": siteNameController.text,
                          "username": usernameController.text,
                          "password": passwordController.text,
                        };
                        try {
                          await apiService.updatePassword(
                              password['id'], updatedData);
                          Navigator.pop(context);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle,
                                      color: Colors.white),
                                  SizedBox(width: 12.w),
                                  Text(
                                    'Password updated successfully!',
                                    style: GoogleFonts.inter(),
                                  ),
                                ],
                              ),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                          );
                          _loadPasswords(); // reload updated data
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.error_outline,
                                      color: Colors.white),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Text(
                                      'Error updating password: $e',
                                      style: GoogleFonts.inter(),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: Colors.red.shade400,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        'Save',
                        style: GoogleFonts.inter(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FB),
      appBar: GradientAppBarWithSearch(
        title: 'Password Vault',
        onSearchChanged: _filterPasswords,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.deepPurple.shade600,
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadPasswords,
              color: Colors.deepPurple.shade600,
              child: _filteredPasswords.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(32.w),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.lock_outline,
                              size: 64.sp,
                              color: Colors.red.shade300,
                            ),
                          ),
                          SizedBox(height: 24.h),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No Passwords Yet'
                                : 'No Passwords Found',
                            style: GoogleFonts.poppins(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            _searchQuery.isEmpty
                                ? 'Add your first password to get started'
                                : 'Try a different keyword',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(16.w),
                      itemCount: _filteredPasswords.length,
                      itemBuilder: (context, index) {
                        final password = _filteredPasswords[index];
                        return PasswordCard(
                          password: password,
                          onDelete: () => _deletePassword(password['id']!),
                          onEdit: () => _showEditDialog(password),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'passwords_fab',
        onPressed: _addPassword,
        backgroundColor: const Color(0xFF6A11CB),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Password',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class PasswordCard extends StatefulWidget {
  final Map<String, dynamic> password;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const PasswordCard(
      {Key? key,
      required this.password,
      required this.onDelete,
      required this.onEdit})
      : super(key: key);

  @override
  _PasswordCardState createState() => _PasswordCardState();
}

class _PasswordCardState extends State<PasswordCard> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final siteName = widget.password['site_name'] ?? 'No Site Name';
    final username = widget.password['username'] ?? 'No Username';
    final password = widget.password['password'] ?? '';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.lock,
                    color: Colors.red.shade600,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    siteName,
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 18.sp,
                  color: Colors.grey.shade600,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    username,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 18.sp,
                  color: Colors.grey.shade600,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    _isPasswordVisible ? password : '••••••••',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: Colors.grey.shade700,
                      fontFeatures: [
                        const FontFeature.tabularFigures(),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey.shade600,
                    size: 20.sp,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Divider(color: Colors.grey.shade200),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: widget.onEdit,
                  icon: Icon(Icons.edit_outlined, size: 18.sp),
                  label: Text(
                    'Edit',
                    style: GoogleFonts.inter(),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.deepPurple.shade600,
                  ),
                ),
                SizedBox(width: 8.w),
                TextButton.icon(
                  onPressed: widget.onDelete,
                  icon: Icon(Icons.delete_outline, size: 18.sp),
                  label: Text(
                    'Delete',
                    style: GoogleFonts.inter(),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
