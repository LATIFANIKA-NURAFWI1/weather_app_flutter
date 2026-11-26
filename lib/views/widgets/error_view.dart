import 'dart:ui';
import 'package:flutter/material.dart';

/// Error View bergaya glassmorphism dengan aksen merah dan tombol Coba Lagi
class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(127, 29, 29, 0.25),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color.fromRGBO(252, 165, 165, 0.30),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(248, 113, 113, 0.20),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color.fromRGBO(252, 165, 165, 0.30),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.error_outline_rounded,
                      size: 20,
                      color: Color(0xFFFECACA),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Gagal memuat data',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          message,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color.fromRGBO(255, 255, 255, 0.65),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (onRetry != null) ...[
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: onRetry,
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(255, 255, 255, 0.20),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: const Color.fromRGBO(255, 255, 255, 0.40),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.refresh_rounded,
                              size: 14,
                              color: Color(0xFFBAE6FD),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Coba Lagi',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
