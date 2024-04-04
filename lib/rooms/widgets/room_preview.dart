import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart';

import '../../chat/pages/chat_page.dart';
import '../../profile/models/profile.dart';
import '../../utils/constants.dart';
import '../models/room.dart';

class room_preview extends StatelessWidget {
  const room_preview({
    super.key,
    required this.rooms,
    required this.profiles,
  });

  final List<Room> rooms;
  final Map<String, Profile?> profiles;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: rooms.length,
      itemBuilder: (context, index) {
        final room = rooms[index];
        final otherUser =
        profiles[room.otherUserId];

        return ListTile(
          onTap: () =>
              Navigator.of(context)
                  .push(ChatPage.route(
                  room.id)),
          leading: CircleAvatar(
            child: otherUser == null
                ? preloader
                : Text(otherUser
                .username
                .substring(0, 2)),
          ),
          title: Text(otherUser == null
              ? 'Loading...'
              : otherUser.username),
          subtitle: room.lastMessage !=
              null
              ? Text(
            room.lastMessage!
                .content,
            maxLines: 1,
            overflow: TextOverflow
                .ellipsis,
          )
              : const Text(
              'Room created'),
          trailing: Text(format(
              room.lastMessage
                  ?.createdAt ??
                  room.createdAt,
              locale: 'en_short')),
        );
      },
    );
  }
}