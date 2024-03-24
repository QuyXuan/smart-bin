import 'package:eco_app/common/widgets/custom_skimmer.dart';
import 'package:flutter/material.dart';

class SkeletonTaskListTile extends StatelessWidget {
  const SkeletonTaskListTile({super.key, this.itemCount});

  final int? itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: itemCount ?? 5,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => CustomSkimmer(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 20,
                height: 60,
                decoration: BoxDecoration(
                  border: const Border(
                    left: BorderSide(
                      color: Colors.grey,
                      width: 5,
                    ),
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 10,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.grey),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: 10,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.grey),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
