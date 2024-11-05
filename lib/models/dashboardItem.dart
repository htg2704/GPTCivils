import 'package:civils_gpt/constants/AppConstants.dart';
import 'package:flutter/material.dart';

var _fileName = '';
var _filePath = '';
var _result = '';
var _date = '';

class DashboardItem extends StatelessWidget {
  final String fileName;
  final String filePath;
  final String result;
  final String date;

  DashboardItem(this.fileName, this.filePath, this.result, this.date) {
    _fileName = fileName;
    _filePath = filePath;
    _result = result;
    _date = date;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Container(
        height: 110,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: AppConstants.choosePlanColour),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      fileName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(date),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
