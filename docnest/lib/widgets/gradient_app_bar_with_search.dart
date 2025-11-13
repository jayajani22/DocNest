import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class GradientAppBarWithSearch extends StatefulWidget
    implements PreferredSizeWidget {
  final String title;
  final ValueChanged<String> onSearchChanged;
  final List<Widget>? actions;

  const GradientAppBarWithSearch({
    Key? key,
    required this.title,
    required this.onSearchChanged,
    this.actions,
  }) : super(key: key);

  @override
  _GradientAppBarWithSearchState createState() =>
      _GradientAppBarWithSearchState();

  @override
  Size get preferredSize =>
      Size.fromHeight(120.h); // Height for app bar and search bar
}

class _GradientAppBarWithSearchState extends State<GradientAppBarWithSearch> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      widget.onSearchChanged(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF6A11CB), // #6A11CB
                  Color(0xFF2575FC), // #2575FC
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: Text(
            widget.title,
            style: GoogleFonts.poppins(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                themeProvider.themeMode == ThemeMode.dark
                    ? Icons.wb_sunny
                    : Icons.nightlight_round,
                color: Colors.white,
              ),
              onPressed: () {
                themeProvider.toggleTheme();
              },
            ),
            ...(widget.actions ?? []),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(50.h),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by keyword...',
                  hintStyle: GoogleFonts.poppins(color: Colors.white70),
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  filled: true,
                  fillColor: Colors.white.withAlpha((255 * 0.3).round()),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 0.h),
                ),
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ),
        );
      },
    );
  }
}
