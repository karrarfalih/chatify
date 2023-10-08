import 'dart:math';

import 'package:chatify/chatify.dart';

final chatifyConfig = ChatifyConfig(
  getUserById: (id) async {
    print(id);
    if (id == karrar.id) return karrar;
    if (id == sara.id) return sara;
    return Future.value(
      ChatifyUser(
        id: 'id${Random().nextInt(10000)}',
        name: 'name',
        profileImage:
            'https://xsgames.co/randomusers/avatar.php?g=female&i=${Random().nextInt(10000)}',
      ),
    );
  },
  getUsersBySearch: (query) async {
    await Future.delayed(Duration(seconds: 2));
    return [
      ChatifyUser(
        id: 'id_1',
        name: 'user 1',
        profileImage: 'https://xsgames.co/randomusers/avatar.php?g=female&i=1',
      ),
      ChatifyUser(
        id: 'id_2',
        name: 'user 2',
        profileImage: 'https://xsgames.co/randomusers/avatar.php?g=female&i=2',
      ),
      ChatifyUser(
        id: 'id_3',
        name: 'user 3',
        profileImage: 'https://xsgames.co/randomusers/avatar.php?g=female&i=3',
      ),
    ];
  },
);

final sara = ChatifyUser(
  id: 'sara_ahmed',
  name: 'Sara Ahmed',
  profileImage:
      'https://img.freepik.com/premium-photo/photo-businesswoman_889227-37078.jpg',
);

final karrar = ChatifyUser(
  id: 'karrar_falih',
  name: 'Karrar Falih',
  profileImage:
      'https://img.freepik.com/premium-photo/western-man-with-short-curly-hair-wearing-glasses_978087-3411.jpg',
);
