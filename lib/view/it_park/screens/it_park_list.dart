import 'package:eatezy/utils/app_spacing.dart';
import 'package:eatezy/view/it_park/screens/it_restuarants.dart';
import 'package:eatezy/view/it_park/services/it_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ItParksList extends StatefulWidget {
  const ItParksList({super.key});

  @override
  State<ItParksList> createState() => _ItParksListState();
}

class _ItParksListState extends State<ItParksList> {
  final TextEditingController _searchController = TextEditingController();
  List filteredList = [];

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ItService>(context, listen: false);
    provider.getItParks().then((_) {
      setState(() {
        filteredList = provider.itParks;
      });
    });

    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    final provider = Provider.of<ItService>(context, listen: false);

    setState(() {
      filteredList = provider.itParks
          .where((itPark) =>
              itPark.name.toLowerCase().contains(query) ||
              itPark.estimateDistance.toLowerCase().contains(query))
          .toList();
    });
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
        title: Text('IT Parks'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: filteredList.isEmpty
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  AppSpacing.h20,
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: "Search It Parks",
                      hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding: EdgeInsets.only(top: 5),
                    ),
                  ),
                  AppSpacing.h20,
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, i) {
                        final park = filteredList[i];
                        return ListTile(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ItParkRestuarantsScreen(
                                          distance: park.estimateDistance,
                                          image: park.image,
                                          name: park.name,
                                          id: park.id,
                                        )));
                          },
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              height: 100,
                              width: 100,
                              child: Image.network(
                                park.image,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          title: Text(
                            park.name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                park.estimateDistance,
                                style: TextStyle(color: Colors.grey),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    color: Colors.green,
                                    size: 16,
                                  ),
                                  AppSpacing.w5,
                                  Text(
                                    park.estimateTime,
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
