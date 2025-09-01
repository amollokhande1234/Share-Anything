import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:shareanything/Provider/side_bar_provide.dart';

Widget HomePage(double size) {
  return Consumer(
    builder: (context, provide, __) {
      return Expanded(
        flex: 8,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Row 1 → Left 70%, Right 30%
              Row(
                children: [
                  _reusableCard(size * 0.5, Colors.blue.shade100, () {
                    context.read<SideBarProvider>().changeIndex(1);
                  }, "Public Messages"),
                  const SizedBox(width: 16),
                  _reusableCard(size * 0.3 - 60, Colors.green.shade100, () {
                    context.read<SideBarProvider>().changeIndex(2);
                  }, "File Share"),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  _reusableCard(size * 0.3 - 60, Colors.orange.shade100, () {
                    context.read<SideBarProvider>().changeIndex(3);
                  }, "Lost & Found"),
                  const SizedBox(width: 16),
                  _reusableCard(size * 0.5, Colors.purple.shade100, () {
                    context.read<SideBarProvider>().changeIndex(4);
                  }, "Private Messages or Groups"),
                ],
              ),

              const SizedBox(height: 16),

              // _reusableCard(double.infinity, Colors.red.shade100, () {
              //   context.read<SideBarProvider>().changeIndex(5);
              // }, "Module 5 (100%)"),
            ],
          ),
        ),
      );
    },
  );
}

Widget _reusableCard(
  double width,
  Color color,
  VoidCallback onTap,
  String title,
) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: width,
      height: 150,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(child: Text(title)),
    ),
  );
}
