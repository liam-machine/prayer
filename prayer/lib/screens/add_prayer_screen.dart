import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prayer/models/prayer_request.dart';
import 'package:prayer/providers/auth_provider.dart';
import 'package:prayer/providers/prayer_provider.dart';

class AddPrayerScreen extends StatefulWidget {
  const AddPrayerScreen({super.key});

  @override
  State<AddPrayerScreen> createState() => _AddPrayerScreenState();
}

class _AddPrayerScreenState extends State<AddPrayerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  Future<void> _submitPrayerRequest() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final prayerProvider = Provider.of<PrayerProvider>(context, listen: false);
      
      if (authProvider.appUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You must be logged in to create a prayer request')),
          );
        }
        return;
      }
      
      final prayerRequest = PrayerRequest(
        userId: authProvider.appUser!.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
      );
      
      final success = await prayerProvider.createPrayerRequest(prayerRequest);
      
      if (success && mounted) {
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(prayerProvider.errorMessage ?? 'Failed to create prayer request')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final prayerProvider = Provider.of<PrayerProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Prayer Request'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'e.g., Prayer for healing',
                ),
                maxLength: 50,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Share details about your prayer request...',
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                maxLength: 500,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: prayerProvider.isLoading ? null : _submitPrayerRequest,
                child: prayerProvider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Submit Prayer Request'),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your friends will be notified about your prayer request.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 