import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/api_client.dart';
import '../../core/constants/app_constants.dart';
import '../utils/image_helper.dart';

class UploadService {
  final ApiClient _apiClient;

  UploadService(this._apiClient);

  static String get FOLDER_PRODUCTS => AppConstants.folderProducts;
  static String get FOLDER_CATEGORIES => AppConstants.folderCategories;
  static String get FOLDER_PROFILE => AppConstants.folderProfile;
  static String get FOLDER_REVIEWS => AppConstants.folderReviews;
  static String get FOLDER_BANNERS => AppConstants.folderBanners;
  static String get FOLDER_STORES => AppConstants.folderStores;

  Future<UploadResult> uploadImage({
    required XFile file,
    String folder = AppConstants.folderProducts,
    int? storeId,
    Function(int sent, int total)? onProgress,
  }) async {
    try {
      final compressedFile = await _compressImage(file);

      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          compressedFile.path,
          filename: '${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: DioMediaType('image', 'jpeg'),
        ),
        'folder': folder,
        if (storeId != null) 'store_id': storeId,
      });

      // 🔥 A URL FINAL SERÁ: http://localhost:8001/api/upload
      final response = await _apiClient.dio.post(
        AppConstants.uploadEndpoint, // <-- '/upload'
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
        onSendProgress: (sent, total) {
          if (onProgress != null) {
            onProgress(sent, total);
          }
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return UploadResult.fromJson(response.data['data']);
      } else {
        throw UploadException(
          response.data['error'] ?? 'Falha no upload',
          response.data['errors'] ?? {},
        );
      }
    } on DioException catch (e) {
      throw UploadException('Erro de rede: ${e.message}', e.response?.data ?? {});
    } catch (e) {
      throw UploadException(e.toString(), {});
    }
  }

  Future<void> deleteImage(String path) async {
    try {
      final cleanPath = ImageHelper.extractPath(path) ?? path;
      await _apiClient.delete(
        AppConstants.uploadEndpoint,
        queryParams: {'path': cleanPath},
      );
    } catch (e) {
      throw UploadException('Erro ao remover imagem: $e', {});
    }
  }

  Future<File> _compressImage(XFile file) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final targetPath = '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        file.path,
        targetPath,
        quality: AppConstants.imageQuality,
        minWidth: AppConstants.imageMaxWidth,
        minHeight: AppConstants.imageMaxHeight,
      );

      return File(result?.path ?? file.path);
    } catch (e) {
      return File(file.path);
    }
  }
}

class UploadResult {
  final String path;
  final String url;
  final String filename;
  final int size;
  final String folder;
  final int? storeId;

  UploadResult({
    required this.path,
    required this.url,
    required this.filename,
    required this.size,
    required this.folder,
    this.storeId,
  });

  factory UploadResult.fromJson(Map<String, dynamic> json) {
    return UploadResult(
      path: json['path'] ?? '',
      url: json['url'] ?? '',
      filename: json['filename'] ?? '',
      size: json['size'] ?? 0,
      folder: json['folder'] ?? '',
      storeId: json['store_id'],
    );
  }
}

class UploadException implements Exception {
  final String message;
  final Map<String, dynamic> errors;
  UploadException(this.message, this.errors);
  @override
  String toString() => 'UploadException: $message';
}