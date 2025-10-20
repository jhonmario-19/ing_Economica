import 'package:flutter/material.dart';
import 'package:billetera/constants/app_colors.dart';
import 'package:billetera/constants/app_styles.dart';

class CommonWidgets {
  
  // ===== TARJETA DE BALANCE PRINCIPAL =====
  static Widget buildBalanceCard({
    required String balance,
    required String title,
    String? subtitle,
    Widget? actionButton,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: AppStyles.balanceCardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppStyles.subheadingMedium.copyWith(
                          color: AppColors.textOnPrimary.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        balance,
                        style: AppStyles.balanceLarge,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: AppStyles.bodySmall.copyWith(
                            color: AppColors.textOnPrimary.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (actionButton != null) actionButton,
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===== BOTÓN FLOTANTE DE ACCIÓN =====
  static Widget buildFloatingActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    String? tooltip,
    Color? backgroundColor,
  }) {
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: backgroundColor ?? AppColors.accentColor,
      foregroundColor: AppColors.textOnPrimary,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, size: 24),
    );
  }

  // ===== AVATAR DE USUARIO =====
  static Widget buildUserAvatar({
    required String name,
    String? imageUrl,
    double size = 40,
    Color? backgroundColor,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.accentColor,
        borderRadius: BorderRadius.circular(size / 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(size / 2),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildInitialsAvatar(name, size);
                },
              ),
            )
          : _buildInitialsAvatar(name, size),
    );
  }

  static Widget _buildInitialsAvatar(String name, double size) {
    final initials = name.isNotEmpty
        ? name.split(' ').take(2).map((n) => n[0].toUpperCase()).join()
        : '?';
    
    return Center(
      child: Text(
        initials,
        style: AppStyles.getCustomTextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.w600,
          color: AppColors.textOnPrimary,
        ),
      ),
    );
  }

  // ===== NOTIFICACIÓN/SNACKBAR PERSONALIZADA =====
  static SnackBar buildCustomSnackBar({
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration? duration,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (type) {
      case SnackBarType.success:
        backgroundColor = AppColors.successColor;
        textColor = AppColors.textOnPrimary;
        icon = Icons.check_circle_outline;
        break;
      case SnackBarType.error:
        backgroundColor = AppColors.errorColor;
        textColor = AppColors.textOnPrimary;
        icon = Icons.error_outline;
        break;
      case SnackBarType.warning:
        backgroundColor = AppColors.warningColor;
        textColor = AppColors.textPrimaryColor;
        icon = Icons.warning_amber_outlined;
        break;
      case SnackBarType.info:
      default:
        backgroundColor = AppColors.primaryColor;
        textColor = AppColors.textOnPrimary;
        icon = Icons.info_outline;
    }

    return SnackBar(
      content: Row(
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppStyles.bodyMedium.copyWith(color: textColor),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      duration: duration ?? const Duration(seconds: 4),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.radiusM),
      ),
      margin: const EdgeInsets.all(AppStyles.spacingM),
      action: onAction != null && actionLabel != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: textColor,
              onPressed: onAction,
            )
          : null,
    );
  }

  // ===== SHIMMER LOADING =====
  static Widget buildShimmerCard({
    double? height,
    double? width,
    BorderRadius? borderRadius,
  }) {
    return Container(
      height: height ?? 80,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: borderRadius ?? BorderRadius.circular(AppStyles.radiusM),
      ),
      child: const _ShimmerWidget(),
    );
  }

  // ===== MODAL BOTTOM SHEET PERSONALIZADO =====
  static void showCustomBottomSheet({
    required BuildContext context,
    required Widget child,
    String? title,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    showModalBottomSheet(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppStyles.radiusXL),
            topRight: Radius.circular(AppStyles.radiusXL),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (enableDrag)
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            if (title != null) ...[
              const SizedBox(height: 16),
              Text(
                title,
                style: AppStyles.headingSmall,
              ),
              const Divider(color: AppColors.dividerColor),
            ],
            child,
          ],
        ),
      ),
    );
  }

  // ===== LOADING INDICATOR =====
  static Widget buildLoadingIndicator({
    String? message,
    Color? color,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: color ?? AppColors.accentColor,
            strokeWidth: 3,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message,
              style: AppStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  // ===== BOTÓN DE ACCIÓN RÁPIDA =====
  static Widget buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
    Color? backgroundColor,
    bool isActive = false,
  }) {
    final bgColor = backgroundColor ?? 
        (isActive ? AppColors.accentColor.withOpacity(0.1) : AppColors.cardBackground);
    final iconColorFinal = iconColor ?? 
        (isActive ? AppColors.accentColor : AppColors.textSecondaryColor);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppStyles.radiusM),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppStyles.radiusM),
          border: Border.all(
            color: isActive ? AppColors.accentColor : AppColors.dividerColor,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColorFinal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppStyles.radiusS),
              ),
              child: Icon(
                icon,
                color: iconColorFinal,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppStyles.bodySmall.copyWith(
                fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                color: isActive ? AppColors.accentColor : AppColors.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== ITEM DE TRANSACCIÓN =====
  static Widget buildTransactionItem({
    required String title,
    required String subtitle,
    required String amount,
    required IconData icon,
    Color? iconBackgroundColor,
    Color? amountColor,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    final iconBgColor = iconBackgroundColor ?? AppColors.cardBackground;
    final amountTextColor = amountColor ?? AppColors.textPrimaryColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppStyles.radiusM),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppStyles.simpleCardDecoration,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(AppStyles.radiusS),
              ),
              child: Icon(
                icon,
                color: AppColors.textSecondaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppStyles.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: AppStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: amountTextColor,
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(height: 2),
                  trailing,
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===== SECCIÓN CON TÍTULO =====
  static Widget buildSectionHeader({
    required String title,
    String? subtitle,
    Widget? action,
    VoidCallback? onActionTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppStyles.spacingM),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppStyles.headingSmall,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppStyles.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          if (action != null)
            GestureDetector(
              onTap: onActionTap,
              child: action,
            ),
        ],
      ),
    );
  }

  // ===== ESTADO VACÍO =====
  static Widget buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppStyles.radiusXL),
              ),
              child: Icon(
                icon,
                size: 48,
                color: AppColors.textTertiaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: AppStyles.headingSmall.copyWith(
                color: AppColors.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 24),
              action,
            ],
          ],
        ),
      ),
    );
  }

  // ===== INDICADOR DE ESTADO =====
  static Widget buildStatusIndicator({
    required String status,
    Color? backgroundColor,
    Color? textColor,
  }) {
    Color bgColor;
    Color txtColor;

    switch (status.toLowerCase()) {
      case 'activo':
      case 'completado':
      case 'éxito':
        bgColor = AppColors.successLight;
        txtColor = AppColors.successColor;
        break;
      case 'pendiente':
      case 'proceso':
        bgColor = AppColors.warningLight;
        txtColor = AppColors.warningColor;
        break;
      case 'cancelado':
      case 'error':
      case 'fallido':
        bgColor = AppColors.errorLight;
        txtColor = AppColors.errorColor;
        break;
      case 'información':
      case 'info':
        bgColor = AppColors.infoLight;
        txtColor = AppColors.infoColor;
        break;
      default:
        bgColor = AppColors.cardBackground;
        txtColor = AppColors.textSecondaryColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: AppStyles.bodySmall.copyWith(
          color: textColor ?? txtColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ===== CONTENEDOR DE INFORMACIÓN =====
  static Widget buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    String? subtitle,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppStyles.radiusM),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppStyles.primaryCardDecoration,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.accentColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppStyles.radiusS),
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppColors.accentColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppStyles.bodySmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: AppStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppStyles.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== DIVISOR CON TEXTO =====
  static Widget buildDividerWithText(String text) {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            color: AppColors.dividerColor,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: AppStyles.bodySmall,
          ),
        ),
        const Expanded(
          child: Divider(
            color: AppColors.dividerColor,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  // ===== BOTÓN PERSONALIZADO =====
  static Widget buildCustomButton({
    required String text,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    bool isOutlined = false,
    bool isLoading = false,
    double? width,
    EdgeInsetsGeometry? padding,
  }) {
    final bgColor = backgroundColor ?? AppColors.accentColor;
    final txtColor = textColor ?? AppColors.textOnPrimary;
    final buttonPadding = padding ?? const EdgeInsets.symmetric(vertical: 16, horizontal: 24);

    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined ? Colors.transparent : bgColor,
          foregroundColor: isOutlined ? bgColor : txtColor,
          padding: buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.radiusM),
            side: isOutlined ? BorderSide(color: bgColor, width: 1.5) : BorderSide.none,
          ),
          elevation: isOutlined ? 0 : 2,
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: isOutlined ? bgColor : txtColor,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: AppStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isOutlined ? bgColor : txtColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ===== ENUMS Y CLASES AUXILIARES =====

enum SnackBarType { success, error, warning, info }

class _ShimmerWidget extends StatefulWidget {
  const _ShimmerWidget();

  @override
  _ShimmerWidgetState createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<_ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: const Alignment(-1.0, -0.3),
              end: const Alignment(1.0, 0.3),
              colors: [
                AppColors.cardBackground,
                AppColors.dividerColor,
                AppColors.cardBackground,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }
}