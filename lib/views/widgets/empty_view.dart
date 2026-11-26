import 'dart:ui';
import 'package:flutter/material.dart';

/// Empty View bergaya glassmorphism sesuai mockup
class EmptyView extends StatelessWidget {
  final String message;
  final String? submessage;
  final IconData icon;

  const EmptyView({
    super.key,
    required this.message,
    this.submessage,
    this.icon = Icons.cloud_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(255, 255, 255, 0.10),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color.fromRGBO(255, 255, 255, 0.16),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(255, 255, 255, 0.10),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color.fromRGBO(255, 255, 255, 0.15),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Icon(icon, size: 24, color: const Color(0xFFBAE6FD)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          message,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color.fromRGBO(255, 255, 255, 0.95),
                          ),
                        ),
                        if (submessage != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            submessage!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color.fromRGBO(255, 255, 255, 0.60),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
