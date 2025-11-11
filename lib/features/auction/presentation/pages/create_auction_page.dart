// lib/features/auction/presentation/pages/create_auction_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/firebase_constants.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class CreateAuctionPage extends StatefulWidget {
  const CreateAuctionPage({super.key});

  @override
  State<CreateAuctionPage> createState() => _CreateAuctionPageState();
}

class _CreateAuctionPageState extends State<CreateAuctionPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _startingPriceController = TextEditingController();
  final _durationController = TextEditingController(text: '3');

  bool _isCreating = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _startingPriceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateAuction() async {
    if (!_formKey.currentState!.validate()) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để tạo đấu giá'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      final startingPrice = int.parse(_startingPriceController.text);
      final durationDays = int.parse(_durationController.text);
      final now = DateTime.now();
      final endTime = now.add(Duration(days: durationDays));

      final auctionData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'imageUrl': _imageUrlController.text.trim(),
        'startingPrice': startingPrice,
        'currentPrice': startingPrice,
        'highestBidderId': null,
        'highestBidderName': null,
        'startTime': Timestamp.fromDate(now),
        'endTime': Timestamp.fromDate(endTime),
        'status': 'active',
        'sellerId': authState.user.id,
        'sellerName': authState.user.displayName,
        'totalBids': 0,
        'createdAt': Timestamp.fromDate(now),
      };

      await FirebaseFirestore.instance
          .collection(FirebaseConstants.auctionsCollection)
          .add(auctionData);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tạo đấu giá thành công!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tạo đấu giá mới')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              CustomTextField(
                controller: _titleController,
                label: 'Tên sản phẩm',
                hint: 'VD: iPhone 14 Pro Max 256GB',
                prefixIcon: const Icon(Icons.title),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên sản phẩm';
                  }
                  if (value.length < 10) {
                    return 'Tên sản phẩm phải có ít nhất 10 ký tự';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              CustomTextField(
                controller: _descriptionController,
                label: 'Mô tả',
                hint: 'Mô tả chi tiết về sản phẩm...',
                maxLines: 4,
                prefixIcon: const Icon(Icons.description),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mô tả';
                  }
                  if (value.length < 20) {
                    return 'Mô tả phải có ít nhất 20 ký tự';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Image URL
              CustomTextField(
                controller: _imageUrlController,
                label: 'URL hình ảnh',
                hint: 'https://example.com/image.jpg',
                prefixIcon: const Icon(Icons.image),
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập URL hình ảnh';
                  }
                  if (!value.startsWith('http')) {
                    return 'URL không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Starting Price
              CustomTextField(
                controller: _startingPriceController,
                label: 'Giá khởi điểm',
                hint: '1000000',
                prefixIcon: const Icon(Icons.attach_money),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập giá khởi điểm';
                  }
                  final price = int.tryParse(value);
                  if (price == null || price < 1000) {
                    return 'Giá phải lớn hơn 1,000 đ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Duration
              CustomTextField(
                controller: _durationController,
                label: 'Thời gian đấu giá (ngày)',
                hint: '3',
                prefixIcon: const Icon(Icons.calendar_today),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập thời gian';
                  }
                  final days = int.tryParse(value);
                  if (days == null || days < 1 || days > 30) {
                    return 'Thời gian từ 1-30 ngày';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Text(
                'Đấu giá sẽ kết thúc sau ${_durationController.text} ngày',
                style: Theme.of(context).textTheme.bodySmall,
              ),

              const SizedBox(height: 32),

              // Preview info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Lưu ý:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Sau khi tạo, đấu giá sẽ bắt đầu ngay lập tức\n'
                      '• Không thể sửa giá khởi điểm sau khi có người đặt giá\n'
                      '• Hãy đảm bảo thông tin chính xác trước khi tạo',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Create Button
              SizedBox(
                height: 48,
                child: CustomButton(
                  text: 'Tạo đấu giá',
                  onPressed: _handleCreateAuction,
                  isLoading: _isCreating,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
