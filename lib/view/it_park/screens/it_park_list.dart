import 'package:eatezy/view/it_park/services/it_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ItParksList extends StatefulWidget {
  const ItParksList({super.key});

  @override
  State<ItParksList> createState() => _ItParksListState();
}

class _ItParksListState extends State<ItParksList> {
  @override
  void initState() {
    Provider.of<ItService>(context, listen: false).fetchParks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ItService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('IT Parks'),
      ),
      body: Column(
        children: [],
      ),
    );
  }
}
