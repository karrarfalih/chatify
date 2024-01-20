import 'package:chatify/chatify.dart';
import 'package:chatify/src/localization/get_string.dart';
import 'package:chatify/src/ui/chats/new_chat/controllers/search_controller.dart';
import 'package:chatify/src/ui/common/shimmer_bloc.dart';
import 'package:chatify/src/utils/value_notifiers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide SearchController;
import 'package:chatify/src/ui/chats/new_chat/result_card.dart';
import 'package:flutter/services.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final search = SearchController();

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Chatify.theme;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        systemOverlayStyle: theme.isRecentChatsDark
            ? SystemUiOverlayStyle.light.copyWith(
                systemNavigationBarDividerColor: Colors.black,
                systemNavigationBarColor: Colors.black,
                systemNavigationBarIconBrightness: Brightness.light,
              )
            : SystemUiOverlayStyle.dark.copyWith(
                systemNavigationBarDividerColor: Colors.white,
                systemNavigationBarColor: Colors.white,
                systemNavigationBarIconBrightness: Brightness.dark,
              ),
        title: Padding(
          padding: const EdgeInsetsDirectional.only(end: 16),
          child: SizedBox(
            height: 42,
            child: TextFormField(
              style: TextStyle(color: theme.recentChatsForegroundColor),
              textAlignVertical: TextAlignVertical.bottom,
              onChanged: (x) => search.query.value = x,
              textInputAction: TextInputAction.done,
              autofocus: true,
              decoration: InputDecoration(
                hintText: localization(context).search,
                enabled: true,
                hintStyle: TextStyle(
                  color: theme.recentChatsForegroundColor.withOpacity(0.5),
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  height: 1.8,
                ),
                isDense: true,
                filled: true,
                fillColor: theme.recentChatsForegroundColor.withOpacity(0.05),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.transparent,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: theme.recentChatsForegroundColor.withOpacity(0.1),
                  ),
                ),
              ),
            ),
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          padding: EdgeInsets.all(14),
          icon: Icon(
            CupertinoIcons.back,
            color: theme.recentChatsForegroundColor,
          ),
        ),
        centerTitle: true,
        actionsIconTheme: IconThemeData(
          color: theme.recentChatsForegroundColor,
          size: 24,
        ),
      ),
      body: SafeArea(
        child: MultiValuesListenableBuilder(
          valueListenables: [
            search.results,
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
                        return UserResultCard(
                          user: e,
                          onTap: (e) async =>
                              await Chatify.openChatByUser(context, user: e),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
