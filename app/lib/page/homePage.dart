import 'package:code_transfer/bloc/discovery/discovery_bloc.dart';
import 'package:code_transfer/bloc/server/server_bloc.dart';
import 'package:code_transfer/bloc/sync/sync_bloc.dart';
import 'package:code_transfer/core/models/core_device.dart';
import 'package:code_transfer/core/models/device_type.dart';
import 'package:code_transfer/core/models/incoming_payload.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<SyncBloc, SyncState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == SyncStatus.idle) {
          return;
        }
        final messenger = ScaffoldMessenger.of(context);
        if (state.status == SyncStatus.success) {
          messenger.showSnackBar(
            SnackBar(
              content: Text('已发送到 ${state.currentTargetIp ?? '目标设备'}'),
            ),
          );
        } else if (state.status == SyncStatus.failure &&
            state.errorMessage != null) {
          messenger.showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('主页'),
          centerTitle: false,
          elevation: 0,
          backgroundColor: theme.scaffoldBackgroundColor,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                context.go('/setting');
              },
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
                      _buildDiscoverySection(context),
                      const SizedBox(height: 24),
                      _buildSyncSection(context),
                      const SizedBox(height: 24),
                      _buildIncomingSection(context),
                    ],
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24.0, top: 16.0),
                    child: Text(
                      '请确保手机和电脑连接到同一 Wi-Fi 网络',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDiscoverySection(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<DiscoveryBloc, DiscoveryState>(
      builder: (context, state) {
        final devices = state.devices;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('局域网设备', style: theme.textTheme.titleLarge),
                FilledButton.icon(
                  icon: const Icon(Icons.radar, size: 16),
                  label: Text(state.isScanning ? '扫描中...' : '重新扫描'),
                  onPressed: () {
                    context.read<DiscoveryBloc>().add(const DiscoveryStarted());
                  },
                ),
              ],
            ),
            if (state.errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                state.errorMessage!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              state.currentTargetIp == null
                  ? '尚未匹配到目标设备'
                  : '当前目标：${state.currentTargetIp}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            if (devices.isEmpty)
              _buildEmptyCard(
                context,
                message: state.isScanning ? '正在扫描...' : '暂无设备',
              )
            else
              Column(
                children: [
                  for (final device in devices) ...[
                    _buildDeviceItem(
                      context,
                      device: device,
                      isConnected: device.ip == state.currentTargetIp,
                    ),
                    const SizedBox(height: 8),
                  ]
                ],
              ),
          ],
        );
      },
    );
  }

  Widget _buildSyncSection(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<SyncBloc, SyncState>(
      builder: (context, state) {
        final isSending = state.status == SyncStatus.sending;
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('自动同步', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  state.hasTarget
                      ? '目标 IP：${state.currentTargetIp}'
                      : '等待自动配对...',
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  icon: const Icon(Icons.send),
                  label: Text(isSending ? '发送中...' : '发送测试'),
                  onPressed: state.hasTarget && !isSending
                      ? () => context
                          .read<SyncBloc>()
                          .add(const SyncSendTestRequested())
                      : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIncomingSection(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<ServerBloc, ServerState>(
      builder: (context, state) {
        final messages = state.messages;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('最近消息', style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              state.isRunning
                  ? '监听端口 ${state.port}'
                  : '服务未启动，等待 BLoC 拉起',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            if (messages.isEmpty)
              _buildEmptyCard(context, message: '暂未收到任何消息')
            else
              Column(
                children: [
                  for (final message in messages.take(5)) ...[
                    _buildMessageItem(context, message),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyCard(
    BuildContext context, {
    required String message,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Text(message, style: theme.textTheme.bodyMedium),
        ),
      ),
    );
  }

  Widget _buildDeviceItem(
    BuildContext context, {
    required CoreDevice device,
    required bool isConnected,
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
        leading: Icon(_iconForDevice(device.deviceType)),
        title: Text(device.alias),
        subtitle: Text('${device.ip} • ${device.deviceType.name}'),
        trailing: Icon(
          isConnected ? Icons.link : CupertinoIcons.link,
          color: isConnected ? colorScheme.primary : theme.disabledColor,
        ),
        onTap: () {
          context.read<DiscoveryBloc>().add(DiscoveryTargetSelected(device));
        },
      ),
    );
  }

  Widget _buildMessageItem(
    BuildContext context,
    IncomingPayload message,
  ) {
    final theme = Theme.of(context);
    final subtitle =
        message.deviceName == null ? message.sourceIp : message.deviceName!;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subtitle,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              message.preview,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.receivedAt),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForDevice(DeviceType type) {
    switch (type) {
      case DeviceType.desktop:
      case DeviceType.server:
        return Icons.desktop_windows;
      case DeviceType.mobile:
        return Icons.smartphone;
      case DeviceType.headless:
      case DeviceType.web:
        return Icons.devices_other;
    }
  }

  String _formatTime(DateTime time) {
    final local = time.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
