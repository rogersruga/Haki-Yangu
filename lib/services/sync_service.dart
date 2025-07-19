import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'firestore_service.dart';
import 'offline_service.dart';
import '../models/app_settings.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final FirestoreService _firestoreService = FirestoreService();
  final OfflineService _offlineService = OfflineService();
  
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _syncTimer;
  bool _isSyncing = false;

  // Initialize sync service
  Future<void> initialize() async {
    try {
      // Listen to connectivity changes
      _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
        _onConnectivityChanged,
      );

      // Start periodic sync (every 5 minutes when online)
      _startPeriodicSync();

      if (kDebugMode) {
        print('Sync service initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing sync service: $e');
      }
    }
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    if (results.isNotEmpty && !results.contains(ConnectivityResult.none)) {
      // Device came online, trigger sync
      _triggerSync();
    }
  }

  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _triggerSync();
    });
  }

  Future<void> _triggerSync() async {
    if (_isSyncing) return;

    try {
      _isSyncing = true;
      await _offlineService.syncPendingOperations();
      
      // Update sync status
      final syncStatus = SyncStatus(
        isOnline: await _firestoreService.isOnline(),
        lastSyncTime: DateTime.now(),
        pendingUploads: (await _offlineService.getPendingOperations()).length,
        pendingDownloads: 0,
        failedOperations: [],
      );
      
      await _offlineService.updateSyncStatus(syncStatus);
      
      if (kDebugMode) {
        print('Sync completed successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Sync failed: $e');
      }
    } finally {
      _isSyncing = false;
    }
  }

  // Manual sync trigger
  Future<bool> syncNow() async {
    try {
      await _triggerSync();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Manual sync failed: $e');
      }
      return false;
    }
  }

  // Get current sync status
  Future<SyncStatus> getSyncStatus() async {
    return await _offlineService.getSyncStatus();
  }

  // Check if device is online
  Future<bool> isOnline() async {
    try {
      final connectivityResults = await Connectivity().checkConnectivity();
      if (connectivityResults.isEmpty || connectivityResults.contains(ConnectivityResult.none)) {
        return false;
      }

      // Double-check with Firestore
      return await _firestoreService.isOnline();
    } catch (e) {
      return false;
    }
  }

  // Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
  }
}
