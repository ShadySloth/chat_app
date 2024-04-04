import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_chat_app/profile/cubits/profiles_cubit.dart';
import 'package:my_chat_app/rooms/cubits/rooms_cubit.dart';
import 'package:my_chat_app/profile/models/profile.dart';
import 'package:my_chat_app/chat/pages/chat_page.dart';
import 'package:my_chat_app/profile/pages/register_page.dart';
import 'package:my_chat_app/utils/constants.dart';

import '../widgets/room_preview.dart';

/// Displays the list of chat threads
class RoomsPage extends StatelessWidget {
  const RoomsPage({Key? key}) : super(key: key);

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (context) => BlocProvider<RoomCubit>(
        create: (context) =>
        RoomCubit()..initializeRooms(context),
        child: const RoomsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rooms'),
        actions: [
          TextButton(
            onPressed: () async {
              await supabase.auth.signOut();
              Navigator.of(context).pushAndRemoveUntil(
                RegisterPage.route(),
                    (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
      body: BlocBuilder<RoomCubit, RoomState>(
        builder: (context, state) {
          if (state is RoomsLoading) {
            return preloader;
          } else if (state is RoomsLoaded) {
            final newUsers = state.newUsers;
            final rooms = state.rooms;
            return BlocBuilder<ProfilesCubit,
                ProfilesState>(
              builder: (context, state) {
                if (state is ProfilesLoaded) {
                  final profiles = state.profiles;
                  return Column(
                    children: [
                      _NewUsers(newUsers: newUsers),
                      Expanded(
                        child: room_preview(rooms: rooms, profiles: profiles),
                      ),
                    ],
                  );
                } else {
                  return preloader;
                }
              },
            );
          } else if (state is RoomsEmpty) {
            final newUsers = state.newUsers;
            return Column(
              children: [
                _NewUsers(newUsers: newUsers),
                const Expanded(
                  child: Center(
                    child: Text(
                        'Start a chat by tapping on available users'),
                  ),
                ),
              ],
            );
          } else if (state is RoomsError) {
            return Center(child: Text(state.message));
          }
          throw UnimplementedError();
        },
      ),
    );
  }
}

class _NewUsers extends StatelessWidget {
  const _NewUsers({
    Key? key,
    required this.newUsers,
  }) : super(key: key);

  final List<Profile> newUsers;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: newUsers
            .map<Widget>((user) => InkWell(
          onTap: () async {
            try {
              final roomId =
              await BlocProvider.of<RoomCubit>(
                  context)
                  .createRoom(user.id);
              Navigator.of(context)
                  .push(ChatPage.route(roomId));
            } catch (_) {
              context.showErrorSnackBar(
                  message:
                  'Failed creating a new room');
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 60,
              child: Column(
                children: [
                  CircleAvatar(
                    child: Text(user.username
                        .substring(0, 2)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.username,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ))
            .toList(),
      ),
    );
  }
}
