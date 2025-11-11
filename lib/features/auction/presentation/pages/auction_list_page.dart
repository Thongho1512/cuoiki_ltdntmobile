import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../bloc/auction_list/auction_list_bloc.dart';
import '../bloc/auction_list/auction_list_event.dart';
import '../bloc/auction_list/auction_list_state.dart';
import '../widgets/auction_card_widget.dart';

class AuctionListPage extends StatefulWidget {
  const AuctionListPage({super.key});

  @override
  State<AuctionListPage> createState() => _AuctionListPageState();
}

class _AuctionListPageState extends State<AuctionListPage> {
  @override
  void initState() {
    super.initState();
    context.read<AuctionListBloc>().add(AuctionListLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đấu giá Trực tuyến'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).pushNamed(AppConstants.profileRoute);
            },
          ),
        ],
      ),
      body: BlocBuilder<AuctionListBloc, AuctionListState>(
        builder: (context, state) {
          if (state is AuctionListLoading) {
            return const LoadingWidget(message: 'Đang tải danh sách...');
          }

          if (state is AuctionListError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<AuctionListBloc>().add(
                        AuctionListLoadRequested(),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (state is AuctionListLoaded) {
            if (state.auctions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.gavel, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Chưa có sản phẩm đấu giá',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<AuctionListBloc>().add(
                  AuctionListRefreshRequested(),
                );
                await Future.delayed(const Duration(seconds: 1));
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.auctions.length,
                itemBuilder: (context, index) {
                  final auction = state.auctions[index];
                  return AuctionCardWidget(
                    auction: auction,
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        AppConstants.auctionDetailRoute,
                        arguments: auction.id,
                      );
                    },
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
