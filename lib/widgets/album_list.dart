import 'package:beathub/classes/album.dart';
import 'package:beathub/main_page.dart';
import 'package:beathub/widgets/horizontal_padding.dart';
import 'package:beathub/widgets/player.dart';
import 'package:flutter/material.dart';

typedef OnSelect = void Function(Album album);

class AlbumList extends StatefulWidget {
  final GlobalKey<PlayerState> playerKey;
  final OnSelect onSelect;
  final double size;

  const AlbumList({
    super.key,
    required this.size,
    required this.playerKey,
    required this.onSelect
  });

  @override
  AlbumListState createState() {
    return AlbumListState();
  }
}

class AlbumListState extends State<AlbumList> {
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      MainPageData.albumScroll = scrollController.position.pixels;
    });

    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(MainPageData.albumScroll);
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    PlayerState? playerState = widget.playerKey.currentState;

    if (playerState == null) {
      return const Text("No tracks");
    }

    double padding = HorizontalPadding.of(context)?.horizontalPadding ?? 0;
    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.only(left: padding, right: padding - 16),
      scrollDirection: Axis.horizontal,
      itemCount: playerState.imageAlbums.length,
      itemBuilder: (context, index) {
        final album = playerState.imageAlbums[index];
        return GestureDetector(
          onTap: () => setState(() => widget.onSelect(album)),
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image(
                    image: album.image,
                    fit: BoxFit.cover,
                    width: widget.size,
                    height: widget.size,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: widget.size,
                  child: Text(
                    album.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(
                  width: widget.size,
                  child: Text(
                    album.author.name,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
