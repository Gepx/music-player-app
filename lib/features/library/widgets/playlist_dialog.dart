import 'package:flutter/material.dart';
import '../../../utils/constants/colors.dart';
import '../../../data/models/user/playlist.dart';

/// Playlist Dialog
/// Dialog for creating or editing a playlist
class PlaylistDialog extends StatefulWidget {
  final Playlist? playlist; // If provided, we're editing

  const PlaylistDialog({
    super.key,
    this.playlist,
  });

  @override
  State<PlaylistDialog> createState() => _PlaylistDialogState();
}

class _PlaylistDialogState extends State<PlaylistDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  final _formKey = GlobalKey<FormState>();

  bool get _isEditing => widget.playlist != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.playlist?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.playlist?.description ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final result = <String, String>{
        'name': _nameController.text.trim(),
        if (_descriptionController.text.trim().isNotEmpty)
          'description': _descriptionController.text.trim(),
      };
      Navigator.pop(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: FColors.darkContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              Text(
                _isEditing ? 'Edit Playlist' : 'Create Playlist',
                style: const TextStyle(
                  color: FColors.textWhite,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 24),

              // Name Field
              TextFormField(
                controller: _nameController,
                style: const TextStyle(
                  color: FColors.textWhite,
                  fontFamily: 'Poppins',
                ),
                decoration: InputDecoration(
                  labelText: 'Playlist Name',
                  labelStyle: TextStyle(
                    color: FColors.textWhite.withOpacity(0.6),
                    fontFamily: 'Poppins',
                  ),
                  hintText: 'My Awesome Playlist',
                  hintStyle: TextStyle(
                    color: FColors.textWhite.withOpacity(0.3),
                    fontFamily: 'Poppins',
                  ),
                  filled: true,
                  fillColor: FColors.black.withOpacity(0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: FColors.primary),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a playlist name';
                  }
                  return null;
                },
                autofocus: true,
              ),
              const SizedBox(height: 16),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                style: const TextStyle(
                  color: FColors.textWhite,
                  fontFamily: 'Poppins',
                ),
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  labelStyle: TextStyle(
                    color: FColors.textWhite.withOpacity(0.6),
                    fontFamily: 'Poppins',
                  ),
                  hintText: 'Add a description...',
                  hintStyle: TextStyle(
                    color: FColors.textWhite.withOpacity(0.3),
                    fontFamily: 'Poppins',
                  ),
                  filled: true,
                  fillColor: FColors.black.withOpacity(0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: FColors.primary),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: FColors.textWhite.withOpacity(0.6),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _isEditing ? 'Save' : 'Create',
                      style: const TextStyle(
                        color: FColors.textWhite,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

