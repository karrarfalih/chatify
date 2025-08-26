import '../../helpers/paginated_result.dart';
import 'paginated_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class PaginatedCustomScrollView<B extends StateStreamable<S>, S, T>
    extends StatefulWidget {
  const PaginatedCustomScrollView({
    super.key,
    required this.slivers,
    required this.selector,
    required this.onFetch,
    this.initialState,
    this.separatorBuilder,
    this.onEmpty,
    this.placeholder,
    this.controller,
    this.scrollDirection,
    this.padding,
    this.cacheExtent,
    this.reverse = false,
  });

  final List<Widget> Function(BuildContext context, List<T> data) slivers;
  final PaginatedResult<T> Function(S state) selector;
  final PaginatedResult<T>? initialState;
  final Function(BuildContext context, bool isRefresh) onFetch;
  final Widget Function(BuildContext, int)? separatorBuilder;
  final Widget? onEmpty;
  final Widget Function(BuildContext context, int index)? placeholder;
  final ScrollController? controller;
  final Axis? scrollDirection;
  final EdgeInsetsGeometry? padding;
  final double? cacheExtent;
  final bool reverse;

  @override
  State<PaginatedCustomScrollView<B, S, T>> createState() =>
      _PaginatedCustomScrollViewState<B, S, T>();
}

class _PaginatedCustomScrollViewState<B extends StateStreamable<S>, S, T>
    extends State<PaginatedCustomScrollView<B, S, T>> {
  late final scrollController = widget.controller ?? ScrollController();

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 100) {
        widget.onFetch(context, false);
      }
    });
    final bloc = context.read<B>();
    if (!widget.selector(bloc.state).isFetched) {
      widget.onFetch(context, true);
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<B, S, PaginatedResult<T>>(
      selector: (state) => widget.selector(state),
      builder: (context, data) {
        if (data.isInitialLoading) {
          return const _LoadingResultBuilder();
        }
        if (data.hasError) {
          return ErrorResultBuilder(
            error: data.error ?? 'Something went wrong',
          );
        }
        if (data.items.isEmpty) {
          return widget.onEmpty ??
              EmptyResultBuilder(
                title: 'No data'.tr,
                description: 'You don’t have any data yet'.tr,
              );
        }
        return CustomScrollView(
          reverse: widget.reverse,
          shrinkWrap: true,
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          scrollDirection: widget.scrollDirection ?? Axis.vertical,
          cacheExtent: widget.cacheExtent,
          slivers: widget.slivers(context, data.items),
        );
      },
    );
  }
}

class _LoadingResultBuilder extends StatelessWidget {
  const _LoadingResultBuilder();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
