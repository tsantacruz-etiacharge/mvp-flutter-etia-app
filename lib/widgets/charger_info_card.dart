import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../data/mock_data.dart';

class ChargerInfoCard extends StatelessWidget {
  final MockCharger charger;
  final VoidCallback onClose;

  const ChargerInfoCard({
    super.key,
    required this.charger,
    required this.onClose,
  });

  String get _statusText {
    switch (charger.status) {
      case ChargerStatus.available:
        return 'Disponible';
      case ChargerStatus.occupied:
        return 'Ocupado';
      case ChargerStatus.unavailable:
        return 'No disponible';
    }
  }

  Color get _statusColor {
    switch (charger.status) {
      case ChargerStatus.available:
        return AppColors.success;
      case ChargerStatus.occupied:
        return AppColors.warning;
      case ChargerStatus.unavailable:
        return AppColors.highlight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 100,
      left: 16,
      right: 16,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        color: AppColors.card,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.ev_station,
                      color: _statusColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          charger.name,
                          style: const TextStyle(
                            color: AppColors.textLight,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          charger.address,
                          style: TextStyle(
                            color: AppColors.textLight.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: onClose,
                    child: Icon(
                      Icons.close,
                      color: AppColors.textLight.withValues(alpha: 0.6),
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(
                    Icons.bolt,
                    '${charger.powerKw} kW',
                    AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    Icons.circle,
                    _statusText,
                    _statusColor,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.directions, size: 18),
                      label: const Text('Direcciones'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.location_on, size: 18),
                      label: const Text('Ubicación'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textLight,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
