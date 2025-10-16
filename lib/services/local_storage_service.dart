import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/note.dart';

/// Small wrapper around SharedPreferences to store and load notes as JSON.
class LocalStorageService {
  static const _kPrefsKey = 'notes_v1';

  /// Save [notes] to persistent storage as JSON.
  Future<void> saveNotes(List<Note> notes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = notes.map((n) => n.toJson()).toList();
      await prefs.setString(_kPrefsKey, jsonEncode(jsonList));
    } catch (e) {
      // ignore save errors
    }
  }

  /// Load notes from storage. Returns empty list when nothing stored.
  Future<List<Note>> loadNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kPrefsKey);
      if (raw == null || raw.isEmpty) return [];
      final List<dynamic> data = jsonDecode(raw);
      return data.map((e) => Note.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Clears stored notes
  Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kPrefsKey);
    } catch (e) {
      // ignore
    }
  }
}
