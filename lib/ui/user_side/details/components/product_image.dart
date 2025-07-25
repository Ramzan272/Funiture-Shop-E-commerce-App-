import 'package:flutter/material.dart';

import '../../../components/constants.dart';


class ProductPoster extends StatelessWidget {
  const ProductPoster({
    required Key? key,
    required this.size,
    required this.image,
  }) : super(key: key);

  final Size size;
  final String image;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: kDefaultPadding),
      height: size.width * 0.8,

      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          Container(
            height: size.width * 0.7,
            width: size.width * 0.7,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          ClipOval(
            child: Image.network(
              image,
              height: size.width * 0.75,
              width: size.width * 0.75,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
