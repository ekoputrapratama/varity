import 'package:flutter/material.dart';

class _PurchasesLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Store is loading'));
  }
}

class _PurchasesNotAvailable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Store not available'));
  }
}
