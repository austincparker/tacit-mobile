import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_base/bloc/auth_bloc.dart';
import 'package:flutter_app_base/model/api_response.dart';
import 'package:flutter_app_base/model/user.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileForm extends StatefulWidget {
  const EditProfileForm({super.key, required this.user});

  final User user;

  @override
  State<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  String _errorMessage = '';
  Map<String, List<String>> _fieldErrors = {};
  bool _isSuccess = false;
  bool _isSaving = false;
  late final TextEditingController _emailController;
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  File? _selectedAvatar;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.user.email);
    _firstNameController = TextEditingController(text: widget.user.firstName ?? '');
    _lastNameController = TextEditingController(text: widget.user.lastName ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  String? _errorTextFor(String field) {
    final errors = _fieldErrors[field];
    if (errors == null || errors.isEmpty) return null;
    return errors.join('. ');
  }

  Future<void> _onPickAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512);
    if (image == null) return;

    setState(() {
      _selectedAvatar = File(image.path);
    });
  }

  Future<void> _onSave() async {
    setState(() {
      _errorMessage = '';
      _fieldErrors = {};
      _isSuccess = false;
      _isSaving = true;
    });

    try {
      await AuthBloc().updateProfile(
        email: _emailController.text,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        avatar: _selectedAvatar,
      );
      setState(() {
        _isSuccess = true;
        _selectedAvatar = null;
      });
    } on ApiResponse catch (response) {
      final error = response.error;
      if (error == null) return;

      setState(() {
        if (error.statusCode == 422) {
          _fieldErrors = error.fieldErrors;
        } else {
          _errorMessage = error.message;
        }
      });
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Widget _buildAvatar() {
    const size = 100.0;

    ImageProvider? imageProvider;
    if (_selectedAvatar != null) {
      imageProvider = FileImage(_selectedAvatar!);
    } else if (widget.user.avatarUrl != null) {
      imageProvider = CachedNetworkImageProvider(widget.user.avatarUrl!);
    }

    return Semantics(
      button: true,
      label: 'Change profile picture',
      hint: 'Tap to select a new photo from your gallery',
      child: GestureDetector(
        onTap: _onPickAvatar,
        child: Stack(
          children: [
            CircleAvatar(
              radius: size / 2,
              backgroundImage: imageProvider,
              child: imageProvider == null ? const Icon(Icons.person, size: size / 2) : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: ExcludeSemantics(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
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
    return AutofillGroup(
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: _buildAvatar()),
        const SizedBox(height: 16),
        if (_isSuccess)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Semantics(
              liveRegion: true,
              child: const Text(
                'Profile updated successfully!',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ),
        if (_errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Semantics(
              liveRegion: true,
              child: Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'Email',
            errorText: _errorTextFor('email'),
          ),
        ),
        TextField(
          controller: _firstNameController,
          autofillHints: const [AutofillHints.givenName],
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'First Name',
            errorText: _errorTextFor('first_name'),
          ),
        ),
        TextField(
          controller: _lastNameController,
          autofillHints: const [AutofillHints.familyName],
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: 'Last Name',
            errorText: _errorTextFor('last_name'),
          ),
          onSubmitted: (_) => _onSave(),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _isSaving ? null : _onSave,
          child: _isSaving
              ? Semantics(
                  label: 'Saving profile',
                  child: const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                )
              : const Text('Save Profile'),
        ),
      ],
    ),
    );
  }
}
