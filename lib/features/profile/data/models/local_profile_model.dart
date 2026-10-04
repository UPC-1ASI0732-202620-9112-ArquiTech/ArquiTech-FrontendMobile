import '../../domain/entities/local_profile.dart';

abstract final class LocalProfileModel {
  static LocalProfile fromJson(Map<String, dynamic> j) => LocalProfile(
    fullName: j['fullName'] as String? ?? '',
    phone: j['phone'] as String? ?? '',
    company: j['company'] as String? ?? '',
  );
  static Map<String, dynamic> toJson(LocalProfile p) => {
    'fullName': p.fullName,
    'phone': p.phone,
    'company': p.company,
  };
}
