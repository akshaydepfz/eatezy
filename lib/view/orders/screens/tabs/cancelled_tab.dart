import 'package:eatezy/view/orders/services/order_service.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:eatezy/utils/app_spacing.dart';
import 'package:intl/intl.dart';

class CancelledTab extends StatelessWidget {
  const CancelledTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderService>(builder: (context, p, _) {
      return p.cancellOrders.isEmpty
          ? const Center(
              child: Text('No Orders Found!'),
            )
          : RefreshIndicator(
              onRefresh: () => p.getOrders(),
              child: ListView.builder(
                itemCount: p.cancellOrders.length,
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
                                p.cancellOrders[index].createdDate))),
                            Container(
                              width: 75,
                              height: 30,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: const Color(0xFFF8D6D3),
                              ),
                              child: const Center(
                                child: Text(
                                  'Cancelled',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        ListView.builder(
                            shrinkWrap: true,
                            itemCount: p.cancellOrders[index].products.length,
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
                                      p.cancellOrders[index].products[i].image,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return LottieBuilder.asset(
                                          'assets/lottie/load.json',
                                          fit: BoxFit.cover,
                                        );
                                      },
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        } else {
                                          return LottieBuilder.asset(
                                            'assets/lottie/load.json',
                                            fit: BoxFit.cover,
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                title: Text(
                                  p.cancellOrders[index].products[i].name,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  "X ${p.cancellOrders[index].products[i].quantity}"
                                      .toString(),
                                  style: TextStyle(fontSize: 14),
                                ),
                                trailing: Text(
                                  "₹${p.cancellOrders[index].products[i].price.toString()}",
                                  style: TextStyle(fontSize: 16),
                                ),
                              );
                            }),
                        AppSpacing.h20,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Total: ₹${p.cancellOrders[index].totalPrice}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
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
