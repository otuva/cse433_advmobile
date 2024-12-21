import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookDetailScreen extends StatefulWidget {
  final String bookId;

  const BookDetailScreen({super.key, required this.bookId});

  @override
  // ignore: library_private_types_in_public_api
  _BookDetailScreenState createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  late DocumentSnapshot bookSnapshot;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookDetails();
  }

  Future<void> _fetchBookDetails() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('books')
          .doc(widget.bookId)
          .get();

      if (doc.exists) {
        setState(() {
          bookSnapshot = doc;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching book details: $e');
    }
  }

  Future<void> _addComment(String commentText) async {
    final comment = {
      'user': 'Onur',
      'text': commentText,
      'liked': true,
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance
          .collection('books')
          .doc(widget.bookId)
          .collection('comments')
          .add(comment);
      _fetchBookDetails();
    } catch (e) {
      print('Error adding comment: $e');
    }
  }

  Future<void> _updateRating(double rating) async {
    try {
      await FirebaseFirestore.instance
          .collection('books')
          .doc(widget.bookId)
          .update({'rating': rating});
    } catch (e) {
      print('Error updating rating: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isLoading
            ? const Text('Loading...')
            : Text(bookSnapshot['title'] ?? 'Book Details'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Image.network(
                              bookSnapshot['image'] ??
                                  'https://via.placeholder.com/150',
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          bookSnapshot['title'] ?? 'Untitled',
                          style: const TextStyle(
                              fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Author: ${bookSnapshot['author'] ?? 'Unknown Author'}',
                          style: const TextStyle(
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey),
                        ),
                        const SizedBox(height: 20),
                        RatingBar.builder(
                          initialRating:
                              (bookSnapshot['rating'] ?? 0.0).toDouble(),
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 30.0,
                          itemBuilder: (context, _) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          onRatingUpdate: (rating) {
                            _updateRating(rating);
                          },
                        ),
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 20),
                        const Text(
                          'Description',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          bookSnapshot['description'] ??
                              'No description available.',
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 20),
                        const Text(
                          'Comments',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('books')
                              .doc(widget.bookId)
                              .collection('comments')
                              .orderBy('timestamp', descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return const Text(
                                'No comments yet.',
                                style: TextStyle(
                                    fontSize: 16, fontStyle: FontStyle.italic),
                              );
                            }

                            final comments = snapshot.data!.docs;

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: comments.length,
                              itemBuilder: (context, index) {
                                final comment = comments[index].data()
                                    as Map<String, dynamic>;
                                return ListTile(
                                  title: Text(comment['user'] ?? 'Anonymous'),
                                  subtitle: Text(comment['text'] ?? ''),
                                  trailing: Icon(
                                    comment['liked'] == true
                                        ? Icons.thumb_up
                                        : Icons.thumb_down,
                                    color: comment['liked'] == true
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Add a comment',
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (text) {
                            _addComment(text);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
