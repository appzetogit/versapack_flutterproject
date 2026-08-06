import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_commerce_seller/core/network/dio_client.dart';

/// The documents a store must attach to register.
///
/// The names are the backend's multipart field names, not labels. A file sent
/// under the wrong key is accepted by multer and then silently ignored, so
/// these are worth keeping in one place rather than typed at each call site.
enum StoreDocument {
  pan('panImage', 'PAN Card'),
  gst('gstImage', 'GSTIN Certificate'),
  fssai('fssaiImage', 'FSSAI Licence'),
  storePhoto('profileImage', 'Store Photo'),
  cover('coverImage', 'Cover Photo');

  const StoreDocument(this.field, this.label);

  /// The multipart field the backend reads this document from.
  final String field;
  final String label;
}

/// Seller registration and its document uploads.
///
/// Both endpoints are public: registration happens before an account exists, so
/// there is no token to send.
class RegistrationApi {
  const RegistrationApi(this._dio);

  final Dio _dio;

  /// Uploads one file and returns the URL the backend stored it at.
  ///
  /// Used by the documents step so each attachment is confirmed as it is
  /// picked, rather than discovering at submit time that one of four files was
  /// rejected and having to ask for all of them again.
  Future<String> uploadAttachment({
    required String filePath,
    String folder = 'restaurants',
  }) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
      'folder': folder,
    });

    final response = await _dio.post<dynamic>(
      '/food/restaurant/upload-attachment',
      data: form,
      // The client sets a JSON content type by default. Left to infer, the
      // multipart boundary never reaches the server and the file arrives empty.
      options: Options(contentType: 'multipart/form-data'),
    );

    final data = response.data;
    final url = data is Map ? (data['url'] ?? data['secure_url'] ?? '') : '';
    return url.toString();
  }

  /// Submits the application.
  ///
  /// [documents] maps each document to a local file path. They are sent in the
  /// same multipart request as the text fields, which is what the backend's
  /// register route expects -- it reads the files off named fields rather than
  /// taking URLs uploaded earlier.
  Future<Map<String, dynamic>> register({
    required Map<String, dynamic> fields,
    Map<StoreDocument, String> documents = const {},
    List<String> galleryImagePaths = const [],
  }) async {
    final form = FormData();

    fields.forEach((key, value) {
      if (value == null) return;
      form.fields.add(MapEntry(key, value.toString()));
    });

    for (final entry in documents.entries) {
      if (entry.value.isEmpty) continue;
      form.files.add(
        MapEntry(entry.key.field, await MultipartFile.fromFile(entry.value)),
      );
    }

    for (final path in galleryImagePaths) {
      if (path.isEmpty) continue;
      form.files.add(
        MapEntry('galleryImages', await MultipartFile.fromFile(path)),
      );
    }

    final response = await _dio.post<dynamic>(
      '/food/restaurant/register',
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );

    final data = response.data;
    return data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
  }
}

final registrationApiProvider = Provider<RegistrationApi>(
  (ref) => RegistrationApi(ref.watch(dioProvider)),
);
