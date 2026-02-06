import 'package:eatezy/style/app_color.dart';
import 'package:eatezy/utils/app_spacing.dart';
import 'package:eatezy/view/auth/screens/customer_profile_add_screen.dart';
import 'package:eatezy/view/cart/screens/primary_button.dart';
import 'package:eatezy/view/cart/services/cart_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    Provider.of<CartService>(context, listen: false).gettVendors();
    Provider.of<CartService>(context, listen: false).getCustomer();
    Provider.of<CartService>(context, listen: false).fetchCoupons();
    super.initState();
  }

  static const double _cardRadius = 16;
  static const double _elevation = 2;
  static const Color _surface = Color(0xFFF8F9FA);
  static const Color _cardBg = Colors.white;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CartService>(context);
    final itemCount = provider.selectedProduct.fold<int>(
        0, (sum, p) => sum + p.itemCount);

    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _surface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.grey.shade800),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Your Cart',
          style: TextStyle(
            color: Colors.grey.shade900,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          if (itemCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColor.primary.withOpacity( 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$itemCount item${itemCount == 1 ? '' : 's'}',
                    style: TextStyle(
                      color: AppColor.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: provider.selectedProduct.isEmpty
          ? _EmptyCart(onAddMore: () => Navigator.pop(context))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SectionCard(
                    radius: _cardRadius,
                    elevation: _elevation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Items',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade900,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(Icons.add_circle_outline_rounded,
                                  size: 20, color: AppColor.primary),
                              label: Text(
                                'Add more',
                                style: TextStyle(
                                    color: AppColor.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        AppSpacing.h10,
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          separatorBuilder: (_, __) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Divider(height: 1, color: Colors.grey.shade200),
                          ),
                          itemCount: provider.selectedProduct.length,
                          itemBuilder: (context, i) {
                            final p = provider.selectedProduct[i];
                            return CartProductCard(
                              itemCount: p.itemCount.toString(),
                              onAdd: () => provider.onItemAdd(i),
                              onDelete: () => provider.onItemDelete(i),
                              onRemove: () => provider.onItemRemove(i),
                              image: p.image,
                              name: p.name,
                              description: p.description,
                              price: p.price.toString(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.h15,
                  GestureDetector(
                    onTap: () => _showCouponSheet(context, provider),
                    child: _SectionCard(
                      radius: _cardRadius,
                      elevation: _elevation,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColor.primary.withOpacity( 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Image.asset('assets/icons/discount.png',
                                height: 28, width: 28,
                                color: AppColor.primary, errorBuilder: (_, __, ___) =>
                                Icon(Icons.local_offer_rounded,
                                    color: AppColor.primary, size: 28)),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Have a coupon?',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  provider.selectedCoupon != null
                                      ? '${provider.selectedCoupon}% off applied'
                                      : 'Tap to add code',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: provider.selectedCoupon != null
                                        ? Colors.green.shade700
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded,
                              color: Colors.grey.shade500, size: 28),
                        ],
                      ),
                    ),
                  ),
                  AppSpacing.h15,
                  _SectionCard(
                    radius: _cardRadius,
                    elevation: _elevation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.note_alt_outlined,
                                size: 20, color: AppColor.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Order notes',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),
                        AppSpacing.h10,
                        TextFormField(
                          controller: provider.notesController,
                          maxLines: 2,
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
                          decoration: InputDecoration(
                            hintText: 'Special instructions (e.g. no onions, extra napkins)',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 13,
                            ),
                            filled: true,
                            fillColor: _surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: AppColor.primary, width: 1.5),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.h15,
                  _SectionCard(
                    radius: _cardRadius,
                    elevation: _elevation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order summary',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade900,
                          ),
                        ),
                        AppSpacing.h15,
                        _SummaryRow(
                            label: 'Subtotal',
                            value:
                                '₹${provider.getSubtotal().toStringAsFixed(2)}'),
                        if (provider.cartPackingFee != null &&
                            provider.cartPackingFee! > 0) ...[
                          AppSpacing.h10,
                          _SummaryRow(
                            label: 'Packing fee',
                            value:
                                '₹${provider.cartPackingFee!.toStringAsFixed(2)}',
                          ),
                        ],
                        if (provider.cartPlatformFee > 0) ...[
                          AppSpacing.h10,
                          _SummaryRow(
                            label: 'Platform fee',
                            value:
                                '₹${provider.cartPlatformFee.toStringAsFixed(2)}',
                          ),
                        ],
                        if (provider.selectedCoupon != null) ...[
                          AppSpacing.h10,
                          _SummaryRow(
                            label: 'Discount',
                            value: provider.getDiscountAmount(
                                provider.getSubtotal(),
                                double.parse(
                                    provider.selectedCoupon.toString())),
                            valueColor: Colors.green.shade700,
                          ),
                        ],
                        AppSpacing.h15,
                        Divider(height: 1, color: Colors.grey.shade200),
                        AppSpacing.h15,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade900,
                              ),
                            ),
                            Text(
                              '₹${provider.getTotalAmount(0, provider.selectedCoupon)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColor.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: provider.selectedProduct.isEmpty
          ? null
          : Container(
              decoration: BoxDecoration(
                color: _cardBg,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity( 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + MediaQuery.of(context).padding.bottom),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '₹${provider.getTotalAmount(0, provider.selectedCoupon)}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.grey.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 160,
                      height: 52,
                      child: PrimaryButton(
                        isLoading: provider.isLoading,
                        onTap: () =>
                            provider.buyNow(context, provider.selectedProduct),
                        label: 'Place order',
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _showCouponSheet(BuildContext context, CartService provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              AppSpacing.h20,
              Text(
                'Enter coupon code',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade900,
                ),
              ),
              AppSpacing.h15,
              PrimaryTextField(
                title: 'Coupon code',
                controller: provider.couponController,
              ),
              AppSpacing.h20,
              PrimaryButton(
                label: 'Apply',
                onTap: () => provider.applyCoupon(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.radius,
    required this.elevation,
    required this.child,
  });

  final double radius;
  final double elevation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity( 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? Colors.grey.shade900,
          ),
        ),
      ],
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.onAddMore});

  final VoidCallback onAddMore;

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
                color: AppColor.primary.withOpacity( 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 64,
                color: AppColor.primary.withOpacity( 0.7),
              ),
            ),
            AppSpacing.h20,
            Text(
              'Your cart is empty',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade800,
              ),
            ),
            AppSpacing.h10,
            Text(
              'Add items from restaurants to get started',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: onAddMore,
              icon: const Icon(Icons.add_rounded, color: AppColor.primary),
              label: Text(
                'Browse menu',
                style: TextStyle(
                  color: AppColor.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CartProductCard extends StatelessWidget {
  const CartProductCard({
    super.key,
    required this.image,
    required this.name,
    required this.description,
    required this.price,
    required this.onDelete,
    required this.onAdd,
    required this.onRemove,
    required this.itemCount,
  });

  final String image;
  final String name;
  final String description;
  final String price;
  final VoidCallback onDelete;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final String itemCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 88,
            width: 88,
            child: Image.network(
              image,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey.shade200,
                child: Icon(Icons.restaurant_rounded,
                    color: Colors.grey.shade400, size: 36),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade900,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '₹$price',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColor.primary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _QuantityButton(
                          icon: Icons.remove_rounded,
                          onTap: onRemove,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            itemCount,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                        _QuantityButton(
                          icon: Icons.add_rounded,
                          onTap: onAdd,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          onPressed: onDelete,
          icon: Icon(
            Icons.delete_outline_rounded,
            color: Colors.grey.shade500,
            size: 22,
          ),
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey.shade100,
            minimumSize: const Size(40, 40),
          ),
        ),
      ],
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 18, color: AppColor.primary),
        ),
      ),
    );
  }
}
