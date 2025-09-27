import 'package:provider/provider.dart';
import '../../providers/app_data_provider.dart';
import 'package:flutter/material.dart';
import 'game_dialog.dart';
import '../game_button.dart';

class AttendanceDialog extends StatelessWidget {
  final void Function(int day) onClaim;

  const AttendanceDialog({
    super.key,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppDataProvider>(
      builder: (context, appData, _) {
        return FutureBuilder<List<bool>>(
          future: appData.getAttendance(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final attendance = snapshot.data!;
            final today = DateTime.now().toIso8601String().substring(0, 10);
            final lastDate = context.read<AppDataProvider>().lastAttendanceDate; // 새로 저장된 값 불러오기
            final nextIndex = attendance.indexOf(false);

            

            return GameDialog(
              title: "출석 체크",
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "오늘도 접속해주셔서 감사합니다!\n보상을 받아가세요 🎁",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: attendance.length + 1,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 6,
                      crossAxisSpacing: 6,
                    ),
                    itemBuilder: (context, index) {
                      if (index == attendance.length) {
                        final allClaimed = attendance.every((d) => d);
                        return Container(
                          decoration: BoxDecoration(
                            color: allClaimed ? Colors.green[100] : Colors.grey[300],
                            border: Border.all(
                              color: allClaimed ? Colors.green : Colors.grey,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              "출석성공",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: allClaimed ? Colors.green : Colors.grey,
                              ),
                            ),
                          ),
                        );
                      }

                      final isClaimed = attendance[index];
                      final day = index + 1;
                      final enabled = index == nextIndex && !isClaimed && lastDate != today;

                      return GestureDetector(
                        onTap: () async {
                          if (enabled) {
                            await context.read<AppDataProvider>().markAttendance();
                            onClaim(day);
                            showDialog(
                                context: context,
                                builder: (context) {
                                    return AlertDialog(
                                    title: const Text("출석 보상 🎁"),
                                    content: Text("$day일차 출석 완료!\n보상: 골드 100 지급"),
                                    actions: [
                                      GameButton(
                                        text: "확인",
                                        onPressed: () => Navigator.of(context).pop(),
                                        width: 80,
                                        height: 36,
                                      ),
                                    ],
                                    );
                                },
                            );
                          }
                        },
                        child: Opacity(
                          opacity: enabled ? 1.0 : 0.4,
                          child: Container(
                            decoration: BoxDecoration(
                              color: isClaimed ? Colors.grey[300] : Colors.orange[100],
                              border: Border.all(
                                color: isClaimed ? Colors.grey : Colors.orange,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.card_giftcard,
                                  color: isClaimed ? Colors.grey : Colors.orange,
                                  size: 20,
                                ),
                                Text(
                                  "$day일",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isClaimed ? Colors.grey : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              confirmText: "닫기",
              onConfirm: () => Navigator.of(context).pop(),
            );
          },
        );
      },
    );
  }
}