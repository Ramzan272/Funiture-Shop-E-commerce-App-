import 'package:flutter/material.dart';

import 'constants.dart';


class SearchBox extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const SearchBox({
    Key? key,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(kDefaultPadding),
      padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
      decoration: BoxDecoration(
        color: Colors.white, // Background color changed to white
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 10),
            blurRadius: 20,
            color: Colors.black12,
          ),
        ],
      ),
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(color: Colors.black), // Text color
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: kPrimaryColor), // Icon color
          hintText: "Search",
          hintStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
