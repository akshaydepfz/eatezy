import 'package:eatezy/utils/app_spacing.dart';
import 'package:eatezy/view/home/services/home_provider.dart';
import 'package:eatezy/view/restaurants/screens/restaurant_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredVendors = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterVendors);
  }

  void _filterVendors() {
    final query = _searchController.text.toLowerCase();
    final vendors = context.read<HomeProvider>().vendors;
    if (vendors != null) {
      setState(() {
        _filteredVendors = vendors
            .where((vendor) => vendor.shopName.toLowerCase().contains(query))
            .toList();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
      ),
      body: Consumer<HomeProvider>(builder: (context, p, _) {
        if (p.vendors == null) {
          return Center(child: CircularProgressIndicator());
        }

        final List vendorsToShow =
            _searchController.text.isEmpty ? p.vendors! : _filteredVendors;

        return SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search restaurants...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  separatorBuilder: (context, index) => Divider(),
                  itemCount: vendorsToShow.length,
                  itemBuilder: (context, i) {
                    final vendor = vendorsToShow[i];
                    return Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12)),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RestaurantViewScreen(
                                        vendor: vendor,
                                      )));
                        },
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(vendor.shopImage),
                              radius: 30,
                            ),
                            AppSpacing.w10,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vendor.shopName,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.place,
                                        size: 15, color: Colors.grey),
                                    Text(
                                      "${vendor.estimateDistance} away",
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 13),
                                    ),
                                  ],
                                ),
                                AppSpacing.h5,
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      color: Colors.red.shade100),
                                  padding: EdgeInsets.all(3),
                                  child: Text(
                                    '30% off, up to ₹300',
                                    style: TextStyle(
                                        fontSize: 11, color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
