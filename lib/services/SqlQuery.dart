import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/docModel.dart';

class SqlQuery {
  Future<Database> openDb() async {
    final documentsDirectory = await getApplicationCacheDirectory();
    final path = join(documentsDirectory.path, "documents.db");
    const currentVersion = 3;
    final iOSAndroidDB =
        await openDatabase(path, version: currentVersion, onCreate: (db, version) {
      // Run the CREATE TABLE statement on the database.
      db.execute(
        'CREATE TABLE docs(id INTEGER PRIMARY KEY,pdfName TEXT, fileName TEXT, filePath TEXT,result TEXT, date TEXT)',
      );
    },
        onUpgrade: (db, oldVersion, newVersion){
          print("Heloo");
          print(oldVersion);
          print( newVersion);
          if(oldVersion < currentVersion){
            db.execute('ALTER TABLE docs ADD COLUMN pdfName TEXT');
          }
        });
    print("created");
    return iOSAndroidDB;
  }

  Future<void> insertDoc(DocModel item, database) async {
    // Get a reference to the database.
    final db = await database;
    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, replace any previous data.
    await db.insert(
      'docs',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print("successfully saved");
  }

  Future<void> deleteDoc(DocModel item, Database database) async {
    // Get a reference to the database.
    final db = await database;
    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, replace any previous data.
    await db.delete('docs', where: 'id=${item.id}');
    print("successfully deleted");
  }

  Future<List<DocModel>> getDocs(Database database) async {
    // Get a reference to the database.
    print("trying to get");
    final db = database;
    // Query the table for all the dogs.
    print("trying to get doc");
    final List<Map<String, Object?>> docsMaps = await db.query('docs');
    // Convert the list of each dog's fields into a list of `Dog` objects.
    return [
      for (final {
            'id': id as int,
            'pdfName': pdfName as String,
            'fileName': fileName as String,
            'filePath': filePath as String,
            'result': result as String,
            'date': date as String,
          } in docsMaps)
        DocModel(
            id: id,
            pdfName: pdfName,
            date: date,
            fileName: fileName,
            filePath: filePath,
            result: result),
    ];
  }

  Future<int> countDocs(Database database) async {
    int count = Sqflite.firstIntValue(
        await database.rawQuery('SELECT COUNT(*) FROM docs'))!;
    return count;
  }
}
