import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/preferences_service.dart';

class SettingsScreen extends StatefulWidget {
  final PreferencesService prefsService;

  const SettingsScreen({
    super.key,
    required this.prefsService,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool soundEnabled;
  late bool vibrationEnabled;

  @override
  void initState() {
    super.initState();
    soundEnabled = widget.prefsService.isSoundEnabled();
    vibrationEnabled = widget.prefsService.isVibrationEnabled();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text('سیٹنگز (Settings)', style: TextStyle(fontFamily: 'UrduNastaliq')),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: SwitchListTile(
                  activeThumbColor: Colors.amber,
                  title: const Text(
                    'آواز (Sound Effects)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: 'UrduNastaliq',
                    ),
                  ),
                  subtitle: const Text(
                    'جوابات کی آوازیں آن یا آف کریں',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                  secondary: const Icon(Icons.volume_up, color: Colors.amber),
                  value: soundEnabled,
                  onChanged: (val) async {
                    setState(() {
                      soundEnabled = val;
                    });
                    await widget.prefsService.setSoundEnabled(val);
                  },
                ),
              ),

              Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: SwitchListTile(
                  activeThumbColor: Colors.amber,
                  title: const Text(
                    'وائبریشن (Vibration)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: 'UrduNastaliq',
                    ),
                  ),
                  subtitle: const Text(
                    'غلط جواب پر وائبریشن کا احساس',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                  secondary: const Icon(Icons.vibration, color: Colors.amber),
                  value: vibrationEnabled,
                  onChanged: (val) async {
                    setState(() {
                      vibrationEnabled = val;
                    });
                    await widget.prefsService.setVibrationEnabled(val);
                  },
                ),
              ),

              Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  leading: const Icon(Icons.rule, color: Colors.amber),
                  title: const Text(
                    'کھیل کے اصول (Game Rules)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: 'UrduNastaliq',
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
                  onTap: _showGameRulesDialog,
                ),
              ),

              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  leading: const Icon(Icons.privacy_tip, color: Colors.amber),
                  title: const Text(
                    'پرائیویسی پالیسی (Privacy Policy)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: 'UrduNastaliq',
                    ),
                  ),
                  trailing: const Icon(Icons.open_in_new, color: Colors.white54, size: 16),
                  onTap: _launchPrivacyPolicy,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchPrivacyPolicy() async {
    final Uri url = Uri.parse('https://zeeustudios.github.io/urdu-alfaz-privacy');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('پرائیویسی پالیسی کا لنک کھولنے میں ناکامی')),
        );
      }
    }
  }

  void _showGameRulesDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '📜 کھیل کے قوانین',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.amber,
            fontSize: 22,
            fontFamily: 'UrduNastaliq',
          ),
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '1. ہر صحیح جواب پر +10 سکے ملیں گے۔\n'
                '2. ہر غلط جواب یا ٹائم ختم ہونے پر -1 زندگی ہوگی۔\n'
                '3. ہر سوال کے لیے 15 سیکنڈ کا وقت ہوگا۔\n'
                '4. کل 3 لیولز ہیں: آسان، درمیانہ، اور مشکل۔\n'
                '5. 1000 سکے جمع کرنے پر مشکل لیول ان لاک ہوگا۔\n'
                '6. روزانہ گیم میں آنے پر 20 سکے انعام ملیں گے۔\n'
                '7. 7 دن مسلسل کھیلنے پر 100 سکے بونس ملیں گے۔',
                style: TextStyle(color: Colors.white, fontSize: 16, height: 1.8),
              ),
            ],
          ),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('سمجھ گیا', style: TextStyle(color: Colors.black)),
            ),
          ),
        ],
      ),
    );
  }
}
