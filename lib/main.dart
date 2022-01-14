import 'package:flutter/material.dart';
import 'db_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Database App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Music Database App Homepage'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    DBHelper.initDB();
    Future<List<Map<String, dynamic>>> artistsList =
        DBHelper.getFromDB('artists');
    Future<List<Map<String, dynamic>>> albumsList =
        DBHelper.getFromDB('albums');
    Future<List<Map<String, dynamic>>> singlesList =
        DBHelper.getFromDB('singles');
    Future<List<Map<String, dynamic>>> membersList =
        DBHelper.getFromDB('group_members');
    Future<List<Map<String, dynamic>>> songsList = DBHelper.getFromDB('songs');
    setState(() {});
    return Scaffold(
        backgroundColor: Colors.black26,
        body: Column(
          children: [
            Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.black38),
                height: 70,
                width: MediaQuery.of(context).size.width - 30,
                margin:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    textButton('Artist/Group'),
                    textButton('Album'),
                    textButton('Single'),
                    textButton('Song'),
                    textButton('Group Member')
                  ],
                )),
            Expanded(
              child: Row(
                children: [
                  kolon(context, artistsList, 'artists'),
                  kolon(context, albumsList, 'albums'),
                  kolon(context, singlesList, 'singles'),
                  kolon(context, songsList, 'songs')
                ],
              ),
            ),
          ],
        ));
  }

  Widget kolon(BuildContext context,
      Future<List<Map<String, dynamic>>> usedList, String tableName) {
    String idPart = tableName.substring(0,tableName.length - 1) +'_id';    
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15), color: Colors.black38),
        margin: const EdgeInsets.all(20),
        child: FutureBuilder(
          future: usedList,
          builder: (BuildContext context,
                  AsyncSnapshot<List<Map<String, dynamic>>> snapshot) =>
              snapshot.hasData
                  ? ListView.builder(
                      controller: ScrollController(),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.white),
                          padding: const EdgeInsets.all(7),
                          //color: Colors.white,
                          margin: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          child: Row(
                            children: [
                              Text(snapshot.data![index][idPart].toString() + " -  ", style: TextStyle(color: Colors.red),),
                              GestureDetector(
                                onTap: () {
                                  showModalBottomSheet(
                                      backgroundColor: Colors.black,
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              color: Colors.white12),
                                          height: 500,
                                          child: Center(
                                            child: showAndUpdate(tableName,
                                                snapshot.data![index]),
                                          ),
                                        );
                                      });
                                },
                                child: Text(
                                  snapshot.data![index]['name'],
                                  style: const TextStyle(color: Colors.black),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () {
                                  setState(() {
                                    delete(
                                        tableName,
                                        snapshot.data![index][
                                            tableName.substring(
                                                    0, tableName.length - 1) +
                                                '_id']);
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  : snapshot.connectionState == ConnectionState.waiting
                      ? const SizedBox(
                          height: 70,
                          width: 70,
                          child: CircularProgressIndicator())
                      : const Text(
                          'Burada bir şey yok',
                          style: TextStyle(color: Colors.white),
                        ),
        ),
      ),
    );
  }

  Widget textButton(String label) {
    return TextButton.icon(
      style: TextButton.styleFrom(
        backgroundColor: Colors.white,
        primary: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      icon: const Icon(Icons.add_circle),
      label: Text('Add $label'),
      onPressed: () => showModalBottomSheet(
          backgroundColor: Colors.black,
          context: context,
          builder: (BuildContext context) {
            return Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white12),
              height: 500,
              child: Center(
                child: add(label),
              ),
            );
          }),
    );
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Widget add(String label) {
    if (label == 'Artist/Group') {
      String name = "";
      String genre = "";
      return Form(
        key: _formKey,
        child: SizedBox(
          height: 300,
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                        hintText: 'Enter the artist\'s or group\'s name...'),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a value...';
                      } else {
                        name = value;
                      }
                    },
                  ),
                ),
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    decoration:
                        const InputDecoration(hintText: 'Enter the genre...'),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a value...';
                      } else {
                        genre = value;
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          insert('artists', [name, genre]);
                        });
                      }
                    },
                    child: const Text('Add'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (label == 'Album') {
      String name = "";
      int publish_date = 1000;
      int number_of_songs = 0;
      int artist_id = 0;
      return Form(
        key: _formKey,
        child: SizedBox(
          height: 300,
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    decoration:
                        const InputDecoration(hintText: 'Enter album name...'),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a value...';
                      } else {
                        name = value;
                      }
                    },
                  ),
                ),
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                        hintText: 'Enter publish date...'),
                    validator: (String? value) {
                      if (value == null ||
                          value.isEmpty ||
                          int.tryParse(value) == null) {
                        return 'Please enter a value...';
                      } else {
                        publish_date = int.parse(value);
                      }
                    },
                  ),
                ),
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                        hintText: 'Enter number of songs in album...'),
                    validator: (String? value) {
                      if (value == null ||
                          value.isEmpty ||
                          int.tryParse(value) == null) {
                        return 'Please enter a value...';
                      } else {
                        number_of_songs = int.parse(value);
                      }
                    },
                  ),
                ),
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    decoration:
                        const InputDecoration(hintText: 'Enter artist id ...'),
                    validator: (String? value) {
                      if (value == null ||
                          value.isEmpty ||
                          int.tryParse(value) == null) {
                        return 'Please enter a value...';
                      } else {
                        artist_id = int.parse(value);
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          insert('albums',
                              [name, publish_date, number_of_songs, artist_id]);
                        });
                      }
                    },
                    child: const Text('Add'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (label == 'Single') {
      String name = "";
      int publish_date = 1000;
      int artist_id = 0;
      return Form(
        key: _formKey,
        child: SizedBox(
          height: 300,
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    decoration:
                        const InputDecoration(hintText: 'Enter album name...'),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a value...';
                      } else {
                        name = value;
                      }
                    },
                  ),
                ),
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                        hintText: 'Enter publish date...'),
                    validator: (String? value) {
                      if (value == null ||
                          value.isEmpty ||
                          int.tryParse(value) == null) {
                        return 'Please enter a value...';
                      } else {
                        publish_date = int.parse(value);
                      }
                    },
                  ),
                ),
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    decoration:
                        const InputDecoration(hintText: 'Enter artist id ...'),
                    validator: (String? value) {
                      if (value == null ||
                          value.isEmpty ||
                          int.tryParse(value) == null) {
                        return 'Please enter a value...';
                      } else {
                        artist_id = int.parse(value);
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          insert('singles', [name, publish_date, artist_id]);
                        });
                      }
                    },
                    child: const Text('Add'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (label == 'Song') {
      String name = "";
      int duration = 0;
      int album_id = 0;
      int single_id = 0;
      return Form(
        key: _formKey,
        child: SizedBox(
          height: 300,
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                        hintText: 'Enter the song name...'),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a value...';
                      } else {
                        name = value;
                      }
                    },
                  ),
                ),
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                        hintText: 'Enter the duration...'),
                    validator: (String? value) {
                      if (value == null ||
                          value.isEmpty ||
                          int.tryParse(value) == null) {
                        return 'Please enter a valid value...';
                      } else {
                        duration = int.parse(value);
                      }
                    },
                  ),
                ),
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                        hintText: 'Enter the album id...'),
                    validator: (String? value) {
                      if (value == null ||
                          value.isEmpty ||
                          int.tryParse(value) == null) {
                        return 'Please enter a valid value...';
                      } else {
                        album_id = int.parse(value);
                      }
                    },
                  ),
                ),
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                        hintText: 'Enter the single id...'),
                    validator: (String? value) {
                      if (value == null ||
                          value.isEmpty ||
                          int.tryParse(value) == null) {
                        return 'Please enter a valid value...';
                      } else {
                        single_id = int.parse(value);
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          if (album_id == 0) {
                            insert('songss', [name, duration, single_id]);
                          } else {
                            insert('songs', [name, duration, album_id]);
                          }
                        });
                      }
                    },
                    child: const Text('Add'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      int artist_id = 0;
      String member = "";
      return Form(
        key: _formKey,
        child: SizedBox(
          height: 300,
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    decoration:
                        const InputDecoration(hintText: 'Enter group id...'),
                    validator: (String? value) {
                      if (value == null ||
                          value.isEmpty ||
                          int.tryParse(value) == null) {
                        return 'Please enter a value...';
                      } else {
                        artist_id = int.parse(value);
                      }
                    },
                  ),
                ),
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                        hintText: 'Enter the member\'s name...'),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a value...';
                      } else {
                        member = value;
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          insert('group_members', [artist_id, member]);
                        });
                      }
                    },
                    child: const Text('Add'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  void insert(String tableName, List<dynamic> values) {
    DBHelper.insertDB(tableName, values);
  }

  void delete(String tableName, int id) {
    DBHelper.deleteFromDB(tableName, id);
  }

  void deleteMember(int id, String member) {
    DBHelper.deleteMember(id, member);
  }

  void update(String tableName, List<dynamic> values) {
    DBHelper.updateDB(tableName, values);
  }

  Widget members(BuildContext context,
      Future<List<Map<String, dynamic>>> usedList, String tableName) {
    return FutureBuilder(
      future: usedList,
      builder: (BuildContext context,
              AsyncSnapshot<List<Map<String, dynamic>>> snapshot) =>
          snapshot.hasData
              ? ListView.builder(
                  controller: ScrollController(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                        color: Colors.black,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                margin: const EdgeInsets.all(5),
                                width: 200,
                                child: Text(snapshot.data![index]['member'],
                                    style: TextStyle(color: Colors.white))),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                setState(() {
                                  deleteMember(
                                      snapshot.data![index]['artist_id'],
                                      snapshot.data![index]['member']);
                                });
                              },
                            ),
                          ],
                        ));
                  })
              /*Text(snapshot.data![0]['member'])*/
              : snapshot.connectionState == ConnectionState.waiting
                  ? const CircularProgressIndicator(
                      color: Colors.black,
                    )
                  : const Text(
                      'bos simdilik',
                      style: TextStyle(color: Colors.black),
                    ),
    );
  }

  Widget showAndUpdate(String tableName, Map<String, dynamic> data) {
    if (tableName == 'artists') {
      int artist_id = data['artist_id'];
      String name = data['name'];
      String genre = data['genre'];
      return Form(
        key: _formKey,
        child: SizedBox(
          height: 300,
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    initialValue: name,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a value...';
                      } else {
                        name = value;
                      }
                    },
                  ),
                ),
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    initialValue: genre,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a value...';
                      } else {
                        genre = value;
                      }
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Future<List<Map<String, dynamic>>> membersList =
                              DBHelper.getFromDB('group_members');
                          showModalBottomSheet(
                              backgroundColor: Colors.black,
                              context: context,
                              builder: (BuildContext context) {
                                return Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: Colors.white),
                                  height: 500,
                                  child: Center(
                                    child: members(
                                        context, membersList, 'group_members'),
                                  ),
                                );
                              });
                        },
                        child: const Text('Members'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              update('artists', [name, genre, artist_id]);
                            });
                          }
                        },
                        child: const Text('Update'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    } else if (tableName == 'albums') {
      int album_id = data['album_id'];
      String name = data['name'];
      int publish_date = data['publish_date'];
      int number_of_songs = data['number_of_songs'];
      int artist_id = data['artist_id'];
      return Form(
        key: _formKey,
        child: SizedBox(
          height: 300,
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    initialValue: name,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a value...';
                      } else {
                        name = value;
                      }
                    },
                  ),
                ),
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    initialValue: publish_date.toString(),
                    validator: (String? value) {
                      if (value == null ||
                          value.isEmpty ||
                          int.tryParse(value) == null) {
                        return 'Please enter a value...';
                      } else {
                        publish_date = int.parse(value);
                      }
                    },
                  ),
                ),
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    initialValue: number_of_songs.toString(),
                    validator: (String? value) {
                      if (value == null ||
                          value.isEmpty ||
                          int.tryParse(value) == null) {
                        return 'Please enter a value...';
                      } else {
                        number_of_songs = int.parse(value);
                      }
                    },
                  ),
                ),
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    initialValue: artist_id.toString(),
                    validator: (String? value) {
                      if (value == null ||
                          value.isEmpty ||
                          int.tryParse(value) == null) {
                        return 'Please enter a value...';
                      } else {
                        artist_id = int.parse(value);
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          update('albums', [
                            name,
                            publish_date,
                            number_of_songs,
                            artist_id,
                            album_id
                          ]);
                        });
                      }
                    },
                    child: const Text('Update'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (tableName == 'singles') {
      int single_id = data['single_id'];
      String name = data['name'];
      int publish_date = data['publish_date'];
      int artist_id = data['artist_id'];
      return Form(
        key: _formKey,
        child: SizedBox(
          height: 300,
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    initialValue: name,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a value...';
                      } else {
                        name = value;
                      }
                    },
                  ),
                ),
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    initialValue: publish_date.toString(),
                    validator: (String? value) {
                      if (value == null ||
                          value.isEmpty ||
                          int.tryParse(value) == null) {
                        return 'Please enter a value...';
                      } else {
                        publish_date = int.parse(value);
                      }
                    },
                  ),
                ),
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    initialValue: artist_id.toString(),
                    validator: (String? value) {
                      if (value == null ||
                          value.isEmpty ||
                          int.tryParse(value) == null) {
                        return 'Please enter a value...';
                      } else {
                        artist_id = int.parse(value);
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          update('singles',
                              [name, publish_date, artist_id, single_id]);
                        });
                      }
                    },
                    child: const Text('Update'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (tableName == 'songs') {
      int song_id = data['song_id'];
      String name = data['name'];
      int duration = data['duration'];
      int? album_id = data['album_id'];
      int? single_id = data['single_id'];
      return Form(
        key: _formKey,
        child: SizedBox(
          height: 300,
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    initialValue: name,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a value...';
                      } else {
                        name = value;
                      }
                    },
                  ),
                ),
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    initialValue: duration.toString(),
                    validator: (String? value) {
                      if (value == null ||
                          value.isEmpty ||
                          int.tryParse(value) == null) {
                        return 'Please enter a valid value...';
                      } else {
                        duration = int.parse(value);
                      }
                    },
                  ),
                ),
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    initialValue: album_id == null ? '' : album_id.toString(),
                    validator: (String? value) {
                      if (value == null ||
                          value.isEmpty ||
                          int.tryParse(value) == null) {
                        return 'Please enter a valid value...';
                      } else {
                        album_id = int.parse(value);
                      }
                    },
                  ),
                ),
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    initialValue: single_id == null ? '' : single_id.toString(),
                    validator: (String? value) {
                      if (value == null ||
                          value.isEmpty ||
                          int.tryParse(value) == null) {
                        return 'Please enter a valid value...';
                      } else {
                        single_id = int.parse(value);
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          if (album_id == 0) {
                            update(
                                'songss', [name, duration, single_id, song_id]);
                          } else {
                            update(
                                'songs', [name, duration, album_id, song_id]);
                          }
                        });
                      }
                    },
                    child: const Text('Update'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      int artist_id = data['artist_id'];
      String member = data['member'];
      return Form(
        key: _formKey,
        child: SizedBox(
          height: 300,
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    initialValue: artist_id.toString(),
                    validator: (String? value) {
                      if (value == null ||
                          value.isEmpty ||
                          int.tryParse(value) == null) {
                        return 'Please enter a value...';
                      } else {
                        artist_id = int.parse(value);
                      }
                    },
                  ),
                ),
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    initialValue: member,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a value...';
                      } else {
                        member = value;
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          update('group_members',
                              [artist_id, member, artist_id, member]);
                        });
                      }
                    },
                    child: const Text('Update'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
