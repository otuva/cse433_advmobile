import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class Book {
  final String title;
  final String author;
  final String image;
  final String description;
  double rating;
  List<Comment> comments;

  Book({
    required this.title,
    required this.author,
    required this.image,
    required this.description,
    this.rating = 0.0,
    this.comments = const [],
  });
}

class Comment {
  final String user;
  final String text;
  final bool liked;

  Comment({required this.user, required this.text, this.liked = false});
}

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  _BooksScreenState createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  final List<Book> _books = [
    Book(
      title: 'Book 1',
      author: 'Author 1',
      image: 'https://picsum.photos/150?random=1',
      description: 'Description of Book 1',
    ),
    Book(
      title: 'Book 2',
      author: 'Author 2',
      image: 'https://picsum.photos/150?random=2',
      description: 'Description of Book 2',
    ),
  ];

  List<Book> _filteredBooks = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredBooks = _books;
    _searchController.addListener(_filterBooks);
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

  void _addBook(String title, String author, String image, String description) {
    setState(() {
      _books.add(Book(
        title: title,
        author: author,
        image: image.isNotEmpty
            ? image
            : 'https://via.placeholder.com/150', // Varsayılan görsel
        description: description,
      ));
      _filterBooks();
    });
  }

  void _removeBook(int index) {
    setState(() {
      _books.removeAt(index);
      _filterBooks();
    });
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
              child: const Text('Add'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
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
        body: ListView.builder(
          itemCount: _filteredBooks.length,
          itemBuilder: (context, index) {
            final book = _filteredBooks[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kitap kapağı
                    Container(
                      width: 80,
                      height: 100,
                      margin: const EdgeInsets.only(right: 10),
                      child: Image.network(
                        book.image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.network(
                            'https://via.placeholder.com/150', // Varsayılan görsel
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                    // Kitap detayları (Başlık ve yazar)
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
                          // Puanlama yıldızları
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
                            onRatingUpdate: (rating) {
                              setState(() {
                                book.rating = rating;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    // Silme butonu
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _removeBook(index);
                      },
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
