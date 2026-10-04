class LocalProfile {
  const LocalProfile({
    required this.fullName,
    this.phone = '',
    this.company = '',
  });
  final String fullName, phone, company;
}
