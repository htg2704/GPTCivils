import 'package:flutter/material.dart';


class ServiceItem extends StatelessWidget {
  var icon;
  var color;
  var text;

  ServiceItem(IconData icon,var text,Color colors){
    this.color=colors;
    this.icon=icon;
    this.text=text;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
            margin:
            EdgeInsets.fromLTRB(20, 0, 10, 10),
            decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.all(
                    Radius.circular(20))),
            padding: EdgeInsets.all(3),
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 50,
                  // color: Colors.blue.shade300,
                  color: Colors.white,
                ),
                // SizedBox(height: 20),
              ],
            ),
          ),
          Text(
            text,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
            softWrap: true,
          )
        ],
      ),
    );
  }
}
