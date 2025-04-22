import 'package:eatezy/style/app_color.dart';
import 'package:eatezy/view/orders/screens/tabs/cancelled_tab.dart';
import 'package:eatezy/view/orders/screens/tabs/delivery_tab.dart';
import 'package:eatezy/view/orders/screens/tabs/processing_tab.dart';
import 'package:eatezy/view/orders/services/order_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrderScreeen extends StatefulWidget {
  const OrderScreeen({super.key});

  @override
  State<OrderScreeen> createState() => _OrderScreeenState();
}

class _OrderScreeenState extends State<OrderScreeen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    Provider.of<OrderService>(context, listen: false).getOrders();
    Provider.of<OrderService>(context, listen: false).gettVendors();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TabController tabController = TabController(length: 3, vsync: this);
    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders'),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              TabBar(
                  indicatorWeight: 3,
                  labelPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  labelColor: AppColor.primary,
                  unselectedLabelColor: Colors.grey.shade400,
                  controller: tabController,
                  indicatorColor: AppColor.primary,
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: const [
                    Text('Processing'),
                    Text('Completed'),
                    Text('Cancelled'),
                  ]),
              Expanded(
                child: TabBarView(
                  controller: tabController,
                  children: const [
                    ProcessingTab(),
                    DeliveryTab(),
                    CancelledTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
