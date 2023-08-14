List<Map<String, dynamic>> deepCopyList(
    List<Map<String, String>> originalList) {
  return originalList.map((value) => Map<String, String>.from(value)).toList();
}
