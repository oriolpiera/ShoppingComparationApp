abstract class BackupRepository {
  Future<String> exportBackupJson();

  Future<void> importBackupJson(String jsonPayload);
}
