import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../constants/app_constants.dart';

/// Item menu sidebar
class SidebarItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;
  final List<String> roles; // role yang bisa mengakses

  const SidebarItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
    this.roles = const [AppConstants.roleAdmin, AppConstants.roleDoctor],
  });
}

/// Daftar menu sidebar
final List<SidebarItem> sidebarMenus = [
  const SidebarItem(
    label: 'Dashboard',
    icon: Icons.dashboard_outlined,
    activeIcon: Icons.dashboard_rounded,
    route: '/dashboard',
  ),
  const SidebarItem(
    label: 'Pasien',
    icon: Icons.people_outline_rounded,
    activeIcon: Icons.people_rounded,
    route: '/patients',
  ),
  const SidebarItem(
    label: 'Antrian',
    icon: Icons.format_list_numbered_rounded,
    activeIcon: Icons.format_list_numbered_rounded,
    route: '/queue',
  ),
  const SidebarItem(
    label: 'Dokter',
    icon: Icons.medical_services_outlined,
    activeIcon: Icons.medical_services_rounded,
    route: '/doctors',
  ),
  const SidebarItem(
    label: 'Rekam Medis',
    icon: Icons.assignment_outlined,
    activeIcon: Icons.assignment_rounded,
    route: '/medical-records',
    roles: [AppConstants.roleDoctor, AppConstants.roleAdmin],
  ),
  const SidebarItem(
    label: 'Apotek',
    icon: Icons.local_pharmacy_outlined,
    activeIcon: Icons.local_pharmacy_rounded,
    route: '/pharmacy',
    roles: [AppConstants.roleAdmin],
  ),
  const SidebarItem(
    label: 'Keuangan',
    icon: Icons.account_balance_wallet_outlined,
    activeIcon: Icons.account_balance_wallet_rounded,
    route: '/finance',
    roles: [AppConstants.roleAdmin],
  ),
  const SidebarItem(
    label: 'Konsultasi',
    icon: Icons.chat_outlined,
    activeIcon: Icons.chat_rounded,
    route: '/consultation',
  ),
  const SidebarItem(
    label: 'Laporan',
    icon: Icons.bar_chart_outlined,
    activeIcon: Icons.bar_chart_rounded,
    route: '/reports',
    roles: [AppConstants.roleAdmin],
  ),
  const SidebarItem(
    label: 'Pengaturan',
    icon: Icons.settings_outlined,
    activeIcon: Icons.settings_rounded,
    route: '/settings',
    roles: [AppConstants.roleAdmin],
  ),
];

/// Widget sidebar navigasi utama
class AppSidebar extends StatefulWidget {
  final String currentRoute;
  final String userRole;
  final String userName;
  final String userEmail;
  final VoidCallback onLogout;
  final ValueChanged<String> onNavigate;

  const AppSidebar({
    super.key,
    required this.currentRoute,
    required this.userRole,
    required this.userName,
    required this.userEmail,
    required this.onLogout,
    required this.onNavigate,
  });

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  bool _isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final filteredMenus = sidebarMenus
        .where((item) => item.roles.contains(widget.userRole))
        .toList();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: _isCollapsed ? 72 : 260,
      decoration: const BoxDecoration(
        color: AppColors.sidebarBg,
        border: Border(
          right: BorderSide(color: Color(0xFFD6E6F9), width: 1),
        ),
      ),
      child: Column(
        children: [
          // Logo & Brand
          _buildHeader(),

          const SizedBox(height: 8),

          // Menu Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              itemCount: filteredMenus.length,
              itemBuilder: (context, index) {
                final item = filteredMenus[index];
                final isActive = widget.currentRoute.startsWith(item.route);
                return _SidebarMenuTile(
                  item: item,
                  isActive: isActive,
                  isCollapsed: _isCollapsed,
                  onTap: () => widget.onNavigate(item.route),
                );
              },
            ),
          ),

          // User Info & Logout
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(_isCollapsed ? 8 : 16, 24, 8, 16),
      child: _isCollapsed
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 16),
                IconButton(
                  onPressed: () => setState(() => _isCollapsed = false),
                  icon: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.sidebarText,
                    size: 24,
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jalan Sehat',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      Text(
                        'Klinik Medina',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppColors.sidebarText,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _isCollapsed = !_isCollapsed),
                  icon: const Icon(
                    Icons.chevron_left_rounded,
                    color: AppColors.sidebarText,
                    size: 20,
                  ),
                  splashRadius: 18,
                  tooltip: 'Collapse',
                ),
              ],
            ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface, // professional light blue for footer
        borderRadius: BorderRadius.circular(12),
      ),
      child: _isCollapsed
          ? Center(
              child: CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary,
                child: Text(
                  widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : 'U',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            )
          : Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : 'U',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.userName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.userRole == AppConstants.roleAdmin
                            ? 'Administrator'
                            : 'Dokter',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppColors.sidebarText,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: widget.onLogout,
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.sidebarText,
                    size: 18,
                  ),
                  splashRadius: 16,
                  tooltip: 'Logout',
                ),
              ],
            ),
    );
  }
}

/// Tile menu item sidebar dengan animasi hover
class _SidebarMenuTile extends StatefulWidget {
  final SidebarItem item;
  final bool isActive;
  final bool isCollapsed;
  final VoidCallback onTap;

  const _SidebarMenuTile({
    required this.item,
    required this.isActive,
    required this.isCollapsed,
    required this.onTap,
  });

  @override
  State<_SidebarMenuTile> createState() => _SidebarMenuTileState();
}

class _SidebarMenuTileState extends State<_SidebarMenuTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isHighlighted = widget.isActive || _isHovered;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: widget.isCollapsed ? 12 : 14,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: widget.isActive
                  ? AppColors.sidebarActive
                  : _isHovered
                      ? AppColors.sidebarHover
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              boxShadow: widget.isActive || _isHovered
                  ? [
                      BoxShadow(
                        color: (widget.isActive
                                ? AppColors.sidebarActive
                                : AppColors.sidebarHover)
                            .withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [],
            ),
            child: Row(
              mainAxisAlignment: widget.isCollapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                AnimatedScale(
                  scale: _isHovered && !widget.isActive ? 1.08 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isHighlighted ? widget.item.activeIcon : widget.item.icon,
                    color: isHighlighted
                        ? AppColors.white
                        : AppColors.sidebarText,
                    size: 20,
                  ),
                ),
                if (!widget.isCollapsed) ...[
                  const SizedBox(width: 12),
                  AnimatedPadding(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.only(
                        left: _isHovered && !widget.isActive ? 4.0 : 0.0),
                    child: Text(
                      widget.item.label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight:
                            widget.isActive ? FontWeight.w600 : FontWeight.w500,
                        color: isHighlighted
                            ? AppColors.sidebarTextActive
                            : AppColors.sidebarText,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
