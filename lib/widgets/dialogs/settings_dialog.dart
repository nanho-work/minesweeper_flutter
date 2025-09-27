import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_data_provider.dart';
import 'game_dialog.dart';

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return GameDialog(
      title: "설정",
      content: Column( // ✅ Widget 전달
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SwitchListTile(
            title: const Text('배경음'),
            value: context.watch<AppDataProvider>().bgmEnabled,
            onChanged: (val) {
              context.read<AppDataProvider>().toggleBgm(val);
            },
            activeColor: Colors.orange,
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            title: const Text('효과음'),
            value: context.watch<AppDataProvider>().effectEnabled,
            onChanged: (val) {
              context.read<AppDataProvider>().toggleEffect(val);
            },
            activeColor: Colors.orange,
            contentPadding: EdgeInsets.zero,
          ),
          ListTile(
            title: const Text('게임 데이터'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: 게임 데이터 관리 팝업 추가
            },
            contentPadding: EdgeInsets.zero,
          ),
          ListTile(
            title: const Text('기타 정보'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: 정보 팝업 추가
            },
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
      confirmText: "닫기",
      onConfirm: () => Navigator.of(context).pop(),
    );
  }
}