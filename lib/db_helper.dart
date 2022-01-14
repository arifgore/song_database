import 'package:mysql1/mysql1.dart';

abstract class DBHelper {
  static var settings = ConnectionSettings(
      host: 'localhost',
      port: 3306,
      user: 'arif',
      password: 'dummypassword',
      db: 'music');
  static Future<MySqlConnection> db = MySqlConnection.connect(settings);

  static void initDB() async {
    var checkResponses = await db.then((value) => value.query('SHOW TABLES'));
    if (checkResponses.isNotEmpty) {
      return;
    } else {
      db.then((value) => value.query(
          'CREATE TABLE artists(artist_id INT NOT NULL AUTO_INCREMENT, name VARCHAR(50) NOT NULL, genre VARCHAR(40), PRIMARY KEY (artist_id))'));
      db.then((value) => value.query(
          'CREATE TABLE group_members(artist_id INT NOT NULL, member VARCHAR(50) NOT NULL, PRIMARY KEY (artist_id, member), FOREIGN KEY (artist_id) REFERENCES artists(artist_id))'));
      db.then((value) => value.query(
          'CREATE TABLE albums(album_id INT NOT NULL AUTO_INCREMENT, name VARCHAR(50) NOT NULL, publish_date YEAR NOT NULL, number_of_songs INT NOT NULL, artist_id INT NOT NULL, PRIMARY KEY (album_id), FOREIGN KEY (artist_id) REFERENCES artists(artist_id))'));
      db.then((value) => value.query(
          'CREATE TABLE singles(single_id INT NOT NULL AUTO_INCREMENT, name VARCHAR(50) NOT NULL, publish_date YEAR NOT NULL, artist_id INT NOT NULL, PRIMARY KEY (single_id), FOREIGN KEY (artist_id) REFERENCES artists(artist_id))'));
      db.then((value) => value.query(
          'CREATE TABLE songs(song_id INT NOT NULL AUTO_INCREMENT, name VARCHAR(70) NOT NULL, duration INT NOT NULL, album_id INT, single_id INT, PRIMARY KEY (song_id), FOREIGN KEY (album_id) REFERENCES albums(album_id), FOREIGN KEY (single_id) REFERENCES singles(single_id))'));
      return;
    }
  }

  static void insertDB(var tableName, List<dynamic> values) async {
    if(tableName == "songs"){
      await db.then((value) => value.query(
        'INSERT INTO songs (name, duration, album_id) VALUES (?, ?, ?)', values));
    }
    else if(tableName == "songss"){
      await db.then((value) => value.query(
        'INSERT INTO songs (name, duration, single_id) VALUES (?, ?, ?)', values));
    }
    else if(tableName == "artists"){
      await db.then((value) => value.query(
        'INSERT INTO artists (name, genre) VALUES (?, ?)', values));
    }    
    else if(tableName == "albums"){
      await db.then((value) => value.query(
        'INSERT INTO albums (name, publish_date, number_of_songs, artist_id) VALUES (?, ?, ?, ?)', values));
    }
    else if(tableName == "singles"){
      await db.then((value) => value.query(
        'INSERT INTO singles (name, publish_date, artist_id) VALUES (?, ?, ?)', values));
    }
    else{
      await db.then((value) => value.query(
        'INSERT INTO group_members (artist_id, member) VALUES (?, ?)', values));
    }
  }

  static Future<void> deleteFromDB(var tableName, int id) async {
    if(tableName == "songs"){
      await db.then((value) => value.query(
        'DELETE FROM songs WHERE song_id = ?', [id]));
    }
    else if(tableName == "artists"){
      List<int> albumIDS = await getIdsByCondition('albums', 'artist_id = $id');
      List<int> singleIDS = await getIdsByCondition('singles', 'artist_id = $id');

      for(id in albumIDS){
        await deleteFromDB('albums', id);
      }

      for(id in singleIDS){
        await deleteFromDB('singles', id);
      }

      await db.then((value) => value.query(
        'DELETE FROM group_members WHERE artist_id = ?', [id]));

      await db.then((value) => value.query(
        'DELETE FROM artists WHERE artist_id = ?', [id]));
    }    
    else if(tableName == "albums"){
      List<int> songIDS = await getIdsByCondition('songs', 'album_id = $id');

      for(id in songIDS){
        await deleteFromDB('songs', id);
      }
      await db.then((value) => value.query(
        'DELETE FROM albums WHERE album_id = ?', [id]));
    }
    else if(tableName == 'singles'){
      List<int> songIDS = await getIdsByCondition('songs', 'single_id = $id');

      for(id in songIDS){
        await deleteFromDB('songs', id);
      }
      await db.then((value) => value.query(
        'DELETE FROM singles WHERE single_id = ?', [id]));
    }
  }

  static Future<List<int>> getIdsByCondition(String tableName, String condition) async{
    String idPart = tableName.substring(0,tableName.length - 1) +'_id';
    List<int> idS = [];
    Results result = await db.then((value) => value.query('SELECT $idPart FROM $tableName WHERE $condition'));
    result.forEach((element) {
      idS.add(element.fields[idPart]);
    });
    return idS;
  }



  static Future<List<Map<String, dynamic>>> getFromDB(String tableName) async {
    List<Map<String, dynamic>> tempList = [];
    Results responses = await db.then((value) => value.query('SELECT * FROM $tableName'));
    responses.forEach((element) {
      tempList.add(element.fields);
    });
    return tempList;
  }

  static void updateDB(var tableName, List<dynamic> values) async {
    if(tableName == "songs"){
      await db.then((value) => value.query(
        'UPDATE songs SET name = ?, duration = ?, album_id = ?  WHERE song_id = ? ', values));
    }
    else if(tableName == "songss"){
      await db.then((value) => value.query(
        'UPDATE songs SET name = ?, duration = ?, single_id = ?  WHERE song_id = ? ', values));
    }
    else if(tableName == "artists"){
      await db.then((value) => value.query(
        'UPDATE artists SET name = ?, genre = ? WHERE artist_id = ?', values));
    }    
    else if(tableName == "albums"){
      await db.then((value) => value.query(
        'UPDATE albums SET name = ?, publish_date = ?, number_of_songs = ?, artist_id = ? WHERE album_id = ?', values));
    }
    else if(tableName == "singles"){
      await db.then((value) => value.query(
        'UPDATE albums SET name = ?, publish_date = ?, artist_id = ? WHERE album_id = ?', values));
    }
    else{
      await db.then((value) => value.query(
        'UPDATE group_members SET artist_id = ?, member = ? WHERE artist_id = ? and member = ? ', values));
    }
  }


}
