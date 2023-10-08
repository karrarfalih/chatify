import 'package:chatify/chatify.dart';
import 'package:chatify/src/theme/theme_widget.dart';
import 'package:chatify/src/ui/chats/new_chat/controllers/search_controller.dart';
import 'package:chatify/src/ui/common/shimmer_bloc.dart';
import 'package:chatify/src/utils/value_notifiers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter/services.dart';
import 'package:chatify/src/ui/chats/new_chat/new_message_card.dart';

class NewMessages extends StatelessWidget {
  const NewMessages({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: Text(
          'New Message',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: const Icon(CupertinoIcons.back, color: Colors.black),
          ),
        ),
        centerTitle: true,
        actionsIconTheme: const IconThemeData(
          color: Colors.black,
          size: 24,
          // weight: 100,
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constrain) {
            return SelectUserBySearch(
              onSelect: (user) async =>
                  await Chatify.openChatByUser(context, user: user),
            );
          },
        ),
      ),
    );
  }
}

class SelectUserBySearch extends StatefulWidget {
  const SelectUserBySearch({
    super.key,
    required this.onSelect,
    this.actionButton,
  });
  final Widget Function(ChatifyUser)? actionButton;

  final Function(ChatifyUser) onSelect;

  @override
  State<SelectUserBySearch> createState() => _SelectUserBySearchState();
}

class _SelectUserBySearchState extends State<SelectUserBySearch> {
  final search = SearchController();

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ChatifyTheme.of(context);
    return Column(
      children: [
        Container(
          height: 56,
          color: Colors.black.withOpacity(0.07),
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.only(top: 2, bottom: 12),
          alignment: Alignment.center,
          child: SizedBox(
            height: 48,
            child: TextFormField(
              style: TextStyle(color: theme.recentChatsBackgroundColor),
              textAlignVertical: TextAlignVertical.bottom,
              onChanged: (x) => search.query.value = x,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: '',
                enabled: true,
                hintStyle: TextStyle(color: Colors.grey),
                filled: false,
                prefixIcon: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'To :',
                      style: TextStyle(color: theme.recentChatsBackgroundColor),
                    ),
                  ],
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                  borderSide: const BorderSide(
                    color: Colors.transparent,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                  borderSide: const BorderSide(
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: MultiValuesListenableBuilder(
            valueListenables: [
              search.results,
              search.history,
              search.isSearching,
            ],
            builder: (context, value, child) {
              return Column(
                children: [
                  Visibility(
                    visible: search.isSearching.value,
                    child: Expanded(
                      child: ListView.builder(
                        itemCount: 3,
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 20,
                            ),
                            child: Row(
                              children: [
                                ShimmerBloc(
                                  radius: 56,
                                  size: Size.square(56),
                                ),
                                SizedBox(
                                  width: 14,
                                ),
                                ShimmerBloc(
                                  radius: 6,
                                  size: Size(200, 20),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Visibility(
                    visible: search.results.value.isNotEmpty &&
                        search.results.value.isNotEmpty &&
                        !search.isSearching.value,
                    child: Expanded(
                      child: ListView.builder(
                        itemCount: search.results.value.length,
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          var e = search.results.value.elementAt(index);
                          return NewMessageCard(
                            user: e,
                            onTap: widget.onSelect,
                          );
                        },
                      ),
                    ),
                  ),
                  Visibility(
                    visible: search.query.value.isEmpty &&
                        search.history.value.isNotEmpty &&
                        !search.isSearching.value,
                    child: Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              'History',
                              style: TextStyle(
                                color: theme.recentChatsBackgroundColor,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: search.history.value.length,
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                var e = search.history.value.elementAt(index);
                                return NewMessageCard(
                                  user: e,
                                  onTap: widget.onSelect,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
