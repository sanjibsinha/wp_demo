import 'package:flutter/material.dart';
import 'package:flutter_wordpress/flutter_wordpress.dart' as wp;
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wp_demo/page_two.dart';

final String _url = 'https://zerodotone.net/';

class PageOne extends StatelessWidget {
  final wp.WordPress wordPress = wp.WordPress(
    baseUrl: _url,
  );

  _launchUrl(String link) async {
    if (await canLaunch(link)) {
      await launch(link);
    } else {
      throw 'Cannot launch $link';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WordPress Demo API for ZeroDotOne'),
        centerTitle: true,
      ),
      body: Container(
        child: FutureBuilder(
          future: _fetchPosts(),
          builder:
              (BuildContext context, AsyncSnapshot<List<wp.Post>> snapshot) {
            if (snapshot.connectionState == ConnectionState.none) {
              return Container();
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                wp.Post post = snapshot.data[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => PageTwo(post)));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: <Widget>[
                            _getPostImage(post),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              post.title.rendered.toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Html(
                              data: post.excerpt.rendered.toString(),
                              onLinkTap: (String link) {
                                _launchUrl(link);
                              },
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(post.date.toString().replaceAll('T', ' ')),
                                Text(post.author.name),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  _fetchPosts() {
    Future<List<wp.Post>> posts = wordPress.fetchPosts(
      postParams: wp.ParamsPostList(
        context: wp.WordPressContext.view,
        pageNum: 1,
        perPage: 10,
        order: wp.Order.desc,
        orderBy: wp.PostOrderBy.date,
      ),
      fetchAuthor: true,
      fetchFeaturedMedia: true,
      postType: "posts",
    );

    return posts;
  }

  _getPostImage(wp.Post post) {
    if (post.featuredMedia == null) {
      return SizedBox();
    }
    return Image.network(post.featuredMedia.sourceUrl);
  }
}
