import '../../../../core/composer.dart';
import '../../../../core/registery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import '../../bloc/bloc.dart';

class AddAttachmentButton extends StatelessWidget {
  const AddAttachmentButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final actions = MessageProviderRegistry.instance.composerActions;
    return PopupMenuButton<ComposerAction>(
      padding: EdgeInsets.zero,
      offset: const Offset(0, -120),
      position: PopupMenuPosition.over,
      popUpAnimationStyle: AnimationStyle.noAnimation,
      constraints: const BoxConstraints(
        minWidth: 44,
        minHeight: 44,
      ),
      icon: Icon(
        Iconsax.add,
        size: 26,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      itemBuilder: (BuildContext context) => actions
          .map((a) => PopupMenuItem<ComposerAction>(
                value: a,
                child: Row(
                  children: [
                    Icon(
                      a.icon,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      a.title,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
      onSelected: (ComposerAction action) async {
        final results = await action.onPick(context);
        if (!context.mounted) return;
        context
            .read<MessagesBloc>()
            .add(MessagesComposerResultsPicked(results));
      },
    );
  }
}
