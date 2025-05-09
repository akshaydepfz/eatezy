import 'package:eatezy/view/orders/services/order_service.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class CancelledTab extends StatelessWidget {
  const CancelledTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderService>(builder: (context, p, _) {
      return p.cancellOrders.isEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('No Cancelled Orders Found!'),
              ],
            )
          : SizedBox();
      // : RefreshIndicator(
      //     onRefresh: () => p.getOrders(),
      //     child: ListView.builder(
      //       itemCount: p.cancellOrders.length,
      //       shrinkWrap: true,
      //       itemBuilder: (context, index) {
      //         return FadeInUp(
      //           duration: const Duration(milliseconds: 800),
      //           child: CancelledCard(
      //             height: height,
      //             width: width,
      //             hotel: p.cancellOrders[index].itemCount.toString(),
      //             image: p.cancellOrders[index].image,
      //             name: p.cancellOrders[index].name,
      //             price: p.cancellOrders[index].price.toString(),
      //           ),
      //         );
      //       },
      //     ),
      //   );
    });
  }
}

class CancelledCard extends StatelessWidget {
  const CancelledCard({
    super.key,
    required this.height,
    required this.width,
    required this.image,
    required this.price,
    required this.hotel,
    required this.name,
  });

  final double width;
  final double height;
  final String image;
  final String price;
  final String hotel;

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(10),
      height: height * .15,
      width: width,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 80,
                width: 80,
                child: Image.network(
                  image,
                  alignment: Alignment.topCenter,
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
                  SizedBox(
                    height: height * .03,
                  ),
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
                        width: width * .20,
                        height: width * .08,
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
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
