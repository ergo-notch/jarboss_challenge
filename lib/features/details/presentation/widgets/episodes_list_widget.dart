import 'package:flutter/material.dart';

class EpisodesListWidget extends StatelessWidget {
  const EpisodesListWidget({super.key, required this.episodes});

  final List<String> episodes;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(8.0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((_, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  tileColor: Colors.deepPurple.withOpacity(0.9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Colors.deepPurple, width: 2),
                  ),
                  title: Text(
                    episodes[index],
                    style: const TextStyle(
                      color: Colors.yellowAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading: const Icon(
                    Icons.play_circle_outline,
                    color: Colors.yellowAccent,
                    size: 35,
                  ),
                ),
              );
            }, childCount: episodes.length),
          ),
        ),
      ],
    );
  }
}
