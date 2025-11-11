import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../core/widgets/custom_button.dart';

class BidWidget extends StatefulWidget {
  final int currentPrice;
  final bool isPlacingBid;
  final Function(int) onPlaceBid;

  const BidWidget({
    super.key,
    required this.currentPrice,
    required this.isPlacingBid,
    required this.onPlaceBid,
  });

  @override
  State<BidWidget> createState() => _BidWidgetState();
}

class _BidWidgetState extends State<BidWidget> {
  final _bidController = TextEditingController();
  int _selectedIncrement = AppConstants.minBidIncrement;

  @override
  void initState() {
    super.initState();
    _updateBidAmount();
  }

  @override
  void didUpdateWidget(BidWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPrice != widget.currentPrice) {
      _updateBidAmount();
    }
  }

  void _updateBidAmount() {
    final newAmount = widget.currentPrice + _selectedIncrement;
    _bidController.text = newAmount.toString();
  }

  @override
  void dispose() {
    _bidController.dispose();
    super.dispose();
  }

  void _handleQuickBid(int increment) {
    setState(() {
      _selectedIncrement = increment;
      final newAmount = widget.currentPrice + increment;
      _bidController.text = newAmount.toString();
    });
  }

  void _handlePlaceBid() {
    final amount = int.tryParse(_bidController.text);
    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập số tiền hợp lệ'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (amount <= widget.currentPrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Giá đấu phải cao hơn giá hiện tại'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    widget.onPlaceBid(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Đặt giá của bạn',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Quick bid buttons
            Text('Tăng nhanh:', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildQuickBidButton(10000, '10K'),
                _buildQuickBidButton(50000, '50K'),
                _buildQuickBidButton(100000, '100K'),
                _buildQuickBidButton(500000, '500K'),
                _buildQuickBidButton(1000000, '1M'),
              ],
            ),

            const SizedBox(height: 16),

            // Custom bid input
            TextField(
              controller: _bidController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Số tiền đấu giá',
                hintText: 'Nhập số tiền',
                prefixIcon: const Icon(Icons.attach_money),
                suffixText: 'đ',
                helperText:
                    'Tối thiểu: ${PriceFormatter.format(widget.currentPrice + AppConstants.minBidIncrement)}',
              ),
            ),

            const SizedBox(height: 16),

            // Place bid button
            SizedBox(
              height: 48,
              child: CustomButton(
                text: 'Đặt giá',
                onPressed: _handlePlaceBid,
                isLoading: widget.isPlacingBid,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickBidButton(int increment, String label) {
    final isSelected = _selectedIncrement == increment;

    return InkWell(
      onTap: () => _handleQuickBid(increment),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          '+$label',
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
