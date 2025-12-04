import 'package:flutter/material.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool _notificationForwarding = true;
  bool _wifiAutoConnect = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('通知设置', theme),
          _buildSectionCard(
            theme,
            children: [
              _buildSwitchTile(
                icon: Icons.notifications_active_outlined,
                title: '启用通知转发',
                subtitle: '允许将通知同步到其他设备',
                value: _notificationForwarding,
                onChanged: (value) =>
                    setState(() => _notificationForwarding = value),
              ),
              const Divider(height: 1),
              _buildSimpleTile(
                icon: Icons.apps_outlined,
                title: '应用筛选',
                subtitle: '选择哪些应用的通知需要转发',
              ),
              const Divider(height: 1),
              _buildSimpleTile(
                icon: Icons.tune,
                title: '关键词过滤',
                subtitle: '包含关键词的通知将不会转发',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('连接与设备', theme),
          _buildSectionCard(
            theme,
            children: [
              _buildSimpleTile(
                icon: Icons.computer_outlined,
                title: '我的电脑',
                subtitle: '已连接',
              ),
              const Divider(height: 1),
              _buildSwitchTile(
                icon: Icons.wifi,
                title: 'Wi-Fi下自动连接',
                subtitle: '在可信网络下开启自动连接',
                value: _wifiAutoConnect,
                onChanged: (value) =>
                    setState(() => _wifiAutoConnect = value),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildSectionCard(ThemeData theme, {required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.only(top: 8),
      elevation: 0,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSimpleTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }
}
