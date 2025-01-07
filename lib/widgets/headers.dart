import 'package:flutter/cupertino.dart';

Text Header1(String text) {
  return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold
      )
  );
}

Text Header2(String text) {
  return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold
      )
  );
}
