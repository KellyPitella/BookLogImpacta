import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../theme/theme_controller.dart';

Future<void> showAppSettingsMenu(BuildContext context) async {
  final authService = AuthService();

  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) {
      final colorScheme = Theme.of(sheetContext).colorScheme;

      return ValueListenableBuilder<ThemeMode>(
        valueListenable: ThemeController.themeMode,
        builder: (context, themeMode, _) {
          final isDark = themeMode == ThemeMode.dark;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(
                      isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                      color: colorScheme.primary,
                    ),
                    title: const Text('Tema'),
                    subtitle: Text(isDark ? 'Escuro' : 'Claro'),
                    trailing: Switch(
                      value: isDark,
                      onChanged: (value) {
                        ThemeController.setDarkMode(value);
                      },
                    ),
                    iconColor: colorScheme.primary,
                    textColor: colorScheme.onSurface,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.info_outline, color: colorScheme.primary),
                    title: const Text('Sobre o BookLog'),
                    iconColor: colorScheme.primary,
                    textColor: colorScheme.onSurface,
                    onTap: () => Navigator.of(sheetContext).pop(),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.logout_rounded, color: colorScheme.error),
                    title: const Text('Sair da conta'),
                    subtitle: const Text('Encerrar sessão atual'),
                    iconColor: colorScheme.error,
                    textColor: colorScheme.onSurface,
                    onTap: () async {
                      Navigator.of(sheetContext).pop();
                      await authService.logout();

                      if (context.mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/login',
                          (route) => false,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
