import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../utils/image_picker_helper.dart';

class ManagePhotosSheet extends StatefulWidget {
  final Map<String, dynamic>? adminEditUser;

  const ManagePhotosSheet({super.key, this.adminEditUser});

  @override
  State<ManagePhotosSheet> createState() => _ManagePhotosSheetState();
}

class _ManagePhotosSheetState extends State<ManagePhotosSheet> {
  bool _isSaving = false;

  Future<void> _addPhoto() async {
    try {
      final Uint8List? originalBytes = await selectImage(context);
      if (originalBytes == null) return;

      setState(() => _isSaving = true);

      final String base64Image = base64Encode(originalBytes);
      final String dataUri = 'data:image/jpeg;base64,$base64Image';

      if (!mounted) return;
      final provider = Provider.of<AuthProvider>(context, listen: false);
      
      final currentPhotos = widget.adminEditUser != null 
          ? (widget.adminEditUser!['uploadedPhotos'] as List<dynamic>? ?? widget.adminEditUser!['photos'] as List<dynamic>? ?? [])
          : (provider.myProfile?['photos'] as List<dynamic>? ?? []);
      final List<String> updatedPhotos = currentPhotos.map((p) => p.toString()).toList();
      
      updatedPhotos.add(dataUri);

      // Limit to 3 photos maximum
      if (updatedPhotos.length > 3) {
        updatedPhotos.removeRange(3, updatedPhotos.length);
      }

      bool success = false;
      if (widget.adminEditUser != null) {
        final userId = widget.adminEditUser!['_id'] ?? widget.adminEditUser!['id'] ?? widget.adminEditUser!['phone'];
        success = await provider.adminEditUser(userId, {'uploadedPhotos': updatedPhotos});
        provider.fetchAdminUsers();
      } else {
        success = await provider.updateProfileSettings({'uploadedPhotos': updatedPhotos});
        await provider.fetchMyProfile();
      }

      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Photo added successfully!' : 'Failed to add photo.'),
            backgroundColor: success ? Colors.green : Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _isSaving = false);
      debugPrint('Error adding photo: $e');
    }
  }

  Future<void> _deletePhoto(int index) async {
    final provider = Provider.of<AuthProvider>(context, listen: false);
    final currentPhotos = widget.adminEditUser != null 
        ? (widget.adminEditUser!['uploadedPhotos'] as List<dynamic>? ?? widget.adminEditUser!['photos'] as List<dynamic>? ?? [])
        : (provider.myProfile?['photos'] as List<dynamic>? ?? []);
    
    if (currentPhotos.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must have at least one profile photo.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final List<String> updatedPhotos = currentPhotos.map((p) => p.toString()).toList();
    updatedPhotos.removeAt(index);

    bool success = false;
    if (widget.adminEditUser != null) {
      final userId = widget.adminEditUser!['_id'] ?? widget.adminEditUser!['id'] ?? widget.adminEditUser!['phone'];
      success = await provider.adminEditUser(userId, {'uploadedPhotos': updatedPhotos});
      provider.fetchAdminUsers();
    } else {
      success = await provider.updateProfileSettings({'uploadedPhotos': updatedPhotos});
      await provider.fetchMyProfile();
    }

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Photo deleted successfully!' : 'Failed to delete photo.'),
          backgroundColor: success ? Colors.green : Colors.redAccent,
        ),
      );
    }
  }

  Widget _buildPhotoTile(String photo, int index, bool isMain) {
    bool hasImage = photo.isNotEmpty && (photo.startsWith('http') || photo.startsWith('data:image/'));

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: isMain ? AppTheme.accentGold : AppTheme.glassBorderColor, width: isMain ? 2.0 : 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.0),
        child: Stack(
          children: [
            Positioned.fill(
              child: hasImage
                  ? (photo.startsWith('data:image/')
                      ? (() {
                          try {
                            final String base64Data = photo.split(',')[1];
                            final Uint8List imageBytes = base64Decode(base64Data);
                            return Image.memory(imageBytes, fit: BoxFit.cover);
                          } catch (_) {
                            return const Icon(Icons.broken_image, color: Colors.grey);
                          }
                        })()
                      : Image.network(photo, fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image, color: Colors.grey)))
                  : Container(color: AppTheme.backgroundLight),
            ),
            if (isMain)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'MAIN',
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 8,
              right: 8,
              child: InkWell(
                onTap: () => _deletePhoto(index),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AuthProvider>(context);
    final currentPhotos = widget.adminEditUser != null 
        ? (widget.adminEditUser!['uploadedPhotos'] as List<dynamic>? ?? widget.adminEditUser!['photos'] as List<dynamic>? ?? [])
        : (provider.myProfile?['photos'] as List<dynamic>? ?? []);
    final String? housePhoto = widget.adminEditUser != null 
        ? (widget.adminEditUser!['housePhoto'] as String?)
        : (provider.myProfile?['housePhoto'] as String?);

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.0)),
      ),
      padding: const EdgeInsets.all(24.0),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                height: 5,
                width: 40,
                decoration: BoxDecoration(
                  color: AppTheme.glassBorderColor,
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            Text(
              'Manage Photos',
              style: GoogleFonts.cinzel(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textCarbon,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'You can upload up to 3 photos. The first photo is your main profile picture.',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 24.0),
            if (_isSaving)
              const Center(child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(color: AppTheme.accentGold),
              )),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 0.8,
              ),
              itemCount: currentPhotos.length < 3 ? currentPhotos.length + 1 : 3,
              itemBuilder: (context, index) {
                if (index < currentPhotos.length) {
                  return _buildPhotoTile(currentPhotos[index].toString(), index, index == 0);
                } else {
                  return InkWell(
                    onTap: _isSaving ? null : _addPhoto,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.glassColor,
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(color: AppTheme.glassBorderColor, width: 1.0, style: BorderStyle.solid),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_a_photo_outlined, color: AppTheme.accentGold, size: 32),
                          const SizedBox(height: 8),
                          Text(
                            'Add Photo',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textCarbon,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 24.0),
            Text(
              'House/Property Photo (ONLY)',
              style: GoogleFonts.cinzel(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Please upload ONLY a photo of your house/residence (No selfies).',
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.textCarbon,
              ),
            ),
            const SizedBox(height: 16.0),
            if (housePhoto != null && housePhoto.isNotEmpty)
              Stack(
                children: [
                  Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(color: AppTheme.glassBorderColor),
                      image: DecorationImage(
                        image: (housePhoto.startsWith('data:image/') 
                            ? MemoryImage(base64Decode(housePhoto.split(',')[1])) 
                            : NetworkImage(housePhoto)) as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: InkWell(
                      onTap: () async {
                        setState(() => _isSaving = true);
                        if (widget.adminEditUser != null) {
                          final userId = widget.adminEditUser!['_id'] ?? widget.adminEditUser!['id'] ?? widget.adminEditUser!['phone'];
                          await provider.adminEditUser(userId, {'housePhoto': ''});
                          provider.fetchAdminUsers();
                        } else {
                          await provider.updateProfileSettings({'housePhoto': ''});
                          await provider.fetchMyProfile();
                        }
                        if (mounted) setState(() => _isSaving = false);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.delete_outline, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              )
            else
              InkWell(
                onTap: _isSaving ? null : () async {
                  final Uint8List? bytes = await selectImage(context);
                  if (bytes == null) return;
                  setState(() => _isSaving = true);
                  final b64 = base64Encode(bytes);
                  final uri = 'data:image/jpeg;base64,$b64';
                  
                  if (widget.adminEditUser != null) {
                    final userId = widget.adminEditUser!['_id'] ?? widget.adminEditUser!['id'] ?? widget.adminEditUser!['phone'];
                    await provider.adminEditUser(userId, {'housePhoto': uri});
                    provider.fetchAdminUsers();
                  } else {
                    await provider.updateProfileSettings({'housePhoto': uri});
                    await provider.fetchMyProfile();
                  }
                  if (mounted) setState(() => _isSaving = false);
                },
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.glassColor,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: AppTheme.glassBorderColor, width: 1.0, style: BorderStyle.solid),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.home_outlined, color: AppTheme.accentGold, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        'Upload House Photo ONLY',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textCarbon,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 32.0),
          ],
        ),
      ),
    );
  }
}
