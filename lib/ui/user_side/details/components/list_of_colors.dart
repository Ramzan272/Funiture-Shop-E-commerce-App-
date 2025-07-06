import 'package:flutter/material.dart';
import '../../../components/constants.dart';
import 'color_dots.dart';

class ListOfColors extends StatelessWidget {
  const ListOfColors({
    required Key? key,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ColorDot(
            fillColor: Color(0xFF80989A),
            isSelected: true, key: null,
          ),
          ColorDot(
            fillColor: Color(0xFF00FFE1), key: null,
          ),
          ColorDot(
            fillColor: kPrimaryColor, key: null,
          ),
        ],
      ),
    );
  }
}
