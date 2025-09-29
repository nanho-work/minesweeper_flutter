import 'package:flutter/material.dart';
import '../dialogs/attendance_dialog.dart';

class SidebarWidget extends StatelessWidget {
  final bool isRight; // true면 오른쪽 사이드바, false면 왼쪽
  final List<bool> attendance;

  const SidebarWidget({
    super.key,
    this.isRight = true,
    required this.attendance,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isRight ? Alignment.topRight : Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // 출석체크 버튼
            IconButton(
              icon: Image.asset(
                'assets/images/day_check.png',
                width: 60,
                height: 60,
              ),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (_) => AttendanceDialog(
                        onClaim: (day) {
                        // ✅ 원하는 보상 처리
                        },
                    ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}