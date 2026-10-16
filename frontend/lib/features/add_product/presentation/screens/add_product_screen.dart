import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../ai_grading/presentation/screens/ai_grading_result_screen.dart';

const Color _green = Color(0xFF006828);

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final ImagePicker _picker = ImagePicker();
  final List<Uint8List> _photos = [];
  String _selectedCategory = 'T-Shirt';
  String? _grade;
  bool _pickingPhoto = false;

  Future<void> _addPhotos(ImageSource source) async {
    if (_pickingPhoto || _photos.length >= 6) return;
    setState(() => _pickingPhoto = true);
    try {
      final remaining = 6 - _photos.length;
      if (source == ImageSource.gallery) {
        final selected = await _picker.pickMultiImage(imageQuality: 85);
        if (!mounted || selected.isEmpty) return;
        final photos = await Future.wait(
          selected.take(remaining).map((photo) => photo.readAsBytes()),
        );
        if (!mounted) return;
        setState(() => _photos.addAll(photos));
      } else {
        final photo = await _picker.pickImage(source: source, imageQuality: 85);
        if (!mounted || photo == null) return;
        final bytes = await photo.readAsBytes();
        if (!mounted) return;
        setState(() => _photos.add(bytes));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open your photos. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _pickingPhoto = false);
    }
  }

  Future<void> _showPhotoPicker() async {
    if (_photos.length >= 6 || _pickingPhoto) return;
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(sheetContext);
                _addPhotos(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(sheetContext);
                _addPhotos(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _continue() async {
    if (_photos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least one item photo to continue.'),
        ),
      );
      return;
    }
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => AiGradingResultScreen(
          imageBytes: List<Uint8List>.unmodifiable(_photos),
          category: _selectedCategory,
        ),
      ),
    );
    if (!mounted || result == null) return;
    setState(() => _grade = result);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$result saved to this listing draft.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Sell an item',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Step 1 of 3: Photos & category',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '33%',
                  style: TextStyle(color: _green, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const LinearProgressIndicator(value: 1 / 3, color: _green),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Item photos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_photos.length}/6 photos',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Add clear photos of the front, back, labels, and any wear.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _photos.length + (_photos.length < 6 ? 1 : 0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemBuilder: (context, index) {
                if (index == _photos.length) {
                  return OutlinedButton(
                    onPressed: _pickingPhoto ? null : _showPhotoPicker,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.blue.shade100),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _pickingPhoto
                              ? Icons.hourglass_top
                              : Icons.add_a_photo_outlined,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _pickingPhoto ? 'Opening…' : 'Add photo',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${6 - _photos.length} slots left',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.memory(_photos[index], fit: BoxFit.cover),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: IconButton.filled(
                          tooltip: 'Remove photo',
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                          ),
                          onPressed: () =>
                              setState(() => _photos.removeAt(index)),
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Photo grading is a demo in this build. Review the result yourself before describing your item.',
                style: TextStyle(fontSize: 13),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Category *',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['Shirt', 'T-Shirt', 'Pants', 'Jacket'].map((category) {
                return ChoiceChip(
                  label: Text(category),
                  selected: _selectedCategory == category,
                  onSelected: (_) =>
                      setState(() => _selectedCategory = category),
                  selectedColor: Colors.green.shade100,
                );
              }).toList(),
            ),
            if (_grade != null) ...[
              const SizedBox(height: 12),
              Text(
                'Draft condition: $_grade',
                style: const TextStyle(
                  color: _green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _continue,
                icon: const Icon(Icons.chevron_right),
                label: const Text('Continue to condition review'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
