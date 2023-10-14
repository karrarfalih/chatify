import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'bloc/pagination_cubit.dart';
import 'bloc/pagination_listeners.dart';
import 'widgets/bottom_loader.dart';
import 'widgets/empty_display.dart';
import 'widgets/empty_separator.dart';
import 'widgets/error_display.dart';
import 'widgets/initial_loader.dart';

class KrPaginateFirestore<T> extends StatefulWidget {
  const KrPaginateFirestore({
    Key? key,
    required this.itemBuilder,
    required this.query,
    required this.itemBuilderType,
    this.gridDelegate =
        const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
    this.startAfterDocument,
    this.itemsPerPage = 15,
    this.onError,
    this.onReachedEnd,
    this.onLoaded,
    this.onEmpty = const EmptyDisplay(),
    this.separator = const EmptySeparator(),
    this.initialLoader = const InitialLoader(),
    this.bottomLoader = const BottomLoader(),
    this.shrinkWrap = false,
    this.reverse = false,
    this.scrollDirection = Axis.vertical,
    this.padding = const EdgeInsets.all(0),
    this.physics,
    this.listeners,
    this.scrollController,
    this.allowImplicitScrolling = false,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.pageController,
    this.onPageChanged,
    this.header,
    this.footer,
    this.isLive = false,
    this.preloadPagesCount = 1,
    this.includeMetadataChanges = false,
    this.options,
    this.firstPage,
    this.excludeId,
    this.itemsCount,
    this.useInsideScrollView = false,
  }) : super(key: key);

  final Widget bottomLoader;
  final Widget onEmpty;
  final SliverGridDelegate gridDelegate;
  final Widget initialLoader;
  final PaginateBuilderType itemBuilderType;
  final int itemsPerPage;
  final int? itemsCount;
  final int preloadPagesCount;
  final List<ChangeNotifier>? listeners;
  final EdgeInsets padding;
  final ScrollPhysics? physics;
  final Query query;
  final bool reverse;
  final bool allowImplicitScrolling;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final ScrollController? scrollController;
  final PageController? pageController;
  final Axis scrollDirection;
  final Widget separator;
  final bool shrinkWrap;
  final bool isLive;
  final DocumentSnapshot? startAfterDocument;
  final Widget? header;
  final Widget? footer;
  final Widget? firstPage;
  final String? excludeId;

  /// Use this only if `isLive = false`
  final GetOptions? options;

  /// Use this only if `isLive = true`
  final bool includeMetadataChanges;

  @override
  _KrPaginateFirestoreState createState() => _KrPaginateFirestoreState();

  final Widget Function(Exception)? onError;

  final Widget Function(BuildContext, List<DocumentSnapshot>, int) itemBuilder;

  final void Function(PaginationLoaded)? onReachedEnd;

  final void Function(PaginationLoaded)? onLoaded;

  final void Function(int)? onPageChanged;

  final bool useInsideScrollView;
}

