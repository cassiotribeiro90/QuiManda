import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get_it/get_it.dart';
import '../services/upload_service.dart';
import '../utils/image_helper.dart';

class ProductImagePicker extends StatefulWidget {
  final String? initialImagePath;
  final Function(String?) onImageSelected;
  final Function(String)? onUploadError;
  final String folder;
  final double size;
  final int? storeId;
  final bool showProgress;

  const ProductImagePicker({
    Key? key,
    this.initialImagePath,
    required this.onImageSelected,
    this.onUploadError,
    this.folder = 'produtos',
    this.size = 200,
    this.storeId,
    this.showProgress = true,
  }) : super(key: key);

  @override
  State<ProductImagePicker> createState() => _ProductImagePickerState();
}

class _ProductImagePickerState extends State<ProductImagePicker> {
  String? _imagePath;
  bool _isLoading = false;
  double _uploadProgress = 0.0;

  UploadService get _uploadService => GetIt.instance<UploadService>();

  @override
  void initState() {
    super.initState();
    _imagePath = ImageHelper.extractPath(widget.initialImagePath);
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _imagePath != null && _imagePath!.isNotEmpty
        ? ImageHelper.getFullImageUrl(_imagePath!)
        : null;

    return Column(
      children: [
        GestureDetector(
          onTap: _showPickerOptions,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _imagePath != null && _imagePath!.isNotEmpty 
                    ? Colors.green 
                    : Colors.grey[300]!,
                width: _imagePath != null && _imagePath!.isNotEmpty ? 2 : 1,
              ),
              image: imageUrl != null && imageUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: _buildContent(),
          ),
        ),
        if (_imagePath != null && _imagePath!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Toque para alterar',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
        if (_isLoading && widget.showProgress)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: LinearProgressIndicator(
              value: _uploadProgress,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation(Colors.green),
            ),
          ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (_uploadProgress > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '${(_uploadProgress * 100).toInt()}%',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
        ],
      );
    }

    if (_imagePath == null || _imagePath!.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            'Adicionar imagem',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 18),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black54,
              padding: const EdgeInsets.all(6),
            ),
            onPressed: _removeImage,
          ),
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: IconButton(
            icon: const Icon(Icons.edit, color: Colors.white, size: 18),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black54,
              padding: const EdgeInsets.all(6),
            ),
            onPressed: _showPickerOptions,
          ),
        ),
      ],
    );
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'Selecionar imagem',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text('Galeria'),
              onTap: () => _pickImage(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.green),
              title: const Text('Câmera'),
              onTap: () => _pickImage(ImageSource.camera),
            ),
            if (_imagePath != null && _imagePath!.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Remover imagem', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _removeImage();
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context);
    
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() {
        _isLoading = true;
        _uploadProgress = 0.0;
      });

      final result = await _uploadService.uploadImage(
        file: pickedFile,
        folder: widget.folder,
        storeId: widget.storeId,
        onProgress: (sent, total) {
          setState(() {
            _uploadProgress = sent / total;
          });
        },
      );

      setState(() {
        _imagePath = result.path;
        _isLoading = false;
      });

      widget.onImageSelected(result.path);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Imagem carregada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }

    } catch (e) {
      setState(() => _isLoading = false);
      
      if (widget.onUploadError != null) {
        widget.onUploadError!(e.toString());
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeImage() async {
    if (_imagePath != null && _imagePath!.isNotEmpty) {
      try {
        await _uploadService.deleteImage(_imagePath!);
      } catch (e) {
        debugPrint('Erro ao deletar imagem: $e');
      }
    }

    setState(() {
      _imagePath = null;
    });
    widget.onImageSelected(null);
  }
}
