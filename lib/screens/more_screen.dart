import 'package:flutter/material.dart';
import '../theme/colors.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.blueGradient,
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(32, 24, 32, 16),
              child: Text(
                'Menú',
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                children: [
                  _buildMenuItem(Icons.person, 'Cuenta'),
                  _buildMenuItem(Icons.private_connectivity, 'Estaciones privadas'),
                  _buildMenuItem(Icons.language, 'Idioma'),
                  _buildMenuItem(Icons.help_outline, 'Soporte'),
                  _buildMenuItem(Icons.info_outline, 'Acerca de'),
                  _buildMenuItem(Icons.share, 'Recomendar'),
                  const SizedBox(height: 16),
                  _buildMenuItem(Icons.logout, 'Cerrar sesión', isDestructive: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, {bool isDestructive = false}) {
    final color = isDestructive ? AppColors.error : AppColors.textLight;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.separator.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: color, size: 22),
        title: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 16,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: color.withValues(alpha: 0.5),
          size: 20,
        ),
      ),
    );
  }
}