class _KrPaginateFirestoreState<T> extends State<KrPaginateFirestore> {
  PaginationCubit? _cubit;
  int get count => (widget.firstPage == null ? 0 : 1);
  UniqueKey key = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaginationCubit, PaginationState>(
      bloc: _cubit,
      builder: (context, state) {
        if (widget.useInsideScrollView) {
          if (state is PaginationInitial) {
            return SliverToBoxAdapter(
              child: widget.initialLoader,
            );
          }
          if (state is PaginationError) {
            return SliverToBoxAdapter(
              child: (widget.onError != null)
                  ? widget.onError!(state.error)
                  : ErrorDisplay(exception: state.error),
            );
          }
          if (state is PaginationLoaded) {
            if (state.documentSnapshots.isEmpty) {
              return SliverToBoxAdapter(
                child: widget.onEmpty,
              );
            }
            return SliverPadding(
              padding: widget.padding,
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final itemIndex = index ~/ 2;
                    if (index.isEven) {
                      if (itemIndex >= state.documentSnapshots.length) {
                        _cubit!.fetchPaginatedList();
                        return widget.bottomLoader;
                      }
                      return widget.itemBuilder(
                        context,
                        state.documentSnapshots,
                        itemIndex,
                      );
                    }
                    return widget.separator;
                  },
                  semanticIndexCallback: (widget, localIndex) {
                    if (localIndex.isEven) {
                      return localIndex ~/ 2;
                    }
                    return null;
                  },
                  childCount: min(
                    (widget.itemsCount ?? 1000000) * 2,
                    max(
                      0,
                      (state.hasReachedEnd
                                  ? state.documentSnapshots.length
                                  : state.documentSnapshots.length + 1) *
                              2 -
                          1,
                    ),
                  ),
                ),
              ),
            );
          }
        }
        return (state is PaginationInitial)
            ? _buildWithScrollView(context, widget.initialLoader, isEmpty: true)
            : (state is PaginationError)
                ? _buildWithScrollView(
                    context,
                    (widget.onError != null)
                        ? widget.onError!(state.error)
                        : ErrorDisplay(exception: state.error),
                  )
                : Builder(
                    builder: (context) {
                      final loadedState = state as PaginationLoaded;
                      if (widget.onLoaded != null) {
                        widget.onLoaded!(loadedState);
                      }
                      if (loadedState.hasReachedEnd &&
                          widget.onReachedEnd != null) {
                        widget.onReachedEnd!(loadedState);
                      }

                      if (loadedState.documentSnapshots.isEmpty) {
                        return _buildWithScrollView(
                          context,
                          widget.onEmpty,
                          isEmpty: true,
                        );
                      }
                      return widget.itemBuilderType ==
                              PaginateBuilderType.listView
                          ? _buildListView(loadedState)
                          : widget.itemBuilderType ==
                                  PaginateBuilderType.gridView
                              ? _buildGridView(loadedState)
                              : _buildPageView(loadedState);
                    },
                  );
      },
    );
  }

  Widget _buildWithScrollView(
    BuildContext context,
    Widget child, {
    bool isEmpty = false,
  }) {
    if (isEmpty) return child;
    return SingleChildScrollView(
      child: Container(
        alignment: Alignment.center,
        height: MediaQuery.of(context).size.height,
        child: child,
      ),
    );
  }

  @override
  void dispose() {
    widget.scrollController?.dispose();
    _cubit?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    if (widget.listeners != null) {
      for (var listener in widget.listeners!) {
        if (listener is PaginateRefreshedChangeListener) {
          listener.addListener(() {
            if (listener.refreshed) {
              _cubit!.refreshPaginatedList();
            }
          });
        } else if (listener is PaginateFilterChangeListener) {
          listener.addListener(() {
            if (listener.searchTerm.isNotEmpty) {
              _cubit!.filterPaginatedList(listener.searchTerm);
            }
          });
        }
      }
    }

    _cubit = PaginationCubit(
      widget.query,
      widget.itemsPerPage,
      widget.startAfterDocument,
      isLive: widget.isLive,
    )..fetchPaginatedList();
    super.initState();
  }

  Widget _buildGridView(PaginationLoaded loadedState) {
    var gridView = CustomScrollView(
      reverse: widget.reverse,
      controller: widget.scrollController,
      shrinkWrap: widget.shrinkWrap,
      scrollDirection: widget.scrollDirection,
      physics: widget.physics,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      slivers: _getGridSlivers(loadedState),
    );

    if (widget.listeners != null && widget.listeners!.isNotEmpty) {
      return MultiProvider(
        providers: widget.listeners!
            .map(
              (_listener) => ChangeNotifierProvider(
                create: (context) => _listener,
              ),
            )
            .toList(),
        child: gridView,
      );
    }

    return gridView;
  }

  List<Widget> _getGridSlivers(PaginationLoaded<dynamic> loadedState) {
    return [
      if (widget.header != null) widget.header!,
      SliverPadding(
        padding: widget.padding,
        sliver: SliverGrid(
          gridDelegate: widget.gridDelegate,
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index >= loadedState.documentSnapshots.length) {
                _cubit!.fetchPaginatedList();
                return widget.bottomLoader;
              }
              return widget.itemBuilder(
                context,
                loadedState.documentSnapshots,
                index,
              );
            },
            childCount: loadedState.hasReachedEnd
                ? loadedState.documentSnapshots.length
                : loadedState.documentSnapshots.length + 1,
          ),
        ),
      ),
      if (widget.footer != null) widget.footer!,
    ];
  }

  Widget _buildListView(PaginationLoaded loadedState) {
    var listView = CustomScrollView(
      reverse: widget.reverse,
      controller: widget.scrollController,
      shrinkWrap: widget.shrinkWrap,
      scrollDirection: widget.scrollDirection,
      physics: widget.physics,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      slivers: _getListViewSlivers(loadedState),
    );

    if (widget.listeners != null && widget.listeners!.isNotEmpty) {
      return MultiProvider(
        providers: widget.listeners!
            .map(
              (_listener) => ChangeNotifierProvider(
                create: (context) => _listener,
              ),
            )
            .toList(),
        child: listView,
      );
    }

    return listView;
  }

  List<Widget> _getListViewSlivers(PaginationLoaded<dynamic> loadedState) {
    return [
      if (widget.header != null) widget.header!,
      SliverPadding(
        padding: widget.padding,
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final itemIndex = index ~/ 2;
              if (index.isEven) {
                if (itemIndex >= loadedState.documentSnapshots.length) {
                  _cubit!.fetchPaginatedList();
                  return widget.bottomLoader;
                }
                return widget.itemBuilder(
                  context,
                  loadedState.documentSnapshots,
                  itemIndex,
                );
              }
              return widget.separator;
            },
            semanticIndexCallback: (widget, localIndex) {
              if (localIndex.isEven) {
                return localIndex ~/ 2;
              }
              return null;
            },
            childCount: min(
              (widget.itemsCount ?? 1000000) * 2,
              max(
                0,
                (loadedState.hasReachedEnd
                            ? loadedState.documentSnapshots.length
                            : loadedState.documentSnapshots.length + 1) *
                        2 -
                    1,
              ),
            ),
          ),
        ),
      ),
      if (widget.footer != null) widget.footer!,
    ];
  }

  Widget _buildPageView(PaginationLoaded loadedState) {
    var pageView = Padding(
      padding: widget.padding,
      child: PageView.custom(
        reverse: widget.reverse,
        controller: widget.pageController,
        scrollDirection: widget.scrollDirection,
        physics: widget.physics,
        onPageChanged: widget.onPageChanged,
        childrenDelegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index >= (loadedState.documentSnapshots.length)) {
              _cubit!.fetchPaginatedList();
              return widget.bottomLoader;
            }
            if (index == 0 && widget.firstPage != null) return widget.firstPage;
            return widget.itemBuilder(
              context,
              loadedState.documentSnapshots
                  .where((e) => e.id != widget.excludeId)
                  .toList(),
              index - count,
            );
          },
          childCount: (loadedState.hasReachedEnd
              ? loadedState.documentSnapshots.length
              : loadedState.documentSnapshots.length),
        ),
      ),
    );

    if (widget.listeners != null && widget.listeners!.isNotEmpty) {
      return MultiProvider(
        providers: widget.listeners!
            .map(
              (_listener) => ChangeNotifierProvider(
                create: (context) => _listener,
              ),
            )
            .toList(),
        child: pageView,
      );
    }

    return pageView;
  }
}

enum PaginateBuilderType { listView, gridView, pageView }
