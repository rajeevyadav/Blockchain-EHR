import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/block.dart';
import 'custom_button.dart';

import 'custom_text.dart';

class RecordDetailCard extends StatelessWidget {
  final Block block;
  final int index;
  RecordDetailCard(this.block, this.index);
  @override
  Widget build(BuildContext context) {
    final deviceheight = MediaQuery.of(context).size.height;
    final f = DateFormat.yMd().add_jm();
    return Container(
      padding: EdgeInsets.all(10),
      height: deviceheight * 0.2,
      child: ListView.builder(
        itemBuilder: (ctx, i) => Card(
          elevation: 7,
          child: ListTile(
            title: CustomText('Visit $index'),
            subtitle: CustomText(
              'Date: ${f.format(
                block.transaction[i].timestamp,
              )}',
            ),
            trailing: CustomButton(
              'View Record',
              () {
                Navigator.of(context).pushNamed(
                  'visit_detail',
                  arguments: block.transaction[i],
                );
              },
            ),
            onTap: () {
              Navigator.of(context).pushNamed(
                'visit_detail',
                arguments: block.transaction[i],
              );
            },
          ),
        ),
        itemCount: block.transaction.length,
      ),
    );
  }
}
