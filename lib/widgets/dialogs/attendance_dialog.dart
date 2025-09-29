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
                  // 텍스트 컨테이너
                  Container(
                    height: 80,
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage("assets/images/dialog/attendance_header.png"),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  // GridView 컨테이너
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage("assets/images/dialog/attendance_body.png"),
                        fit: BoxFit.fill,
                      ),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: attendance.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 6,
                        crossAxisSpacing: 6,
                      ),
                      itemBuilder: (context, index) {
                        final isClaimed = attendance[index];
                        final day = index + 1;
                        final enabled = index == nextIndex && !isClaimed && lastDate != today;

                        return GestureDetector(
                          onTap: () async {
                            if (enabled) {
                              await context.read<AppDataProvider>().markAttendance();
                              onClaim(day);
                              String rewardText;
                              if (day == 1 || day == 3 || day == 5) {
                                rewardText = "골드 100 지급";
                              } else if (day == 2 || day == 4 || day == 6) {
                                rewardText = "보석 20 지급";
                              } else if (day == 7) {
                                rewardText = "골드 200 + 보석 40 지급";
                              } else {
                                rewardText = "보상 없음";
                              }
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                      return AlertDialog(
                                      title: const Text("출석 보상 🎁"),
                                      content: Text("$day일차 출석 완료!\n보상: $rewardText"),
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
                              child: Image.asset(
                                day == 7
                                    ? "assets/images/dialog/attendance_gold_gem.png"
                                    : (day == 1 || day == 3 || day == 5)
                                        ? "assets/images/dialog/attendance_gold.png"
                                        : "assets/images/dialog/attendance_gem.png",
                                width: 48,
                                height: 48,
                                color: isClaimed ? Colors.grey : null,
                                colorBlendMode: isClaimed ? BlendMode.saturation : null,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              confirmText: "닫기",
              onConfirm: () => Navigator.of(context).pop(),
              backgroundColor: Colors.transparent, // ✅ 투명 지정
            );
          },
        );
      },
    );
  }
}