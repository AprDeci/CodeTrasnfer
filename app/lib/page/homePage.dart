import 'package:code_transfer/bloc/cubit/key_pair_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('主页'),
        centerTitle: false,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  children: [
                    Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: theme.cardColor,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: BlocBuilder<KeyPairCubit, KeyPairState>(
                  builder: (context, state) {
                    final isLoading = state.status == KeyPairStatus.loading ||
                        state.status == KeyPairStatus.initial;
                    final hasError = state.status == KeyPairStatus.failure;
                    final hasKey =
                        state.status == KeyPairStatus.success && state.keyPair != null;

                    final displayText = () {
                      if (isLoading) {
                        return '正在生成密钥...';
                      }
                      if (hasError) {
                        return '生成失败：${state.errorMessage ?? ''}';
                      }
                      if (hasKey) {
                        return state.keyPair!.publicKey;
                      }
                      return '暂无密钥';
                    }();

                    return Column(
                      children: [
                        Text('本机设备ID', style: theme.textTheme.labelMedium),
                        const SizedBox(height: 8),
                        SelectableText(
                          displayText,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.tonalIcon(
                          icon: const Icon(Icons.copy),
                          label: const Text('复制'),
                          onPressed: hasKey
                              ? () {
                                  final key = state.keyPair!.publicKey;
                                  Clipboard.setData(ClipboardData(text: key));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('已复制到剪贴板')),
                                  );
                                }
                              : null,
                        )
                      ],
                    );
                  },
                ),
              ),
            ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('局域网设备', style: theme.textTheme.titleLarge),
                        FilledButton.icon(
                          icon: const Icon(Icons.qr_code_scanner, size: 16),
                          label: const Text('扫描'),
                          onPressed: () {},
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDeviceItem(
                      context,
                      icon: Icons.desktop_windows,
                      name: 'My-Desktop-PC',
                      status: '已连接',
                      isConnected: true,
                    ),
                    const SizedBox(height: 8),
                    _buildDeviceItem(
                      context,
                      icon: Icons.laptop_mac,
                      name: 'John\'s MacBook',
                      status: '点击以连接',
                    ),
                    const SizedBox(height: 8),
                    _buildDeviceItem(
                      context,
                      icon: Icons.laptop_windows,
                      name: 'Work-Laptop',
                      status: '点击以连接',
                    ),
                  ],
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24.0, top: 16.0),
                  child: Text(
                    '请确保手机和电脑连接到同一Wi-Fi网络',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceItem(
    BuildContext context,
      {
    required IconData icon,
    required String name,
    required String status,
    bool isConnected = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: theme.cardColor,
      child: ListTile(
        leading: Icon(icon),
        title: Text(name),
        subtitle: Text(status),
        trailing: Icon(
          isConnected ? Icons.link : CupertinoIcons.right_chevron,
          color: isConnected ? colorScheme.primary : theme.disabledColor,
        ),
        onTap: () {},
      ),
    );
  }
}
