import 'package:eatezy/style/app_color.dart';
import 'package:eatezy/utils/app_spacing.dart';
import 'package:eatezy/view/cart/screens/primary_button.dart';
import 'package:eatezy/view/cart/services/cart_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const double _paymentCardRadius = 16;
const double _paymentCardElevation = 2;
const Color _paymentSurface = Color(0xFFF8F9FA);

/// Payment type: 'cod' or 'online'.
typedef PaymentType = String;

const PaymentType kPaymentCod = 'cod';
const PaymentType kPaymentOnline = 'online';

/// Screen shown after "Place order" to choose COD or online payment.
class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  PaymentType? _selectedPaymentType;

  void _onProceed(BuildContext context, CartService provider) {
    if (_selectedPaymentType == null) return;
    if (_selectedPaymentType == kPaymentCod) {
      provider.placeOrderWithCod(context);
    } else {
      provider.buyNow(context, provider.selectedProduct);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CartService>(context);
    final totalAmount = provider.getTotalAmount(0, provider.selectedCoupon);
    final hasSelection = _selectedPaymentType != null;
    final canProceed = hasSelection && !provider.isLoading;

    return Scaffold(
      backgroundColor: _paymentSurface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _paymentSurface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.grey.shade800),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Payment',
          style: TextStyle(
            color: Colors.grey.shade900,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Choose how you want to pay',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  AppSpacing.h20,
                  _PaymentOptionCard(
                    icon: Icons.payments_rounded,
                    title: 'Cash on Delivery (COD)',
                    subtitle: 'Pay when your order is delivered',
                    isSelected: _selectedPaymentType == kPaymentCod,
                    onTap: () => setState(() => _selectedPaymentType = kPaymentCod),
                  ),
                  AppSpacing.h15,
                  _PaymentOptionCard(
                    icon: Icons.credit_card_rounded,
                    title: 'Pay Online',
                    subtitle: 'Pay now with card, UPI or wallet',
                    isSelected: _selectedPaymentType == kPaymentOnline,
                    onTap: () => setState(() => _selectedPaymentType = kPaymentOnline),
                  ),
                  AppSpacing.h20,
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(_paymentCardRadius),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order total',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        Text(
                          '₹${totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColor.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + MediaQuery.of(context).padding.bottom),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: IgnorePointer(
                ignoring: !canProceed,
                child: Opacity(
                  opacity: (hasSelection || provider.isLoading) ? 1 : 0.5,
                  child: PrimaryButton(
                    label: 'Proceed',
                    isLoading: provider.isLoading,
                    onTap: () => _onProceed(context, provider),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentOptionCard extends StatelessWidget {
  const _PaymentOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(_paymentCardRadius),
      elevation: _paymentCardElevation,
      shadowColor: Colors.black.withOpacity(0.04),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_paymentCardRadius),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_paymentCardRadius),
            border: Border.all(
              color: isSelected ? AppColor.primary : Colors.transparent,
              width: 2,
            ),
            color: isSelected ? AppColor.primary.withOpacity(0.06) : null,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColor.primary.withOpacity(0.2)
                      : AppColor.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: AppColor.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle_rounded, color: AppColor.primary, size: 28)
              else
                Icon(Icons.circle_outlined, color: Colors.grey.shade400, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}
