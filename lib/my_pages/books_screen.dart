import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String title;
  final String author;
  final String image;
  final String description;
  double rating;
  final String id;
  List<Comment> comments;

  Book({
    required this.title,
    required this.author,
    required this.image,
    required this.description,
    this.rating = 0.0,
    required this.id,
    this.comments = const [],
  });

  factory Book.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic> data = doc.data() ?? {};

    return Book(
      title: data['title'] ?? 'Untitled',
      author: data['author'] ?? 'Unknown',
      image: data['image'] ?? 'https://via.placeholder.com/150',
      description: data['description'] ?? 'No description provided.',
      rating: (data['rating'] ?? 0.0).toDouble(),
      id: doc.id,
      comments: (data['comments'] as List<dynamic>?)
              ?.map((commentData) => Comment.fromFirestore(commentData))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'author': author,
      'image': image,
      'description': description,
      'rating': rating,
      'comments': comments.map((comment) => comment.toFirestore()).toList(),
    };
  }
}

class Comment {
  final String user;
  final String text;
  final bool liked;

  Comment({required this.user, required this.text, this.liked = false});

  factory Comment.fromFirestore(Map<String, dynamic> data) {
    return Comment(
      user: data['user'] ?? '',
      text: data['text'] ?? '',
      liked: data['liked'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user': user,
      'text': text,
      'liked': liked,
    };
  }
}

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BooksScreenState createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  List<Book> _books = [];
  List<Book> _filteredBooks = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchBooks();
    _searchController.addListener(_filterBooks);
  }

  Future<void> _fetchBooks() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('books').get();

      setState(() {
        _books = snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList();
        _filteredBooks = List.from(_books);
      });
    } catch (e) {
      print('Error fetching books: $e');
    }
  }

  void _filterBooks() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBooks = _books.where((book) {
        return book.title.toLowerCase().contains(query) ||
            book.author.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _addBook(
      String title, String author, String image, String description) async {
    try {
      final DocumentReference<Map<String, dynamic>> docRef =
          await FirebaseFirestore.instance.collection('books').add({
        'title': title,
        'author': author,
        'image': image.isNotEmpty ? image : 'https://via.placeholder.com/150',
        'description': description,
        'rating': 0.0,
        'comments': [],
      });

      setState(() {
        _books.add(Book(
          id: docRef.id,
          title: title,
          author: author,
          image: image.isNotEmpty ? image : 'https://via.placeholder.com/150',
          description: description,
        ));
        _filterBooks();
      });
    } catch (e) {
      print("Failed to add book: $e");
    }
  }

  void _removeBook(String bookId, int index) async {
    try {
      await FirebaseFirestore.instance.collection('books').doc(bookId).delete();

      setState(() {
        _books.removeWhere((book) => book.id == bookId);
        _filteredBooks.removeAt(index);
      });
    } catch (e) {
      print('Failed to remove book: $e');
    }
  }

  void _showAddBookDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController authorController = TextEditingController();
    final TextEditingController imageController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Book'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: authorController,
                  decoration: const InputDecoration(labelText: 'Author'),
                ),
                TextField(
                  controller: imageController,
                  decoration:
                      const InputDecoration(labelText: 'Cover Image URL'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _addBook(
                  titleController.text,
                  authorController.text,
                  imageController.text,
                  descriptionController.text,
                );
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, right: 10, left: 10),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Books'),
          actions: [
            ElevatedButton.icon(
              onPressed: _showAddBookDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search books...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
          ),
        ),
        body: _filteredBooks.isEmpty
            ? const Center(
                child: Text(
                  'No Books in your library',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              )
            : ListView.builder(
                itemCount: _filteredBooks.length,
                itemBuilder: (context, index) {
                  final book = _filteredBooks[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 80,
                            height: 100,
                            margin: const EdgeInsets.only(right: 10),
                            child: Image.network(
                              book.image,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.network(
                                  'https://via.placeholder.com/150',
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  book.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Author: ${book.author}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                RatingBar.builder(
                                  initialRating: book.rating,
                                  minRating: 1,
                                  direction: Axis.horizontal,
                                  allowHalfRating: true,
                                  itemCount: 5,
                                  itemSize: 20.0,
                                  itemBuilder: (context, _) => const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  onRatingUpdate: (rating) async {
                                    setState(() {
                                      book.rating = rating;
                                    });

                                    await FirebaseFirestore.instance
                                        .collection('books')
                                        .doc(book.id)
                                        .update({'rating': rating});
                                  },
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeBook(book.id, index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
