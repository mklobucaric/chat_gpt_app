// This function takes a list of maps as input and creates a deep copy
// of the list by copying each map in the original list
List<Map<String, dynamic>> deepCopyList(
    List<Map<String, String>> originalList) {
  // The map function is used to loop through each map in the original list
  return originalList.map((value) => Map<String, String>.from(value)).toList();
  // The `Map.from` constructor is used to create a new map with the same key-value pairs
  // as the original map. The map function returns an Iterable, so we convert it back to a list
  // using the toList() method.
}
