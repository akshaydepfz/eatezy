import 'package:animate_do/animate_do.dart';
import 'package:eatezy/style/app_color.dart';
import 'package:eatezy/view/orders/services/order_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeliveryTab extends StatelessWidget {
  const DeliveryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderService>(builder: (context, p, _) {
      if (p.deliveredOrders.isEmpty) {
        return _EmptyOrdersState(
          message: 'No delivered orders yet',
          subtitle: 'Completed orders will show up here',
          icon: Icons.check_circle_outline_rounded,
        );
      }
      return RefreshIndicator(
        onRefresh: () => p.getOrders(),
        color: AppColor.primary,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: p.deliveredOrders.length,
          shrinkWrap: true,
          itemBuilder: (context, i) {
            final order = p.deliveredOrders[i];
            final totalQuantity = order.products.fold<int>(
              0,
              (sum, product) => sum + product.quantity,
            );
            final image = order.shopImage.isNotEmpty
                ? order.shopImage
                : (order.products.isNotEmpty
                    ? order.products.first.image
                    : '');
            final name = order.vendorName.isNotEmpty
                ? order.vendorName
                : (order.products.isNotEmpty
                    ? order.products.first.name
                    : 'Order');
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: FadeInUp(
                duration: const Duration(milliseconds: 400),
                child: _DeliveryOrderCard(
                  image: image,
                  name: name,
                  totalPrice: order.totalPrice,
                  itemCount: totalQuantity.toString(),
                  notes: order.notes,
                  packingFee: order.packingFee,
                  platformFee: order.platformCharge,
                  isRated: order.isRated,
                  rating: order.rating,
                  onReviewTap: () => p.showReviewDialog(context, order.id),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}

class _DeliveryOrderCard extends StatelessWidget {
  const _DeliveryOrderCard({
    required this.image,
    required this.name,
    required this.totalPrice,
    required this.itemCount,
    required this.onReviewTap,
    required this.isRated,
    required this.rating,
    this.notes = '',
    this.packingFee = 0.0,
    this.platformFee = 0.0,
  });

  final String image;
  final String name;
  final String totalPrice;
  final String itemCount;
  final String notes;
  final double packingFee;
  final double platformFee;
  final VoidCallback onReviewTap;
  final double rating;
  final bool isRated;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with image
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                child: SizedBox(
                  height: 100,
                  width: 100,
                  child: Image.network(
                    image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade200,
                      child: Icon(
                        Icons.restaurant_rounded,
                        size: 40,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    loadingBuilder: (_, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: Colors.grey.shade100,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade900,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD1EEDB),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Completed',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.green.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$itemCount items',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₹$totalPrice',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColor.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (notes.trim().isNotEmpty || packingFee > 0 || platformFee > 0) ...[
            Divider(height: 1, color: Colors.grey.shade200),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (notes.trim().isNotEmpty) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.note_alt_outlined,
                            size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            notes.trim(),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (packingFee > 0 || platformFee > 0) const SizedBox(height: 8),
                  ],
                  if (packingFee > 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Packing fee',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          '₹${packingFee.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  if (platformFee > 0) ...[
                    if (packingFee > 0) const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Platform fee',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          '₹${platformFee.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
          Divider(height: 1, color: Colors.grey.shade200),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (isRated)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) {
                      final filled = index < rating.round();
                      return Icon(
                        filled ? Icons.star_rounded : Icons.star_border_rounded,
                        color: filled ? Colors.amber : Colors.grey.shade400,
                        size: 24,
                      );
                    }),
                  )
                else
                  Expanded(
                    child: _OutlinedActionButton(
                      label: 'Write Review',
                      onTap: onReviewTap,
                      isDestructive: false,
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FilledActionButton(
                    label: 'Order Again',
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilledActionButton extends StatelessWidget {
  const _FilledActionButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.primary,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 48,
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _OutlinedActionButton extends StatelessWidget {
  const _OutlinedActionButton({
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.red : Colors.grey.shade700;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyOrdersState extends StatelessWidget {
  const _EmptyOrdersState({
    required this.message,
    required this.subtitle,
    required this.icon,
  });

  final String message;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColor.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: AppColor.primary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
