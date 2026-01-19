import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medi_time/data/models/medication_model.dart';

class LocalDB {
  static Database? _database;
  static const String _webKey = 'medications_data';

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('meditime.db');
    return _database!;
  }

  static Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4,
      onCreate: (db, version) async {
        debugPrint("DEBUG: Creating medications table (v$version)");
        await _createTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        debugPrint("DEBUG: Upgrading DB from $oldVersion to $newVersion");
        if (oldVersion < 2) {
          await db.execute('DROP TABLE IF EXISTS medications');
          await _createTable(db);
        } else if (oldVersion < 3) {
          await db.execute(
            'ALTER TABLE medications ADD COLUMN remainingQuantity INTEGER DEFAULT 0',
          );
          await db.execute(
            'ALTER TABLE medications ADD COLUMN color INTEGER DEFAULT 0xFF4CAF50',
          );
        } else if (oldVersion < 4) {
          await db.execute(
            'ALTER TABLE medications ADD COLUMN color INTEGER DEFAULT 0xFF4CAF50',
          );
        }
      },
    );
  }

  static Future<void> _createTable(Database db) async {
    await db.execute('''
      CREATE TABLE medications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        dosage TEXT,
        type TEXT,
        totalQuantity INTEGER,
        quantityPerDose INTEGER,
        remainingQuantity INTEGER,
        color INTEGER,
        doctorName TEXT,
        reason TEXT,
        startDate TEXT,
        endDate TEXT,
        notes TEXT,
        imagePath TEXT,
        scheduleMode TEXT,
        intervalHours INTEGER,
        timeList TEXT,
        daysOfWeek TEXT
      )
    ''');
  }

  // --- Helpers for Web (Shared Preferences) ---

  static Future<List<Medication>> _getWebMedications() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_webKey);
    if (data == null) return [];

    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((e) => Medication.fromMap(e)).toList();
  }

  static Future<void> _saveWebMedications(List<Medication> meds) async {
    final prefs = await SharedPreferences.getInstance();
    final String data = jsonEncode(meds.map((e) => e.toMap()).toList());
    await prefs.setString(_webKey, data);
    debugPrint(
      "DEBUG: Saved ${meds.length} medications to SharedPreferences (Web)",
    );
  }

  // --- CRUD Operations ---

  static Future<int> insertMedication(Medication med) async {
    debugPrint('DEBUG: Insert Medication: ${med.toMap()}');

    if (kIsWeb) {
      final meds = await _getWebMedications();
      // Generate pseudo-ID for web
      final newId = (meds.isEmpty ? 0 : meds.last.id ?? 0) + 1;
      final newMed = Medication(
        id: newId,
        name: med.name,
        dosage: med.dosage,
        type: med.type,
        totalQuantity: med.totalQuantity,
        quantityPerDose: med.quantityPerDose,
        doctorName: med.doctorName,
        reason: med.reason,
        startDate: med.startDate,
        endDate: med.endDate,
        notes: med.notes,
        imagePath: med.imagePath,
        scheduleMode: med.scheduleMode,
        intervalHours: med.intervalHours,
        timeList: med.timeList,
        daysOfWeek: med.daysOfWeek,
      );
      meds.add(newMed);
      await _saveWebMedications(meds);
      return newId;
    } else {
      final db = await database;
      return await db.insert('medications', med.toMap());
    }
  }

  static Future<List<Medication>> getMedications() async {
    if (kIsWeb) {
      debugPrint('DEBUG: Fetching medications from SharedPreferences (Web)');
      return await _getWebMedications();
    } else {
      debugPrint('DEBUG: Fetching medications from SQLite');
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('medications');
      return List.generate(maps.length, (i) => Medication.fromMap(maps[i]));
    }
  }

  static Future<int> updateMedication(Medication med) async {
    debugPrint('DEBUG: Update Medication: ${med.toMap()}');

    if (kIsWeb) {
      final meds = await _getWebMedications();
      final index = meds.indexWhere((element) => element.id == med.id);
      if (index != -1) {
        meds[index] = med;
        await _saveWebMedications(meds);
        return 1;
      }
      return 0;
    } else {
      final db = await database;
      return await db.update(
        'medications',
        med.toMap(),
        where: 'id = ?',
        whereArgs: [med.id],
      );
    }
  }

  static Future<int> deleteMedication(int id) async {
    debugPrint('DEBUG: Delete Medication ID: $id');

    if (kIsWeb) {
      final meds = await _getWebMedications();
      meds.removeWhere((element) => element.id == id);
      await _saveWebMedications(meds);
      return 1;
    } else {
      final db = await database;
      return await db.delete('medications', where: 'id = ?', whereArgs: [id]);
    }
  }
}
