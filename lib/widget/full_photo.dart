import 'package:flutter/material.dart';
import 'package:chat_test/shared/const.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FullPhoto extends StatelessWidget {
  final String url;

  FullPhoto({Key key, @required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'FULL PHOTO',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FullPhotoScreen(
        ulr: url,
      ),
    );
  }
}

class FullPhotoScreen extends StatefulWidget {
  final String ulr;

  FullPhotoScreen({Key key, @required this.ulr}) : super(key: key);

  @override
  _FullPhotoScreenState createState() => _FullPhotoScreenState(url: ulr);
}

class _FullPhotoScreenState extends State<FullPhotoScreen> {
  final String url;

  _FullPhotoScreenState({Key key, @required this.url});

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: PhotoView(
        imageProvider: CachedNetworkImageProvider(url),
      ),
    );
  }
}
