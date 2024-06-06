int calculateAge(String birthdateString) {
  // Parse the birthdate string into a DateTime object
  DateTime birthdate = DateTime.parse(birthdateString);

  // Get the current date
  DateTime now = DateTime.now();

  // Calculate the difference between the birthdate and the current date
  Duration difference = now.difference(birthdate);

  // Extract the age from the difference in years
  int age = (difference.inDays / 365).floor();

  return age;
}
