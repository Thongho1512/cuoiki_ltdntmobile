import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/auction_detail/auction_detail_bloc.dart';
import '../bloc/auction_detail/auction_detail_event.dart';
import '../bloc/auction_detail/auction_detail_state.dart';
import '../widgets/bid_history_widget.dart';
import '../widgets/bid_widget.dart';
import '../widgets/countdown_timer_widget.dart';

class AuctionDetailPage extends StatefulWidget {
  final String auctionId;

  const AuctionDetailPage({Key? key, required this.auctionId})
    : super(key: key);

  @override
  State<AuctionDetailPage> createState() => _AuctionDetailPageState();
}

class _AuctionDetailPageState extends State<AuctionDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<AuctionDetailBloc>().add(
      AuctionDetailLoadRequested(widget.auctionId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết đấu giá')),
      body: BlocConsumer<AuctionDetailBloc, AuctionDetailState>(
        listener: (context, state) {
          if (state is AuctionDetailBidSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is AuctionDetailBidError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AuctionDetailLoading) {
            return const LoadingWidget(message: 'Đang tải...');
          }

          if (state is AuctionDetailError) {
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
                ],
              ),
            );
          }

          if (state is AuctionDetailLoaded || state is AuctionDetailBidError) {
            final auction = state is AuctionDetailLoaded
                ? state.auction
                : (state as AuctionDetailBidError).auction;

            final bidHistory = state is AuctionDetailLoaded
                ? state.bidHistory
                : [];

            final isPlacingBid = state is AuctionDetailLoaded
                ? state.isPlacingBid
                : false;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      auction.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.image_not_supported,
                            size: 64,
                            color: Colors.grey[600],
                          ),
                        );
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          auction.title,
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        const SizedBox(height: 8),

                        // Seller info
                        Row(
                          children: [
                            const Icon(Icons.person, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              auction.sellerName,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Countdown Timer
                        if (auction.isActive)
                          CountdownTimerWidget(endTime: auction.endTime)
                        else
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.close, color: Colors.red[700]),
                                const SizedBox(width: 8),
                                Text(
                                  'Đấu giá đã kết thúc',
                                  style: TextStyle(
                                    color: Colors.red[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 16),

                        // Price Info Card
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Giá khởi điểm:',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                    Text(
                                      PriceFormatter.format(
                                        auction.startingPrice,
                                      ),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleLarge,
                                    ),
                                  ],
                                ),
                                const Divider(height: 24),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Giá hiện tại:',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                          ),
                                    ),
                                    Text(
                                      PriceFormatter.format(
                                        auction.currentPrice,
                                      ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .displaySmall
                                          ?.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                                if (auction.highestBidderName != null) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Người đặt giá cao nhất:',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                      Text(
                                        auction.highestBidderName!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                                const Divider(height: 24),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Tổng lượt đấu giá:',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                    Text(
                                      '${auction.totalBids} lượt',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleLarge,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Description
                        Text(
                          'Mô tả:',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          auction.description,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),

                        const SizedBox(height: 24),

                        // Bid Widget
                        if (auction.isActive)
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, authState) {
                              if (authState is AuthAuthenticated) {
                                final isOwnAuction =
                                    authState.user.id == auction.sellerId;
                                final isHighestBidder =
                                    authState.user.id ==
                                    auction.highestBidderId;

                                if (isOwnAuction) {
                                  return Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.orange[50],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.info,
                                          color: Colors.orange[700],
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Đây là sản phẩm của bạn',
                                            style: TextStyle(
                                              color: Colors.orange[700],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                if (isHighestBidder) {
                                  return Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.green[50],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          color: Colors.green[700],
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Bạn đang là người đặt giá cao nhất',
                                            style: TextStyle(
                                              color: Colors.green[700],
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                return BidWidget(
                                  currentPrice: auction.currentPrice,
                                  isPlacingBid: isPlacingBid,
                                  onPlaceBid: (amount) {
                                    context.read<AuctionDetailBloc>().add(
                                      AuctionDetailPlaceBidRequested(amount),
                                    );
                                  },
                                );
                              }

                              return const SizedBox.shrink();
                            },
                          ),

                        const SizedBox(height: 24),

                        // Bid History
                        Text(
                          'Lịch sử đấu giá',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        BidHistoryWidget(bids: bidHistory),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
