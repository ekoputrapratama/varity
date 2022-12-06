import 'dart:io';

class FileUtils {
  static bool isDirectoryWritable(String path) {
    bool isWritable;
    final f = File(path);
    final didExist = f.existsSync();
    try {
      // try appending nothing
      f.writeAsStringSync('', mode: FileMode.append, flush: true);
      isWritable = true;
      if (didExist) {
        f.deleteSync();
      }
    } on FileSystemException {
      isWritable = false;
    }

    return isWritable;
  }
}
