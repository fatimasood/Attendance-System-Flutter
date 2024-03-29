import 'dart:async';

import 'package:attendence_sys/Student/MarkAt.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

late Database _database;

class DatabaseHelper {
  Future<void> initializeDatabase() async {
    String path = await getDatabasesPath();
    _database = await openDatabase(
      join(path, 'attendence_database.db'),
      onCreate: (db, version) {
        return db.execute(
            '''CREATE TABLE attendence_records( id INTEGER PRIMARY KEY AUTOINCREMENT,
            firstName TEXT,
            lastName TEXT,
            registrationNumber TEXT,
            className TEXT,
            date TEXT,
            isPresent INTEGER )''');
      },
      version: 1,
    );
  }

//insert record
  Future<void> insertAttendanceRecord(AttendanceRecord record) async {
    record.id = await _database.insert('attendence_records', record.toMap());
  }

//delete record

  Future<void> deleteAttendanceRecord(DateTime date) async {
    print('Deleting records for date: $date');
    await _database.delete(
      'attendence_records',
      where: 'date = ?',
      whereArgs: [date.toIso8601String()],
    );
  }

//all record

  Future<List<AttendanceRecord>> getAllAttendanceRecordsForUser(
      String userName) async {
    final List<Map<String, dynamic>> records = await _database.query(
      'attendence_records',
      where: 'firstName || lastName = ?',
      whereArgs: [userName],
      orderBy: 'date DESC',
    );

    return records.map((record) {
      return AttendanceRecord(
        firstName: record['firstName'],
        lastName: record['lastName'],
        regNum: record['registrationNumber'],
        className: record['className'],
        date: DateTime.parse(record['date']),
        isPresent: record['isPresent'] == 1,
      );
    }).toList();
  }

  Future<AttendanceRecord?> getAttendanceRecordByName(
      String firstName, String lastName) async {
    final List<Map<String, dynamic>> records = await _database.query(
      'attendence_records',
      where: 'firstName = ? AND lastName = ?',
      whereArgs: [firstName, lastName],
      orderBy:
          'date DESC', // Order by date in descending order to get the latest record first
      limit: 1, // Limit set
    );

    if (records.isNotEmpty) {
      return AttendanceRecord(
        firstName: records[0]['firstName'],
        lastName: records[0]['lastName'],
        regNum: records[0]['registrationNumber'],
        className: records[0]['className'],
        date: DateTime.parse(records[0]['date']),
        isPresent: records[0]['isPresent'] == 1,
      );
    } else {
      return null;
    }
  }
}
