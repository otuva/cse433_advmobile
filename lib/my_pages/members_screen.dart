import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'member_detail_screen.dart';

class Member {
  final String name;
  final String email;
  final String image;
  final String description;
  final String id;

  Member({
    required this.name,
    required this.email,
    required this.image,
    required this.description,
    required this.id,
  });

  factory Member.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic> data = doc.data() ?? {};
    return Member(
      name: data['name'] ?? 'Unknown',
      email: data['email'] ?? 'Unknown',
      image: data['image'] ?? 'https://via.placeholder.com/150',
      description: data['description'] ?? 'No description provided.',
      id: doc.id,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'image': image,
      'description': description,
    };
  }
}

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  _MembersScreenState createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  List<Member> _members = [];
  List<Member> _filteredMembers = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchMembers();
    _searchController.addListener(_filterMembers);
  }

  Future<void> _fetchMembers() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('members').get();
      setState(() {
        _members =
            snapshot.docs.map((doc) => Member.fromFirestore(doc)).toList();
        _filteredMembers = List.from(_members);
      });
    } catch (e) {
      print('Error fetching members: $e');
    }
  }

  void _filterMembers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMembers = _members.where((member) {
        return member.name.toLowerCase().contains(query) ||
            member.email.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _addMember(
      String name, String email, String image, String description) async {
    try {
      final DocumentReference<Map<String, dynamic>> docRef =
          await FirebaseFirestore.instance.collection('members').add({
        'name': name,
        'email': email,
        'image': image,
        'description': description,
      });

      setState(() {
        _members.add(Member(
          name: name,
          email: email,
          image: image,
          description: description,
          id: docRef.id,
        ));
        _filterMembers();
      });
    } catch (e) {
      print("Failed to add member: $e");
    }
  }

  void _removeMember(String memberId, int index) async {
    try {
      await FirebaseFirestore.instance
          .collection('members')
          .doc(memberId)
          .delete();
      setState(() {
        _members.removeWhere((member) => member.id == memberId);
        _filteredMembers.removeAt(index);
      });
    } catch (e) {
      print('Failed to remove member: $e');
    }
  }

  void _showAddMemberDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController imageController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Member'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: imageController,
                  decoration: const InputDecoration(labelText: 'Image URL'),
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
                _addMember(
                  nameController.text,
                  emailController.text,
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
          title: const Text('Members'),
          actions: [
            ElevatedButton.icon(
              onPressed: _showAddMemberDialog,
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
                  hintText: 'Search member...',
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
        body: _filteredMembers.isEmpty
            ? const Center(child: Text('No members found.'))
            : ListView.builder(
                itemCount: _filteredMembers.length,
                itemBuilder: (context, index) {
                  final member = _filteredMembers[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: ListTile(
                      leading: Image.network(
                        member.image,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.person);
                        },
                      ),
                      title: Text(member.name),
                      subtitle: Text(member.email),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MemberDetailScreen(
                              member: member,
                              memberId: '',
                            ),
                          ),
                        );
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _removeMember(member.id, index);
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
