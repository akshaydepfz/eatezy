import 'package:eatezy/map_example.dart';
import 'package:eatezy/model/order_model.dart';
import 'package:eatezy/style/app_color.dart';
import 'package:eatezy/utils/app_spacing.dart';
import 'package:eatezy/view/orders/screens/tabs/cancel/cancell_order.dart';
import 'package:eatezy/view/orders/services/order_service.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';

class ProcessingTab extends StatelessWidget {
  const ProcessingTab({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Consumer<OrderService>(builder: (context, p, _) {
      return p.upmcomingedOrders.isEmpty
          ? Center(
              child: const Text('No Orders Found!'),
            )
          : RefreshIndicator(
              onRefresh: () => p.getOrders(),
              child: ListView.builder(
                itemCount: p.upmcomingedOrders.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppSpacing.h10,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(DateFormat('MMM d yyyy').format(DateTime.parse(
                                p.upmcomingedOrders[index].createdDate))),
                            Container(
                              width: 75,
                              height: 30,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: p.upmcomingedOrders[index].isPaid
                                    ? const Color(0xFFD1EEDB)
                                    : Colors.red.withOpacity(0.2),
                              ),
                              child: Center(
                                child: Text(
                                  'Unpaid',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: p.upmcomingedOrders[index].isPaid
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        ListView.builder(
                            shrinkWrap: true,
                            itemCount:
                                p.upmcomingedOrders[index].products.length,
                            itemBuilder: (context, i) {
                              return ListTile(
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 3),
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: SizedBox(
                                    height: 50,
                                    width: 50,
                                    child: Image.network(
                                      p.upmcomingedOrders[index].products[i]
                                          .image,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  p.upmcomingedOrders[index].products[i].name,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  "X ${p.upmcomingedOrders[index].products[i].quantity}"
                                      .toString(),
                                  style: TextStyle(fontSize: 14),
                                ),
                                trailing: Text(
                                  "₹${p.upmcomingedOrders[index].products[i].price.toString()}",
                                  style: TextStyle(fontSize: 16),
                                ),
                              );
                            }),
                        AppSpacing.h20,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (p.upmcomingedOrders[index].orderStatus !=
                                'Waiting')
                              Container(
                                width: width / 2.5,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.grey,
                                  ),
                                  color: Colors.white,
                                ),
                                child: Center(
                                  child: Text(
                                    'Cancel Order',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            if (p.upmcomingedOrders[index].orderStatus ==
                                'Waiting')
                              OrderButton(
                                width: width,
                                label: 'Cancel Order',
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => CancelOrder(
                                                id: p.upmcomingedOrders[index]
                                                    .id,
                                              )));
                                },
                              ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => OSMTrackingScreen(
                                              orderStatus: p
                                                  .upmcomingedOrders[index]
                                                  .orderStatus,
                                              customerImage: p
                                                  .upmcomingedOrders[index]
                                                  .customerImage,
                                              customerName: p
                                                  .upmcomingedOrders[index]
                                                  .customerName,
                                              vendorToken: p
                                                  .findVendorById(p
                                                      .upmcomingedOrders[index]
                                                      .vendorId)!
                                                  .fcmToken,
                                              orderID:
                                                  p.upmcomingedOrders[index].id,
                                              vendorId: p
                                                  .upmcomingedOrders[index]
                                                  .vendorId,
                                              chatId: p.upmcomingedOrders[index]
                                                  .chatId,
                                              vendorName: p
                                                  .upmcomingedOrders[index]
                                                  .vendorName,
                                              vendorPhone: p
                                                  .upmcomingedOrders[index]
                                                  .vendorPhone,
                                              vendorImage: p
                                                  .upmcomingedOrders[index]
                                                  .shopImage,
                                              lat: double.parse(p
                                                  .upmcomingedOrders[index]
                                                  .lat),
                                              long: double.parse(p
                                                  .upmcomingedOrders[index]
                                                  .long),
                                              isOrder: true,
                                            )));
                              },
                              child: Container(
                                width: width / 2.5,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: AppColor.primary),
                                child: const Center(
                                  child: Text(
                                    'Get Direction',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
            );
    });
  }
}

class ProcessingCard extends StatelessWidget {
  const ProcessingCard({
    super.key,
    required this.width,
    required this.height,
    required this.image,
    required this.price,
    required this.hotel,
    required this.isPaid,
    required this.name,
    required this.orderStatus,
    required this.deliveryBoyId,
    required this.id,
    required this.isAccept,
    required this.order,
    required this.status,
    required this.ontrackingTap,
  });

  final double width;
  final double height;
  final String image;
  final String price;
  final String hotel;
  final String isPaid;
  final String name;
  final String orderStatus;
  final String deliveryBoyId;
  final String id;
  final bool isAccept;
  final OrderModel order;
  final String status;
  final Function() ontrackingTap;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.all(10),
      width: width,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 80,
                width: 80,
                child: Image.network(
                  image,
                  errorBuilder: (context, error, stackTrace) {
                    return LottieBuilder.asset(
                      'assets/lottie/load.json',
                      fit: BoxFit.cover,
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    } else {
                      return LottieBuilder.asset(
                        'assets/lottie/load.json',
                        fit: BoxFit.cover,
                      );
                    }
                  },
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Qty: $hotel",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  AppSpacing.h10,
                  Row(
                    children: [
                      Text(
                        '₹$price',
                        style: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        width: width * .04,
                      ),
                      Container(
                        width: 75,
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: isPaid == 'Paid'
                              ? const Color(0xFFD1EEDB)
                              : Colors.red.withOpacity(0.2),
                        ),
                        child: Center(
                          child: Text(
                            isPaid,
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  isPaid == 'Paid' ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ],
          ),
          AppSpacing.h15,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.schedule, size: 20, color: Colors.grey.shade600),
                  AppSpacing.w5,
                  Text(
                    'Order Status',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
              Text(
                status,
                style: TextStyle(color: Colors.green),
              ),
            ],
          ),
          Divider(
            color: Colors.grey.shade200,
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              isAccept
                  ? Container(
                      width: width / 2.5,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey,
                        ),
                        color: Colors.white,
                      ),
                      child: Center(
                        child: Text(
                          'cancell',
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    )
                  : OrderButton(
                      width: width,
                      label: 'Cancel Order',
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CancelOrder(
                                      id: id,
                                    )));
                      },
                    ),
              GestureDetector(
                onTap: ontrackingTap,
                child: Container(
                  width: width / 2.5,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppColor.primary),
                  child: const Center(
                    child: Text(
                      'Get Direction',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class OrderButton extends StatelessWidget {
  const OrderButton({
    super.key,
    required this.width,
    required this.label,
    required this.onTap,
  });

  final double width;
  final String label;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width / 2.5,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.red,
          ),
          color: Colors.white,
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.red,
            ),
          ),
        ),
      ),
    );
  }
}
