import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../services/assignment_service.dart';
import '../../services/storage_service.dart';
import '../../providers/auth_provider.dart';

class SubmitAssignmentPage extends StatefulWidget {
  final String assignmentId;
  const SubmitAssignmentPage({required this.assignmentId, super.key});

  @override
  State<SubmitAssignmentPage> createState() => _SubmitAssignmentPageState();
}

class _SubmitAssignmentPageState extends State<SubmitAssignmentPage> {
  File? _file;
  bool _isLoading = false;
  String? _fileName;

  Future<void> _pickFile() async {
    final ImagePicker picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _file = File(picked.path);
        _fileName = picked.name;
      });
    }
  }

  Future<void> _submit() async {
    if (_file == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file first')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final auth = context.read<AuthProvider>();
      final studentId = auth.user?.uid ?? 'unknown';
      final storage = StorageService();
      
      // Generate unique file path: assignments/{assignmentId}/{studentId}/{timestamp}_{filename}
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storagePath = 'assignments/${widget.assignmentId}/$studentId/${timestamp}_$_fileName';
      
      // Upload file to Firebase Storage
      final url = await storage.uploadFile(_file!, storagePath);
      
      if (url != null) {
        // Record submission in Firestore
        final asService = AssignmentService();
        await asService.submitAssignment(widget.assignmentId, {
          'fileUrl': url,
          'studentId': studentId,
          'fileName': _fileName,
          'submittedAt': DateTime.now().toIso8601String(),
        });
        
        setState(() => _isLoading = false);
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Assignment submitted successfully!')),
        );
        Navigator.pop(context);
      } else {
        setState(() => _isLoading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload file')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit Assignment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.upload_file),
                title: const Text('Select File'),
                subtitle: Text(_fileName ?? 'No file selected'),
                onTap: _isLoading ? null : _pickFile,
              ),
            ),
            const SizedBox(height: 20),
            if (_file != null) 
              Image.file(_file!, height: 200, fit: BoxFit.cover),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading 
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
