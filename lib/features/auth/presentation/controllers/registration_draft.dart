import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What the seller has typed so far, carried between registration steps.
///
/// The steps are separate screens, so without somewhere to hold this the store
/// name and owner details collected on step one were simply gone by the time
/// the application was submitted -- which is why nothing ever reached
/// `/restaurant/register`.
class RegistrationDraft {
  const RegistrationDraft({
    this.storeName = '',
    this.ownerName = '',
    this.ownerEmail = '',
    this.phone = '',
    this.storeCategory,
    this.businessType,
    this.licenseNumber = '',
  });

  final String storeName;
  final String ownerName;
  final String ownerEmail;
  final String phone;
  final String? storeCategory;
  final String? businessType;
  final String licenseNumber;

  RegistrationDraft copyWith({
    String? storeName,
    String? ownerName,
    String? ownerEmail,
    String? phone,
    String? storeCategory,
    String? businessType,
    String? licenseNumber,
  }) => RegistrationDraft(
    storeName: storeName ?? this.storeName,
    ownerName: ownerName ?? this.ownerName,
    ownerEmail: ownerEmail ?? this.ownerEmail,
    phone: phone ?? this.phone,
    storeCategory: storeCategory ?? this.storeCategory,
    businessType: businessType ?? this.businessType,
    licenseNumber: licenseNumber ?? this.licenseNumber,
  );

  /// True once everything the backend insists on is present.
  ///
  /// The phone matters as much as the rest: sign-in finds a store by it, so
  /// registering without one produces a store nobody can reach.
  bool get isComplete =>
      storeName.trim().isNotEmpty &&
      ownerName.trim().isNotEmpty &&
      ownerEmail.trim().isNotEmpty &&
      phone.trim().isNotEmpty;

  /// The multipart text fields `/food/restaurant/register` reads.
  ///
  /// `pureVegRestaurant` is required by the schema and is a food-delivery
  /// question a grocery seller is never asked, so it is sent false rather than
  /// put in front of them. The licence number goes to whichever field it looks
  /// like: GST numbers are 15 characters, FSSAI 14.
  Map<String, dynamic> toRegisterFields() {
    final licence = licenseNumber.trim();
    return {
      'restaurantName': storeName.trim(),
      'ownerName': ownerName.trim(),
      'ownerEmail': ownerEmail.trim(),
      // Sent unconditionally, and under both names the login lookup searches.
      // A store registered without a phone exists but can never be signed into,
      // so the seller is sent back to registration every time.
      'ownerPhone': phone.trim(),
      'primaryContactNumber': phone.trim(),
      'pureVegRestaurant': 'false',
      if (storeCategory != null) 'cuisines': storeCategory,
      if (licence.isNotEmpty && licence.length == 15) 'gstNumber': licence,
      if (licence.isNotEmpty && licence.length != 15) 'fssaiNumber': licence,
      if (licence.isNotEmpty && licence.length == 15) 'gstRegistered': 'true',
    };
  }
}

class RegistrationDraftController extends Notifier<RegistrationDraft> {
  @override
  RegistrationDraft build() => const RegistrationDraft();

  void update(RegistrationDraft Function(RegistrationDraft) change) =>
      state = change(state);
}

final registrationDraftProvider =
    NotifierProvider<RegistrationDraftController, RegistrationDraft>(
      RegistrationDraftController.new,
    );
