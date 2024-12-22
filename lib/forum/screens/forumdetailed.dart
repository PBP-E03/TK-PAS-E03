// import 'dart:convert';

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:steve_mobile/forum/models/forum_entry.dart';
import 'package:steve_mobile/forum/screens/editform.dart';

class ForumDetailPage extends StatefulWidget {
  final ForumEntry forum;

  const ForumDetailPage({Key? key, required this.forum}) : super(key: key);

  @override
  State<ForumDetailPage> createState() => _ForumDetailPageState();
}

class _ForumDetailPageState extends State<ForumDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  bool isUpvoted = false;
  bool isDownvoted = false;
  late int upvotes;
  late int downvotes;
  List<dynamic> comments = [];
  ForumEntry? forumState;
  String? username;
  Map<int, String>? userComment;

  @override
  void initState() {
    super.initState();
    forumState = widget.forum;
    upvotes = widget.forum.fields.upvotes;
    downvotes = widget.forum.fields.downvotes;
    fetchForum();
    fetchComments();
  }

  Future<String> fetchUser(int id) async {
    final request = context.read<CookieRequest>();
    final response = await request.get(
      'https://danniel-steve.pbp.cs.ui.ac.id/forum/get-username/$id',
    );

    return response["username"];
  }

  Future<void> fetchComments() async {
    final request = context.read<CookieRequest>();
    final response = await request.get(
      'https://danniel-steve.pbp.cs.ui.ac.id/forum/post/${widget.forum.pk}/comments/',
    );
    setState(() {
      comments = response;
    });
  }

  Future<void> fetchForum() async {
    final request = context.read<CookieRequest>();
    final response = await request.get(
      'https://danniel-steve.pbp.cs.ui.ac.id/forum/post/get-${widget.forum.pk}/',
    );
    setState(() {
      for (var d in response) {
        if (d != null) {
          forumState = ForumEntry.fromJson(d);
        }
      }
    });
    var usernameGet = await fetchUser(forumState!.fields.author);
    setState(() {
      username = usernameGet;
    });
  }

  Widget buildCommentsList() {
    if (comments.isEmpty) {
      return const Text('No comments yet.');
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: comments.length,
      itemBuilder: (context, index) {
        final comment = comments[index]['fields'];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment['content'],
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                FutureBuilder(
                    future: fetchUser(comment['author']),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      return Text(
                        'By ${snapshot.data} on ${comment['date_posted']}',
                        style: const TextStyle(color: Colors.grey),
                      );
                    })
              ],
            ),
          ),
        );
      },
    );
  }

  void handleVote(
      bool isUpvote, CookieRequest request, VoidCallback onVoteComplete) async {
    try {
      final response = await request.post(
        isUpvote
            ? 'https://danniel-steve.pbp.cs.ui.ac.id/forum/upvote/${forumState!.pk}/'
            : 'https://danniel-steve.pbp.cs.ui.ac.id/forum/downvote/${forumState!.pk}/',
        {},
      );

      if (context.mounted) {
        if (response['upvotes'] != null && response['downvotes'] != null) {
          setState(() {
            upvotes = response['upvotes'];
            downvotes = response['downvotes'];
            if (isUpvote) {
              isUpvoted = !isUpvoted;
              if (isDownvoted) isDownvoted = false;
            } else {
              isDownvoted = !isDownvoted;
              if (isUpvoted) isUpvoted = false;
            }
          });
          onVoteComplete();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['error'] ?? 'Failed to vote')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void deletePost(CookieRequest request) async {
    try {
      final response = await request.post(
        'https://danniel-steve.pbp.cs.ui.ac.id/forum/post/${forumState!.pk}/delete/',
        {},
      );

      if (context.mounted) {
        if (response['status'] == 'success') {
          Navigator.pop(context, true); // Pass true to indicate deletion
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post deleted successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(response['message'] ?? 'Failed to delete post')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void deleteComment(int commentId) async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.post(
        'https://danniel-steve.pbp.cs.ui.ac.id/forum/comment/$commentId/delete/',
        {},
      );

      if (context.mounted) {
        if (response['status'] == 'success') {
          fetchComments(); // Refresh comments
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Comment deleted successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(response['message'] ?? 'Failed to delete comment')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Widget buildCommentSection(CookieRequest request) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Add a Comment',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _commentController,
          decoration: const InputDecoration(
            hintText: 'Write your comment here...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          onPressed: () async {
            if (_commentController.text.isNotEmpty) {
              final response = await request.postJson(
                  "https://danniel-steve.pbp.cs.ui.ac.id/forum/post/new-comment/",
                  jsonEncode({
                    'post_id': forumState!.pk.toString(),
                    'content': _commentController.text,
                  }));

              if (context.mounted) {
                if (response['status'] == 'success') {
                  _commentController.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Comment successfully posted!"),
                    ),
                  );
                  fetchComments();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text(response['message'] ?? "Failed to post comment"),
                    ),
                  );
                }
              }
            }
          },
          child: const Text('Post Comment'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    if (forumState == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Steve SteakHouse',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFBF4141),
        actions: [
          if (forumState?.fields.author == widget.forum.fields.author)
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'edit') {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditForumPage(
                        forum: forumState!,
                        onUpdate: () {
                          setState(() {
                            fetchForum();
                          });
                        },
                      ),
                    ),
                  );
                  if (result == true) {
                    fetchForum();
                  }
                } else if (value == 'delete') {
                  deletePost(request);
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit Post'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child:
                      Text('Delete Post', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              forumState!.fields.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Restaurant: ${forumState!.fields.resto}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              forumState!.fields.content,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  icon: Icon(
                    Icons.thumb_up,
                    color: isUpvoted ? Colors.white : Colors.grey,
                  ),
                  label: Text('$upvotes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isUpvoted ? Colors.green : Colors.grey[200],
                    foregroundColor: isUpvoted ? Colors.white : Colors.black,
                  ),
                  onPressed: () => handleVote(
                    true,
                    request,
                    () => fetchForum(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: Icon(
                    Icons.thumb_down,
                    color: isDownvoted ? Colors.white : Colors.grey,
                  ),
                  label: Text('$downvotes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isDownvoted ? Colors.red : Colors.grey[200],
                    foregroundColor: isDownvoted ? Colors.white : Colors.black,
                  ),
                  onPressed: () => handleVote(
                    false,
                    request,
                    () => fetchForum(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'By $username on ${forumState!.fields.datePosted}',
              style: const TextStyle(color: Colors.grey),
            ),
            Row(
              children: [
                TextButton(
                  onPressed: () async {
                    // Navigate to edit page with MaterialPageRoute
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditForumPage(
                          forum: forumState!,
                          onUpdate: () {
                            setState(() {
                              fetchForum();
                            });
                          },
                        ),
                      ),
                    );

                    // Refresh if post was updated
                    if (result == true) {
                      setState(() {
                        // Refresh the current page
                        fetchComments();
                      });
                      if (context.mounted) {
                        Navigator.pop(context,
                            true); // Return to list with refresh signal
                      }
                    }
                  },
                  child:
                      const Text('Edit', style: TextStyle(color: Colors.blue)),
                ),
                TextButton(
                  onPressed: () => deletePost(request),
                  child:
                      const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
            const Divider(),
            const Text(
              'Comments',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Comments list
            buildCommentsList(),
            const SizedBox(height: 16),

            // New comment section
            buildCommentSection(request),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
