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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CartService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListView.separated(
                      shrinkWrap: true,
                      separatorBuilder: (context, index) => Divider(),
                      itemCount: provider.selectedProduct.length,
                      itemBuilder: (context, i) {
                        return CartProductCard(
                            itemCount: provider.selectedProduct[i].itemCount
                                .toString(),
                            onAdd: () => provider.onItemAdd(i),
                            onDelete: () => provider.onItemDelete(i),
                            onRemove: () => provider.onItemRemove(i),
                            image: provider.selectedProduct[i].image,
                            name: provider.selectedProduct[i].name,
                            description:
                                provider.selectedProduct[i].description,
                            price:
                                provider.selectedProduct[i].price.toString());
                      }),
                  AppSpacing.h20,
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 150,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: Colors.grey.shade300),
                        padding: EdgeInsets.all(5),
                        child: Row(
                          children: [
                            Icon(Icons.add),
                            AppSpacing.w5,
                            Text('Add more items')
                          ],
                        ),
                      ),
                    ),
                  ),
                  AppSpacing.h10,
                ],
              ),
            ),
            AppSpacing.h10,
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                    context: context,
                    builder: (context) => Container(
                          padding: EdgeInsets.all(15),
                          child: Column(
                            children: [
                              Text(
                                'Enter Your Coupon Code',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: AppColor.primary,
                                    fontWeight: FontWeight.bold),
                              ),
                              AppSpacing.h10,
                              PrimaryTextField(
                                  title: 'Enter Coupon',
                                  controller: provider.couponController),
                              AppSpacing.h15,
                              PrimaryButton(
                                  label: 'Apply',
                                  onTap: () => provider.applyCoupon(context))
                            ],
                          ),
                        ));
              },
              child: Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                            height: 25,
                            width: 25,
                            child: Image.asset('assets/icons/discount.png')),
                        AppSpacing.w10,
                        Text('Apply Coupon'),
                      ],
                    ),
                    Icon(Icons.arrow_forward_ios_rounded)
                  ],
                ),
              ),
            ),
            AppSpacing.h10,
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Summary',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  AppSpacing.h10,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sub total',
                        style: TextStyle(fontSize: 15),
                      ),
                      Text(
                        '₹${provider.getTotalAmount(0, 0)}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                  AppSpacing.h10,
                  if (provider.selectedCoupon != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Coupon Discount',
                          style: TextStyle(fontSize: 15, color: Colors.green),
                        ),
                        Text(
                          provider.getDiscountAmount(
                              provider.getTotalAmount(0, 0),
                              double.parse(provider.selectedCoupon.toString())),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.green),
                        ),
                      ],
                    ),
                  AppSpacing.h10,
                  Divider(color: Colors.grey.shade200),
                  AppSpacing.h10,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '₹${provider.getTotalAmount(0, provider.selectedCoupon)}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      bottomSheet: Container(
        color: Colors.white,
        height: 100,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: PrimaryButton(
                isLoading: provider.isLoading,
                onTap: () => provider.buyNow(context, provider.selectedProduct),
                label: 'Continue',
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
  final Function() onDelete;
  final Function() onAdd;
  final Function() onRemove;
  final String itemCount;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                    height: 80,
                    width: 80,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        image,
                        fit: BoxFit.cover,
                      ),
                    )),
                AppSpacing.w10,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2,
                      child: Text(
                        description,
                        maxLines: 1,
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ),
                    Text(
                      '₹$price',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    AppSpacing.h10,
                  ],
                ),
              ],
            ),
            IconButton(
                onPressed: onDelete,
                icon: Icon(Icons.delete_forever, color: Colors.red))
          ],
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 100,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColor.primary)),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onRemove,
                  child: const Icon(Icons.remove, color: AppColor.primary),
                ),
                AppSpacing.w10,
                Text(
                  itemCount,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                AppSpacing.w10,
                GestureDetector(
                  onTap: onAdd,
                  child: const Icon(Icons.add, color: AppColor.primary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
