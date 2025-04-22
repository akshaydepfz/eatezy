import 'package:animate_do/animate_do.dart';
import 'package:eatezy/view/home/services/home_provider.dart';
import 'package:eatezy/view/orders/services/order_service.dart';
import 'package:flutter/material.dart';

import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class DeliveryTab extends StatelessWidget {
  const DeliveryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HomeProvider>(context);
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Consumer<OrderService>(builder: (context, p, _) {
      return p.deliveredOrders.isEmpty
          ? Center(
              child: const Text('No Orders Found!'),
            )
          : RefreshIndicator(
              onRefresh: () => p.getOrders(),
              child: ListView.builder(
                itemCount: p.deliveredOrders.length,
                shrinkWrap: true,
                itemBuilder: (context, i) {
                  return FadeInUp(
                    duration: const Duration(milliseconds: 800),
                    child: DeliveryCard(
                      isRated: p.deliveredOrders[i].isRated,
                      rating: p.deliveredOrders[i].rating,
                      onReviewTap: () {
                        p.showReviewDialog(context, p.deliveredOrders[i].id);
                      },
                      width: width,
                      height: height,
                      hotel: p.deliveredOrders[i].itemCount.toString(),
                      image: p.deliveredOrders[i].image,
                      name: p.deliveredOrders[i].name,
                      price: p.deliveredOrders[i].price.toString(),
                    ),
                  );
                },
              ),
            );
    });
  }
}

class DeliveryCard extends StatelessWidget {
  const DeliveryCard({
    super.key,
    required this.width,
    required this.height,
    required this.image,
    required this.price,
    required this.hotel,
    required this.name,
    required this.onReviewTap,
    required this.isRated,
    required this.rating,
  });

  final double width;
  final double height;
  final String image;
  final String price;
  final String hotel;
  final String name;

  final Function() onReviewTap;
  final double rating;
  final bool isRated;

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
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: const Color(0xFFD1EEDB),
                        ),
                        child: const Center(
                          child: Text(
                            'Completed',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green,
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
          Divider(
            color: Colors.grey.shade200,
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              isRated
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(rating.toInt(), (index) {
                        return Icon(
                          index < rating
                              ? Icons.star
                              : Icons.star_border, // Yellow or Grey
                          color: index < rating ? Colors.amber : Colors.grey,
                          size: 25,
                        );
                      }),
                    )
                  : OrderButton(
                      width: width,
                      label: 'Write Review',
                      onTap: onReviewTap,
                    ),
              GestureDetector(
                onTap: () {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) =>
                  //             ProductViewScreen(product: product)));
                },
                child: Container(
                  width: width / 2.5,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.black,
                  ),
                  child: const Center(
                    child: Text(
                      'Order Again',
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
            color: Colors.black,
          ),
          color: Colors.white,
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
