import 'package:chatify/chatify.dart';

final chatifyConfig = ChatifyConfig(
  getUserById: (id) async {
    return users.firstWhere((element) => element.id == id);
  },
  getUsersBySearch: (query) async {
    return users;
  },
);

final users = [
      ChatifyUser(
        id: 'amjed',
        name: 'Amjed Sami',
        profileImage: 'https://xsgames.co/randomusers/avatar.php?g=female&i=1',
      ),
      ChatifyUser(
        id: 'karrar',
        name: 'Karrar Falih',
        profileImage: 'https://xsgames.co/randomusers/avatar.php?g=female&i=2',
      ),
      ChatifyUser(
        id: 'husain',
        name: 'Husain Kadhum',
        profileImage: 'https://xsgames.co/randomusers/avatar.php?g=female&i=3',
      ),
      ChatifyUser(
        id: 'ali',
        name: 'Ali Emad',
        profileImage: 'https://xsgames.co/randomusers/avatar.php?g=female&i=4',
      ),
    ];

