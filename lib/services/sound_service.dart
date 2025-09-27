import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart'; // ✅ 추가
import '../providers/app_data_provider.dart'; // ✅ 추가
import '../core/navigation_service.dart';

class SoundService {
  static final _bgmPlayer = AudioPlayer(playerId: "bgm");

  // 🎵 BGM 전용 AudioContext
  static final _bgmContext = AudioContext(
    iOS: AudioContextIOS(
      category: AVAudioSessionCategory.playback,
      options: {AVAudioSessionOptions.mixWithOthers}, // ✅ Set 사용
    ),
    android: AudioContextAndroid(
      isSpeakerphoneOn: false,
      stayAwake: false,
      contentType: AndroidContentType.music,
      usageType: AndroidUsageType.media,
      audioFocus: AndroidAudioFocus.none,
    ),
  );

  // 🔊 효과음 전용 AudioContext
  static final _effectContext = AudioContext(
    iOS: AudioContextIOS(
      category: AVAudioSessionCategory.ambient,
    ),
    android: AudioContextAndroid(
      contentType: AndroidContentType.sonification,
      usageType: AndroidUsageType.assistanceSonification,
      audioFocus: AndroidAudioFocus.none,
    ),
  );

  // ✅ 배경음악 (루프)
  static Future<void> playBgm(String file, {bool force = false}) async {
    final context = navigatorKey.currentContext;
    if (!force && context != null) {
      final enabled = context.read<AppDataProvider>().bgmEnabled;
      if (!enabled) return;
    }
    await _bgmPlayer.stop();
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.setAudioContext(_bgmContext);
    await _bgmPlayer.play(AssetSource("sounds/$file"), volume: 0.5);
  }
  static Future<void> stopBgm() async {
    await _bgmPlayer.stop();
  }

  // ✅ 효과음 (BGM 끊기지 않음)
  static Future<void> _playEffect(String file, {bool force = false}) async {
    final context = navigatorKey.currentContext;
    if (!force && context != null) {
      final enabled = context.read<AppDataProvider>().effectEnabled;
      if (!enabled) return;
    }
    final player = AudioPlayer();
    await player.setReleaseMode(ReleaseMode.stop);
    await player.play(
      AssetSource("sounds/$file"),
      volume: 1.0,
    );
    Future.delayed(const Duration(seconds: 2), () {
      player.dispose();
    });
  }

  // 🎵 호출 메서드
  static Future<void> playBomb() => _playEffect("bomb.mp3");
  static Future<void> playTap() => _playEffect("tap.mp3");
  static Future<void> playFlag() => _playEffect("flag.mp3");
  static Future<void> playVictory() => _playEffect("victory.mp3");
  static Future<void> playLose() => _playEffect("lose.mp3");
}