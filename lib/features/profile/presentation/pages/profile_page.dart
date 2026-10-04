import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/localization/localization_context.dart';
import '../../../../core/widgets/record_form.dart';
import '../../../auth/presentation/controllers/session_controller.dart';
import '../../domain/entities/local_profile.dart';
import '../controllers/profile_controller.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionControllerProvider).user;
    final profile = ref.watch(localProfileProvider);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.profile)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(context.l10n.localProfile),
          ListTile(
            title: Text(context.l10n.fullName),
            subtitle: Text(profile.fullName),
          ),
          ListTile(
            title: Text(context.l10n.email),
            subtitle: Text(user?.email ?? ''),
          ),
          ListTile(
            title: Text(context.l10n.workerRole),
            subtitle: Text(user?.role.apiValue ?? ''),
          ),
          ListTile(
            title: Text(context.l10n.phone),
            subtitle: Text(profile.phone),
          ),
          ListTile(
            title: Text(context.l10n.company),
            subtitle: Text(profile.company),
          ),
          FilledButton(
            onPressed: user == null
                ? null
                : () => Navigator.push<void>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecordForm(
                        title: context.l10n.profile,
                        fields: [
                          RecordField(
                            'fullName',
                            context.l10n.fullName,
                            initial: profile.fullName,
                            maxLength: 100,
                          ),
                          RecordField(
                            'phone',
                            context.l10n.phone,
                            initial: profile.phone,
                            maxLength: 30,
                            required: false,
                          ),
                          RecordField(
                            'company',
                            context.l10n.company,
                            initial: profile.company,
                            required: false,
                          ),
                        ],
                        onSave: (v) async {
                          await ref
                              .read(profileRepositoryProvider)
                              .save(
                                user.id,
                                LocalProfile(
                                  fullName: v['fullName']!,
                                  phone: v['phone']!,
                                  company: v['company']!,
                                ),
                              );
                          ref.invalidate(localProfileProvider);
                        },
                      ),
                    ),
                  ),
            child: Text(context.l10n.edit),
          ),
        ],
      ),
    );
  }
}
