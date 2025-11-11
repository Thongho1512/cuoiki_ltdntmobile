import 'package:flutter/material.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../domain/entities/bid_entity.dart';

class BidHistoryWidget extends StatelessWidget {
  final List<BidEntity> bids;

  const BidHistoryWidget({Key? key, required this.bids}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (bids.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.history, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 8),
                Text(
                  'Chưa có lượt đấu giá nào',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: bids.length > 10 ? 10 : bids.length,
        separatorBuilder: (context, index) => const Divider(height: 24),
        itemBuilder: (context, index) {
          final bid = bids[index];
          final isWinning = index == 0;

          return Row(
            children: [
              // Position badge
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isWinning ? Colors.amber : Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isWinning
                      ? const Icon(
                          Icons.emoji_events,
                          color: Colors.white,
                          size: 18,
                        )
                      : Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                ),
              ),

              const SizedBox(width: 12),

              // Bidder info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            bid.bidderName,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: isWinning
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isWinning)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Đang dẫn',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormatter.formatDateTime(bid.timestamp),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Bid amount
              Text(
                PriceFormatter.format(bid.amount),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: isWinning
                      ? Theme.of(context).colorScheme.primary
                      : null,
                  fontWeight: isWinning ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
