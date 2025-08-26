import '../../helpers/paginated_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class PaginatedResultBuilder<B extends StateStreamable<S>, S, T>
    extends StatefulWidget {
  const PaginatedResultBuilder({
    super.key,
    required this.builder,
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

  final Widget Function(BuildContext context, List<T> data, int index) builder;
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
  State<PaginatedResultBuilder<B, S, T>> createState() =>
      _PaginatedResultBuilderState<B, S, T>();
}

class _PaginatedResultBuilderState<B extends StateStreamable<S>, S, T>
    extends State<PaginatedResultBuilder<B, S, T>> {
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
          if (widget.placeholder != null) {
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: widget.placeholder!,
              padding: widget.padding,
              separatorBuilder: widget.separatorBuilder ??
                  (context, _) => const SizedBox.shrink(),
              itemCount: 20,
              cacheExtent: widget.cacheExtent,
              scrollDirection: widget.scrollDirection ?? Axis.vertical,
            );
          }
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
        return ListView.separated(
          reverse: widget.reverse,
          shrinkWrap: true,
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          scrollDirection: widget.scrollDirection ?? Axis.vertical,
          padding: widget.padding,
          itemBuilder: (context, index) {
            if (index == data.items.length) {
              return widget.placeholder?.call(context, 0) ??
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: _LoadingResultBuilder(),
                  );
            }
            return widget.builder(context, data.items, index);
          },
          separatorBuilder: widget.separatorBuilder ??
              (context, _) => const SizedBox.shrink(),
          itemCount: data.items.length + (data.hasReachedEnd ? 0 : 1),
          cacheExtent: widget.cacheExtent,
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

class EmptyResultBuilder extends StatelessWidget {
  const EmptyResultBuilder({
    super.key,
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title.tr,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Text(
            description.tr,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class ErrorResultBuilder extends StatelessWidget {
  const ErrorResultBuilder({
    super.key,
    required this.error,
    this.isSmall = false,
  });

  final String error;
  final bool isSmall;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isSmall ? null : double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: isSmall ? MainAxisSize.min : MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            error.toLowerCase().contains('no internet')
                ? Icons.wifi_off_outlined
                : Iconsax.info_circle,
            color: Theme.of(context).colorScheme.error,
            size: 80,
          ),
          const SizedBox(height: 16),
          Text(error),
        ],
      ),
    );
  }
}
