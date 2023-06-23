import 'package:chat/models/chats.dart';
import 'package:chat/models/search.dart';
import 'package:chat/models/theme.dart';
import 'package:chat/models/user.dart';
import 'package:chat/ui/common/user_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:chat/ui/chats/new_message_card.dart';

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
          'New Message'.tr,
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
              child: const Icon(CupertinoIcons.back, color: Colors.black)),
        ),
        centerTitle: true,
        actionsIconTheme: const IconThemeData(
          color: Colors.black,
          size: 24,
          // weight: 100,
        ),
      ),
      body: SafeArea(child: LayoutBuilder(builder: (context, constrain) {
        return SelectUserBySearch(
          onSelect: (x) async => await ChatModel.startChat(x),
        );
      })),
    );
  }
}

class SelectUserBySearch extends StatefulWidget {
  const SelectUserBySearch(
      {super.key, required this.onSelect, this.actionButton});
  final Widget Function(ChatUser)? actionButton;

  final Function(ChatUser) onSelect;

  @override
  State<SelectUserBySearch> createState() => _SelectUserBySearchState();
}

class _SelectUserBySearchState extends State<SelectUserBySearch> {
  final SearchService search = SearchService(hasSuggestion: true);

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 56,
          color: Colors.black.withOpacity(0.07),
          width: Get.width,
          margin: const EdgeInsets.only(top: 2, bottom: 12),
          alignment: Alignment.center,
          child: SizedBox(
            height: 48,
            child: TextFormField(
              style: currentTheme.titleStyle,
              textAlignVertical: TextAlignVertical.bottom,
              onChanged: (x) => search.searchTerm.value = x,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: '',
                enabled: true,
                hintStyle: currentTheme.titleStyle.copyWith(color: Colors.grey),
                filled: false,
                prefixIcon: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${'To'.tr} :',
                      style: currentTheme.titleStyle,
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Obx(() {
                  return Visibility(
                    visible: search.isSearching.value,
                    child: Expanded(
                      child: ListView.builder(
                        itemCount: 3,
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: UserAvatar.loading(
                                height: 56,
                                width: 56,
                              ));
                        },
                      ),
                    ),
                  );
                }),
                Obx(() {
                  return Visibility(
                    visible: search.result.isNotEmpty &&
                        search.searchTerm.isNotEmpty &&
                        !search.isSearching.value,
                    child: Expanded(
                      child: ListView.builder(
                        itemCount: search.result.length,
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          var e = search.result.elementAt(index);
                          return NewMessageCard(
                            actionButton: widget.actionButton,
                            user: e,
                            onPressed: () async {
                              await widget.onSelect(e);
                            },
                          );
                        },
                      ),
                    ),
                  );
                }),
                Obx(() {
                  return Visibility(
                    visible: search.searchTerm.isEmpty &&
                        search.suggestion.isNotEmpty &&
                        !search.isSearching.value,
                    child: Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              'Suggested'.tr,
                              style: currentTheme.titleStyle,
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: search.suggestion.length,
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                var e = search.suggestion.elementAt(index);
                                return NewMessageCard(
                                  actionButton: widget.actionButton,
                                  user: e,
                                  onPressed: () async {
                                    await widget.onSelect(e);
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        // Expanded(
        //     child: PaginateFirestore(
        //     physics: const BouncingScrollPhysics(),
        //   itemBuilder: (context, docs, i) {
        //     UserConnection connection =
        //         docs.elementAt(i).data() as UserConnection;
        //     return NewMessageCard(
        //       connection: connection,
        //     );
        //   },
        //   separator: const Divider(
        //       color: Colors.black12, height: 24, thickness: 1),
        //   query: UserConnection.connections,
        //   onEmpty: const SizedBox(),
        //   itemBuilderType: PaginateBuilderType.listView,
        //   isLive: false,
        // )),
      ],
    );
  }
}
