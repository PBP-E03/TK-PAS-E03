import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:steve_mobile/forum/models/forum_entry.dart';
import 'package:steve_mobile/widgets/leftdrawer.dart';
import 'package:steve_mobile/forum/screens/forumdetailed.dart';
import 'package:steve_mobile/forum/screens/forumentry_form.dart';

class ListForumEntry extends StatefulWidget {
  const ListForumEntry({super.key});

  @override
  State<ListForumEntry> createState() => _ListForumEntryState();
}

class _ListForumEntryState extends State<ListForumEntry> {
  Future<List<ForumEntry>> fetchForum(CookieRequest request) async {
    try {
      final response = await request
          .get('https://danniel-steve.pbp.cs.ui.ac.id/forum/post/get-all/');

      // Pastikan response adalah List
      if (response is List) {
        List<ForumEntry> listForum = [];
        for (var d in response) {
          if (d != null) {
            listForum.add(ForumEntry.fromJson(d));
          }
        }
        return listForum;
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      // Tambahkan print untuk debugging
      print('Error fetching forum: $e');
      return [];
    }
  }

  Future<String> fetchUser(int id) async {
    final request = context.read<CookieRequest>();
    final response = await request.get(
      'https://danniel-steve.pbp.cs.ui.ac.id/forum/get-username/$id',
    );

    return response["username"];
  }

  Future<String> fetchResto(int id) async {
    final request = context.read<CookieRequest>();
    final response = await request.get(
      'https://danniel-steve.pbp.cs.ui.ac.id/forum/get-resto/$id',
    );

    return response["name"];
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Steve SteakHouse',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFBF4141),
      ),
      drawer: const LeftDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Forum Diskusi',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE85F5C),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ForumEntryFormPage(
                          onSubmitSuccess: () {
                            setState(() {
                              // This will trigger a rebuild and fetch new data
                            });
                          },
                        ),
                      ),
                    );

                    // Refresh list if post was created successfully
                    if (result == true) {
                      setState(() {
                        // This will trigger a rebuild and fetch new data
                      });
                    }
                  },
                  child: const Text(
                    'Create New Post',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: fetchForum(request),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.data == null) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  if (!snapshot.hasData) {
                    return const Column(
                      children: [
                        Text(
                          'Belum ada diskusi.',
                          style:
                              TextStyle(fontSize: 20, color: Color(0xff59A5D8)),
                        ),
                        SizedBox(height: 8),
                      ],
                    );
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (_, index) => Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 7,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ForumDetailPage(
                                      forum: snapshot.data![index],
                                    ),
                                  ),
                                );

                                // Refresh list if post was deleted or updated
                                if (result == true) {
                                  setState(() {
                                    // This will trigger rebuild and fetch new data
                                  });
                                }
                              },
                              child: Text(
                                snapshot.data![index].fields.title,
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(snapshot.data![index].fields.content),
                            const SizedBox(height: 10),
                            FutureBuilder(
                                future: fetchUser(
                                    snapshot.data![index].fields.author),
                                builder: (context, snapshotUser) {
                                  return Text(
                                    "By ${snapshotUser.data} on ${snapshot.data![index].fields.datePosted}",
                                    style: const TextStyle(color: Colors.grey),
                                  );
                                }),
                            // Text(
                            //   "By ${snapshot.data![index].fields.author} on ${snapshot.data![index].fields.datePosted}",
                            //   style: const TextStyle(color: Colors.grey),
                            // ),
                            const SizedBox(height: 10),
                            FutureBuilder(
                                future: fetchResto(
                                    snapshot.data![index].fields.resto),
                                builder: (context, snapshotResto) {
                                  return Text(
                                    "Restaurant: ${snapshotResto.data}",
                                    style: const TextStyle(color: Colors.grey),
                                  );
                                }),
                            // Text(
                            //   "Restaurant: ${snapshot.data![index].fields.resto}"),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Text(
                                    "Upvotes: ${snapshot.data![index].fields.upvotes}"),
                                const SizedBox(width: 20),
                                Text(
                                    "Downvotes: ${snapshot.data![index].fields.downvotes}"),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
